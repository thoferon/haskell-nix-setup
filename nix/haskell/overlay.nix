nixpkgsSelf: nixpkgsSuper:

let
  inherit (nixpkgsSelf) pkgs;

  ghcVersion = "ghc865";

  hsPkgs = nixpkgsSuper.haskell.packages.${ghcVersion}.override {
    overrides = self: super: {
      # Override ghcide and some of its dependencies since the versions on
      # Nixpkgs is currently broken.
      ghcide = pkgs.haskell.lib.dontCheck (self.callCabal2nix
        "ghcide"
        (builtins.fetchGit {
          url = "https://github.com/digital-asset/ghcide.git";
          rev = "0838dcbbd139e87b0f84165261982c82ca94fd08";
        })
        {});
      hie-bios = pkgs.haskell.lib.dontCheck (self.callHackageDirect {
        pkg = "hie-bios";
        ver = "0.3.2";
        sha256 = "08b3z2k5il72ccj2h0c10flsmz4akjs6ak9j167i8cah34ymygk6";
      } {});
      haskell-lsp = pkgs.haskell.lib.dontCheck (self.callHackageDirect {
        pkg = "haskell-lsp";
        ver = "0.18.0.0";
        sha256 = "0pd7kxfp2limalksqb49ykg41vlb1a8ihg1bsqsnj1ygcxjikziz";
      } {});
      haskell-lsp-types = pkgs.haskell.lib.dontCheck (self.callHackageDirect {
        pkg = "haskell-lsp-types";
        ver = "0.18.0.0";
        sha256 = "1s3q3d280qyr2yn15zb25kv6f5xcizj3vl0ycb4xhl00kxrgvd5f";
      } {});
      shake = pkgs.haskell.lib.dontCheck (self.callHackage "shake" "0.18.3" {});

      # Example of overriding a package with a version known by Nixpkgs.
      hedgehog = self.callHackage "hedgehog" "1.0" {};

      # Example of importing a package from Hackage without using the list of
      # packages in Nixpkgs. This requires us to specify the SHA256.
      morph = self.callHackageDirect {
        pkg = "morph";
        ver = "0.1.1.3";
        sha256 = "1pax8zx2frj4fldjiqicq8c6pm4j5xmldrlapxaww7422irp51n0";
      } {};

      # Example of importing a package from GitHub.
      # This library is in a subdirectory of the repository and the
      # documentation for that commit is broken so we skip generating it.
      eventsourcing =
        let
          eventsourcingRepo = builtins.fetchGit {
            url = "https://github.com/thoferon/eventsourcing.git";
            rev = "6647c61af09d80154f58e858c1a5724144955b34";
          };
        in
        pkgs.haskell.lib.dontHaddock (self.callCabal2nix
          "eventsourcing"
          (eventsourcingRepo + /eventsourcing)
          {});
    };
  };

in
{
  haskell = nixpkgsSuper.haskell // {
    inherit ghcVersion;

    packages = nixpkgsSuper.haskell.packages // {
      "${ghcVersion}" = hsPkgs;
    };
  };
}