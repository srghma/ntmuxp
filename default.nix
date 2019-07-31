{
  pkgs ? import ./nix/pkgs.nix,
}:

with pkgs;
with pkgs.haskell.lib;

let
additionalIgnores = ''
  .git
'';
in

((import ./stack2nix.nix { inherit pkgs; }).override {
  overrides = self: super: {
    ntmuxp = justStaticExecutables (overrideCabal super.ntmuxp (old: {
      src = gitignore.gitignoreSource [./.gitignore additionalIgnores] ./.;

      buildTools = old.buildTools or [] ++ [ makeWrapper ];

      postInstall = ''
        wrapProgram $out/bin/ntmuxp \
          --prefix PATH ':' ${lib.makeBinPath [ tmuxp yajl ]}
      '';
    }));
  };
}).ntmuxp
