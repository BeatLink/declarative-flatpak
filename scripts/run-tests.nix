{ writeShellScriptBin }:

writeShellScriptBin "run-tests" ''
  pushd tests &>/dev/null
  nix flake update flatpak
  nix flake check --print-build-logs
  popd &>/dev/null
''