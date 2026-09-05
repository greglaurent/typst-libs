{
  description = "greg's local Typst libraries — installed into Typst's @local namespace.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      # Every subdir here holding a typst.toml is a package (press, and any added later).
      names = builtins.attrNames (lib.filterAttrs
        (n: t: t == "directory" && builtins.pathExists (self + "/${n}/typst.toml"))
        (builtins.readDir self));
      pkgOf = name: (builtins.fromTOML (builtins.readFile (self + "/${name}/typst.toml"))).package;
    in
    {
      # Home-manager module: symlink each package IN THIS REPO into Typst's @local namespace,
      # EDITABLE in place (out-of-store symlink to the live checkout). Add typst-libs as a flake
      # input, `imports = [ typst-libs.homeModules.default ]`, and set `myTypstLibsDir` to the
      # checkout. This module knows nothing about cascade — cascade's flake links its own assets.
      homeModules.default = { config, lib, ... }: {
        options.myTypstLibsDir = lib.mkOption {
          type = lib.types.str;
          description = "Live checkout of this typst-libs repo (for editable @local symlinks).";
        };

        config.xdg.dataFile = lib.listToAttrs (map (name:
          let p = pkgOf name; in
          lib.nameValuePair "typst/packages/local/${p.name}/${p.version}" {
            source = config.lib.file.mkOutOfStoreSymlink "${config.myTypstLibsDir}/${name}";
            force = true;
          }) names);
      };

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [ typst tinymist ];
      };
    };
}
