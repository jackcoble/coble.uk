#!/bin/bash
# Script to update my PGP public key

# Fetch latest key from keys.openpgp.org
wget "https://keys.openpgp.org/vks/v1/by-fingerprint/C579C19990CE95D90E0B61ABE5B1B9260FA9AA26" -O jackcoble.asc

# Move into static folder
mv jackcoble.asc static/