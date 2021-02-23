#!/usr/bin/env bash
 
# ############################################################
# Setup

# Make sure we know where we are
PROJECT_ROOT=`pwd`
GITHUB_USER=`git config --get remote.origin.url | sed 's/https:\/\/github\.com\///' | sed 's/\/.*$//'`

# Fail fast
set -e

# ############################################################
# Test database

echo "Initializing database:"
set -x
sudo mysql -u root -e 'CREATE DATABASE IF NOT EXISTS dashv2_test'
sudo mysql -u root -e 'CREATE USER IF NOT EXISTS travis@localhost'
sudo mysql -u root -e 'GRANT ALL ON dashv2_test.* TO travis@localhost'
{ set +x; } 2>/dev/null
