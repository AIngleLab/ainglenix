# Example: Custom AIngle And Binaries

The following `shell.nix` file can be used in your project's root folder and activated with `nix-shell`.
It uses a custom revision and a custom set of binaries to be installed.

```nix
let 
  ainglenixPath = builtins.fetchTarball {
    url = "https://github.com/AIngleLab/ainglenix/archive/cdf1d199d5489ebc943b88e552507f1063e3e571.tar.gz";
    sha256 = "1b5pdlxj91syg1qqf42f49sxlq9qd3qnz7ccgdncjvhdfyricagh";
  };

  ainglenix = import (ainglenixPath) {
    includeAIngleBinaries = true;

    aingleVersionId = "custom";
    
    aingleVersion = { 
     rev = "e89870cfb68645d656d432a9b50e7e7479542e67";  
     sha256 = "0xn7s8ai6h11cz63yjdfs1spizqz36ngizyx371iygbmh2k9kvg6";  
     cargoSha256 = "0h18qcs9jawmvc09k51bwx58fidqp3456hiz0pwk74122rbs5i7w";
     bins = {
       aingle = "aingle";
       ai = "ai";
       kitsune-p2p-proxy = "kitsune_p2p/proxy";
     };
    };
  };

in ainglenix.main
```
