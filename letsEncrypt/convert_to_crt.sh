#!/bin/bash
# must be converted to crt to be installed into system
sudo apt update && sudo apt list --upgradable && sudo apt install -y openssl
sudo openssl x509 -in ca.pem -inform PEM -out letsEncrypt-01.crt