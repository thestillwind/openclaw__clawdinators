{ pkgs }:
pkgs.buildNpmPackage {
  pname = "pi-coding-agent";
  version = "0.50.1";

  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-0.50.1.tgz";
    hash = "sha256-39tkNCz+h0CjvkAjnWJELsMpeg9HCr4S+y3teNQP8A8=";
  };

  postPatch = ''
    cp ${../vendor/pi-coding-agent/package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-xCHoy5xKeUl/ouowPqyHVlq/zjNTPygxy9af8jItC/w=";
  dontNpmBuild = true;
}
