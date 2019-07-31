{
  pkgs ? import ./nix/pkgs.nix,
}:

with pkgs;
with pkgs.haskell.lib;

((import ./stack2nix.nix { inherit pkgs; }).override {
  overrides = self: super: {
    ntmuxp = justStaticExecutables (overrideCabal super.ntmuxp (old: {
      src = gitignore.gitignoreSource [./.gitignore] ./.;
    }));
  };
}).ntmuxp
