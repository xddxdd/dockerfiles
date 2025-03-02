{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            stdenv = pkgs.stdenvNoCC;
            buildInputs = with pkgs; [
              gnumake
              gpp
            ];
          };

          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
