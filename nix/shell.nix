let
  nixpkgs = import ./nixpkgs.nix {};

  inherit (nixpkgs) pkgs;

  haskell = import ./haskell { inherit pkgs; };

in
pkgs.mkShell {
  buildInputs = with pkgs; [
    haskell.cabal-install
    haskell.ghc
    haskell.ghcide
    haskell.hlint
    # Other dependencies such as postgresql-12_x would go here.
  ];

  # Use the libraries from the derivation created by ghcWithHoogle.
  NIX_GHC_LIBDIR = "${haskell.ghc}/lib/ghc-${haskell.ghc.version}";
}