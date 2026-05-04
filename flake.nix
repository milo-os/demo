{
  description = "milo-demo — local kind-based demo environment for the Milo stack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          name = "milo-demo";

          packages = with pkgs; [
            # Kubernetes tooling
            kind
            kubectl
            kubernetes-helm   # pulled in transitively by some task-infra scripts
            kustomize

            # Task runner (Taskfile)
            go-task

            # Container builds (Docker daemon must be running on the host)
            # docker CLI only — daemon is a host concern
            docker-client

            # Node.js for Playwright verification (verify/ directory)
            nodejs_20
            nodePackages.npm

            # Git (submodule operations)
            git

            # Shell utilities used in hack/ scripts
            bash
            coreutils
            curl
            jq
          ];

          shellHook = ''
            echo "milo-demo dev shell"
            echo "  task demo:up    — boot the full stack"
            echo "  task demo:down  — destroy the cluster"
            echo ""
            if ! docker info &>/dev/null 2>&1; then
              echo "WARNING: Docker daemon not reachable. Start Docker before running demo:up."
            fi
          '';
        };
      }
    );
}
