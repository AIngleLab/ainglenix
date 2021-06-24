{ pkgs }:
let
  name = "ai-happ-create";

  script = pkgs.writeShellScriptBin name
  ''
    curl -L -o happ-template.tar.gz https://github.com/AIngleLab/react-graphql-template/archive/master.tar.gz
    mkdir "''${1:-"Notes-hApp-Template"}"
    tar -zxvf happ-template.tar.gz --strip-components=1 -C ./"''${1:-"Notes-hApp-Template"}"
    rm happ-template.tar.gz
    cd ''${1:-"Notes-hApp-Template"}
    sed -i "s/react-graphql-template/"''${1:-"Notes-hApp-Template"}"/g" package.json
    cd ui_src    
    sed -i "s/react-graphql-template/"''${1:-"Notes-hApp-Template"}"/g" package.json
    cd ..
    cd saf_src    
    sed -i "s/react-graphql-template/"''${1:-"Notes-hApp-Template"}"/g" app.json
    cd ..
    cp ui_src/.env.example ui_src/.env
    yarn ai:install
  '';
in
{
 buildInputs = [ script ];
}
