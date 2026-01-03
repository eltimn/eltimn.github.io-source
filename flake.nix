{
  description = "Basic Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      # Systems to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
          }
        );
    in
    {
      devShell = forAllSystems (
        {
          system,
          pkgs,
          ...
        }:
        pkgs.mkShell {
          # buildInputs = with pkgs; [ ];

          packages = with pkgs; [
            hugo
          ];

          env = {

          };

          shellHook = ''
            echo "Welcome to Basic App!"
          '';
        }
      );
    };
}
