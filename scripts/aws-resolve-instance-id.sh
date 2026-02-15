#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <host-tag-Name>" >&2
  exit 2
fi

host="$1"

ids="$(aws ec2 describe-instances \
  --filters \
    "Name=tag:app,Values=clawdinator" \
    "Name=tag:Name,Values=${host}" \
    "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text)"

if [ -z "${ids}" ] || [ "${ids}" = "None" ]; then
  echo "no running instance found for Name tag: ${host}" >&2
  exit 1
fi

# If multiple instances match, fail loudly.
count="$(wc -w <<<"${ids}" | tr -d ' ')"
if [ "${count}" != "1" ]; then
  echo "expected 1 instance for ${host}, got ${count}: ${ids}" >&2
  exit 1
fi

echo "${ids}"
