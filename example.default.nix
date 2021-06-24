# This is an example of what downstream consumers of ainglenix should do
# This is also used to dogfood as many commands as possible for ainglenix
# For example the release process for ainglenix uses this file
let

 # point this to your local config.nix file for this project
 # example.config.nix shows and documents a lot of the options
 config = import ./example.config.nix;

 # START AINGLENIX IMPORT BOILERPLATE
 ainglenix = import (
  if ! config.ainglenix.use-github
  then config.ainglenix.local.path
  else fetchTarball {
   url = "https://github.com/${config.ainglenix.github.owner}/${config.ainglenix.github.repo}/tarball/${config.ainglenix.github.ref}";
   sha256 = config.ainglenix.github.sha256;
  }
 ) { config = config; };
 # END AINGLENIX IMPORT BOILERPLATE

in
with ainglenix.pkgs;
{
 dev-shell = stdenv.mkDerivation (ainglenix.shell // {
  name = "dev-shell";

  buildInputs = [ ]
   ++ ainglenix.shell.buildInputs
   ++ config.buildInputs
  ;
 });
}
