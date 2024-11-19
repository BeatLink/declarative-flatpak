{ writeShellScriptBin, inputs }:

writeShellScriptBin "run-shell" ''
  pushd vm &>/dev/null
  nix flake update flatpak
  nixos-shell --quiet --flake .#shell -I nixpkgs=${inputs.nixpkgs}
  popd &>/dev/null
''