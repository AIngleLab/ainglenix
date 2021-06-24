{ pkgs, aingleVersionId, aingleVersion }:

let
  extraSubstitutors = [
    "https://cache.ai.host"
  ];
  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.ai.host-1:lNXIXtJgS9Iuw4Cu6X0HINLu9sTfcjEntnrgwMQIMcE="
    "cache.ai.host-2:ZJCkX3AUYZ8soxTLfTb60g+F3MkWD7hkH9y8CgqwhDQ="
  ];

  buildCmd = ''
      $(command -v nix-store) \
          --option extra-substituters "${builtins.concatStringsSep " " extraSubstitutors}" \
          --option trusted-public-keys  "${builtins.concatStringsSep " " trustedPublicKeys}" \
          --add-root "''${GC_ROOT_DIR}/allrefs" --indirect \
          --realise "''${ref}"
  '';

in pkgs.writeShellScriptBin "ainglenix" ''
  export GC_ROOT_DIR="''${HOME:-/tmp}/.ainglenix"
  export SHELL_DRV="''${GC_ROOT_DIR}/shellDrv"
  export LOG="''${GC_ROOT_DIR}/log"

  cat <<- EOF
  # AInglenix

  ## Permissions
  This scripts uses sudo to allow specifying Ai's Nix binary cache. Specifically:
  * Instruct Nix to use the following extra substitutors (binary cache):
    - ${builtins.concatStringsSep "\n - " extraSubstitutors}
  * Instruct Nix to use trust these public keys:
    - ${builtins.concatStringsSep "\n  - " trustedPublicKeys}

  If you don't want to use "sudo", you can set HN_NOSUDO="true" prior to calling this script.

  ## Caching
  AInglenix will be cached locally.
  To wipe the cache, remove all symlinks inside ''${GC_ROOT_DIR} and run "nix-collect-garbage".

  ## Running the cached version directly
  Use: nix-shell ''${SHELL_DRV}

  Building...
  EOF

  if [[ $(uname) == "Darwin" ]]; then
    echo macOS detected, disabling sudo.
    export HN_NOSUDO="true"
  fi

  set -euo pipefail
  mkdir -p "''${GC_ROOT_DIR}"

  function handle_error() {
    rc=$?

    echo "Errors during build. Status: $rc)"
    if [[ -e ''${SHELL_DRV} ]]; then
        echo Please see "''${LOG}" for details.
        echo Falling back to cached version
    else
        cat ''${LOG}
        exit $rc
    fi
  }
  trap handle_error err

  function handle_int() {
    rc=$?
    if [[ ''${HN_VERBOSE:-false} != "true" ]]; then
      echo Check ''${LOG} for the build output.
    fi
    echo Aborting.
    exit $rc
  }
  trap handle_int int

  (
    if [[ ''${HN_VERBOSE:-false} != "true" ]]; then
      exec 2>''${LOG} 1>>''${LOG}
    fi

    SHELL_DRV_TMP=$(mktemp)
    rm ''${SHELL_DRV_TMP}

    nix-instantiate --add-root "''${SHELL_DRV_TMP}" --indirect ${builtins.toString ./.}/.. -A main \
      --argstr aingleVersionId ${aingleVersionId} \
      --arg aingleVersion '{ rev = "${aingleVersion.rev}"; sha256 = "${aingleVersion.sha256}"; cargoSha256 = "${aingleVersion.cargoSha256}"; }'
    for ref in `nix-store \
                --add-root "''${GC_ROOT_DIR}/refquery" --indirect \
                --query --references "''${SHELL_DRV_TMP}"`;
    do
      echo Processing ''${ref}

      if [[ "''${HN_NOSUDO:-false}" == "true" ]]; then
        ${buildCmd}
      else
        sudo -E ${buildCmd}
      fi
    done

    mv -f ''${SHELL_DRV_TMP} ''${SHELL_DRV}
  )

  echo Spawning shell..
  export NIX_BUILD_SHELL=${pkgs.bashInteractive}/bin/bash
  nix-shell \
    --add-root "''${GC_ROOT_DIR}/finalShell" --indirect \
    "''${SHELL_DRV}" "''${@}"
''
