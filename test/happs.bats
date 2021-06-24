#!/usr/bin/env bats

@test "ai-happ-scaffold smoke test with json" {
  FILE="./tmp"

  # run the ai-happ-scaffold cmd
  ai-happ-scaffold ./test/scaffold-test.json $FILE
  # Checking if the folder was created
  [[ -d "$FILE" ]]
  [[ -f "$FILE/conductor-config.toml" ]]
  [[ -f "$FILE/saf-src/dist/saf-src.saf.json" ]]
  [[ -d "$FILE/ui-src" ]]

  # remove the created happ
  rm -rf "$FILE"
  # Checking if the file was removed
  ! [[ -d "$FILE" ]]
}

@test "ai-happ-scaffold smoke test with url plus integration test" {
  FILE="./tmp"

  # run the ai-happ-scaffold cmd
  ai-happ-scaffold https://tinyurl.com/ybgdhtwa $FILE
  # Checking if the folder was created
  [[ -d "$FILE" ]]
  [[ -f "$FILE/conductor-config.toml" ]]
  [[ -f "$FILE/saf-src/dist/saf-src.saf.json" ]]
  [[ -d "$FILE/ui-src" ]]

  # run generated happ integration tests
  cd $FILE
  # Checking that integration tests pass
  npm run ci:integration
  cd ..

  # remove the created happ
  rm -rf "$FILE"
  # Checking if the file was removed
  ! [[ -d "$FILE" ]]
}

@test "ai-happ-create smoke test" {
  FILE="./tmp"

  # run the ai-happ-create cmd
  ai-happ-create $FILE
  # Checking if the folder was created
  [[ -d "$FILE" ]]
  [[ -d "$FILE/saf_src" ]]
  [[ -d "$FILE/ui_src" ]]
  [[ -f "$FILE/example.conductor-config.toml" ]]
  # remove the created happ
  rm -rf "$FILE"
  # Checking if the file was removed
  ! [[ -d "$FILE" ]]
}
