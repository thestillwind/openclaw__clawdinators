# Deployment model (fast + declarative)

This repo uses a **two-lane** delivery model:

- **Lane A: Base AMI** (slow path, rare)
  - Purpose: reliable boot substrate (Nix + systemd + networking + EFS + SSM + bootstrap services).
  - Built by: `.github/workflows/image-build.yml` (manual or scheduled).
  - Tradeoff: EC2 VM Import is slow/variable; do not run per-commit.

- **Lane B: Release + Fleet switch** (fast path, every merge)
  - Purpose: ship config/app changes quickly while staying reproducible.
  - Built by: `.github/workflows/release.yml`.
  - Steps:
    1) **Fail-fast eval** of NixOS configs.
    2) Upload **bootstrap bundles** to S3 (repo seeds, workspace, secrets references).
    3) Deploy via **SSM**: `nixos-rebuild switch --flake github:openclaw/clawdinators/<rev>#<host>`.

## Primitives

- **Source of truth**: git SHA + `flake.lock`.
- **Artifact**: NixOS system closure for each host config.
- **Distribution**: Nix substituters + S3 bootstrap bundle.
- **Activation**: `nixos-rebuild switch`.
- **Rollout**: canary order (clawdinator-1 then clawdinator-2).
- **Rollback**: redeploy an older git SHA.

## Tradeoffs

- Pros:
  - Fast deploys (minutes) vs AMI import (tens of minutes).
  - Cattle-friendly: hosts stay disposable; state lives on EFS.
  - Reproducible: deploys are pinned to a git SHA.

- Cons:
  - `nixos-rebuild switch` restarts services; expect brief bot downtime per release.
  - Requires AWS SSM permissions for the CI user (see `infra/opentofu/aws/main.tf`).
  - If Nix caches miss, deploys can be slower (still typically faster than AMI import).

## Infra requirement: CI SSM permissions

`release.yml` uses `aws ssm send-command`.

After pulling these changes, run `tofu apply` in `infra/opentofu/aws` (with admin creds)
so the CI IAM policy includes the `FleetDeploySSM` statement.
