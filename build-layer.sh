#!/usr/bin/env bash

# Prerequisites:
#
# 1. docker
# 2. zip

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

print_usage() {
    cat <<USAGEMSG
$0: error: the following arguments are required: outfile
usage: $0 outfile
example: $0 layer.zip
USAGEMSG
}

if [ $# -lt 1 ]; then
    print_usage
    exit 1
fi

main() {
  local outfile="${1}"
  
  echo "Building a layer..."
  assemble_layer "${outfile}"
  
  echo "Cleaning up..."
  trap clean_up EXIT
  
  echo "DONE!"
}

assemble_layer() {
  local outfile="${1}"
  docker build -t awscliv2:amazonlinux .
  docker create -it --name dummy awscliv2:amazonlinux bash
  docker cp dummy:/opt/layer.zip ${outfile}
  zip ${outfile} bootstrap
}

clean_up() {
    docker rm -f dummy
    docker image rm awscliv2:amazonlinux
}

main "${@}"
