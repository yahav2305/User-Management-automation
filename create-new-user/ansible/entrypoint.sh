#!/usr/bin/env bash

ansible-galaxy collection install collections/*.tar.gz

export PIP_INDEX_URL=https://repos.network.internal/pypi/simple
export PIP_CERT=/workdir/HTTPSSubCA-chain.pem
pip install -r requirements.txt

ansible-playbook playbook.yml \
  -i inventory.yml