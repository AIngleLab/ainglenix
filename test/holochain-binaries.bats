#!/usr/bin/env bats

@test "expected aingle version available" {
  result="$(aingle --version)"
  echo $result
  [[ "$result" == *" 0.0.100" ]]
}

@test "expected ai version available" {
  result="$(ai --version)"
  echo $result
  [[ "$result" == *" 0.1.0" ]]
}

@test "expected lair-keystore version available" {
  result="$(lair-keystore --version)"
  echo $result
  [[ "$result" == *" 0.0.1-alpha.12" ]]
}

@test "expected kitsune-p2p-proxy version available" {
  result="$(kitsune-p2p-proxy --version)"
  echo $result
  [[ "$result" == *" 0.0.1" ]]
}
