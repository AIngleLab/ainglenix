# This is the default nix file FOR AINGLENIX
# This file is what nix will find when hitting this repo as a tarball
# This means that downstream consumers should pkgs.callPackage this file
# See example.default.nix for an example of how to consume this file downstream
{
 # allow consumers to pass in their own config
 # fallback to empty sets
 config ? import ./config.nix
 , ai-nixpkgs ? config.ai-nixpkgs.importFn {}
 , includeAIngleBinaries ? true

 # either of: hpos, develop, main, custom. when "custom" is set, `aingleVersion` needs to be specified
 , aingleVersionId? "develop"
 , aingleVersion ? (if aingleVersionId == "custom"
                       then null
                       else builtins.getAttr aingleVersionId ai-nixpkgs.aingleVersions
                      )
 , aingleOtherDepsNames ? [ "lair-keystore" ]
}:

assert (aingleVersionId == "custom") -> aingleVersion != null;

let
 pkgs = import ai-nixpkgs.path {
  overlays = ai-nixpkgs.overlays
    ++ [
      (self: super: {
        ainglenix = ((import <nixpkgs> {}).callPackage or self.callPackage) ./pkgs/ainglenix.nix {
          inherit aingleVersionId aingleVersion;
        };
        ainglenixIntrospect = self.callPackage ./pkgs/ainglenix-introspect.nix { pkgsOfInterest = self.aingleBinaries; };

        # these are referenced in aingle-s merge script.
        # ideally we'd expose all packages in this repository in this way.
        hnRustClippy = builtins.elemAt (self.callPackage ./rust/clippy {}).buildInputs 0;
        hnRustFmtCheck = builtins.elemAt (self.callPackage ./rust/fmt/check {}).buildInputs 0;
        hnRustFmtFmt = builtins.elemAt (self.callPackage ./rust/fmt/fmt {}).buildInputs 0;
        inherit aingleVersionId;
        aingleBinaries =
          if aingleVersionId == "custom" then
            ai-nixpkgs.mkAIngleAllBinariesWithDeps (aingleVersion // {
              otherDeps =
                super.lib.attrsets.filterAttrs (name: value:
                  super.lib.lists.any (elem: elem == name) aingleOtherDepsNames
                ) ai-nixpkgs
                ;
            })
          else
            (builtins.getAttr aingleVersionId ai-nixpkgs.aingleAllBinariesWithDeps)
          ;
      })
    ]
    ;
};

 rust = pkgs.callPackage ./rust {
  inherit config;
 };

 node = pkgs.callPackage ./node { };
 git = pkgs.callPackage ./git { };
 linux = pkgs.callPackage ./linux { };
 docs = pkgs.callPackage ./docs { };
 openssl = pkgs.callPackage ./openssl { };
 release = pkgs.callPackage ./release {
  config = config;
 };
 test = pkgs.callPackage ./test {
   inherit
    pkgs
    config
    ;
 };
 happs = pkgs.callPackage ./happs { };

 ainglenix-shell = pkgs.callPackage ./nix-shell {
  inherit
    pkgs
    docs
    git
    linux
    node
    openssl
    release
    rust
    test
    happs
    ;
  extraBuildInputs = [
      pkgs.ainglenixIntrospect
    ]
    ++ (if !includeAIngleBinaries then [] else
      (builtins.attrValues pkgs.aingleBinaries)
    )
    ;
 };

 # override and overrideDerivation cannot be handled by mkDerivation
 derivation-safe-ainglenix-shell = (removeAttrs ainglenix-shell ["override" "overrideDerivation"]);

in rec
{
 inherit
  ai-nixpkgs
  pkgs
  # expose other things
  rust
  ;

 # export the set used to build shell alongside the main derivation
 # downstream devs can extend/override the shell as needed
 # ainglenix-shell provides canonical dev shell for generic work
 shell = derivation-safe-ainglenix-shell;
 main = derivation-safe-ainglenix-shell;
}
