#!/bin/bash
# Load environment variables and deploy with Kamal
set -e

echo "Loading .env..."
set -a
source .env
set +a

echo "Deploying with Kamal..."
kamal deploy "$@"

