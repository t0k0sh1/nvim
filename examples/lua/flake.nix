{
  description = "Lua testing and coverage example";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lua = pkgs.lua5_4.withPackages (packages: with packages; [ busted luacov ]);
        in {
          default = pkgs.mkShell {
            packages = [ lua ];
          };
        });
    };
}
