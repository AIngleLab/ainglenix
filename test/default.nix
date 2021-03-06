{ pkgs, config }:
let
 # self tests for ainglenix
 # mostly smoke tests on various platforms
 name = "hn-test";

 script = pkgs.writeShellScriptBin name ''
bats ./test/clippy.bats
# TODO: revisit when decided on a new gihtub-release binary
# bats ./test/github-release.bats

bats ./test/nix-shell.bats
${if pkgs.stdenv.isLinux then "bats ./test/perf.bats" else ""}
bats ./test/rust-manifest-list-unpinned.bats
bats ./test/rust.bats
bats ./test/flamegraph.bats
# TODO: refactor the happ scaffolding tests for RSM
# bats ./test/happs.bats
bats ./test/aingle-binaries.bats
'';

in
{
 buildInputs = [
  script
  # test system for bash
  # https://github.com/sstephenson/bats
  pkgs.bats
 ];
}
