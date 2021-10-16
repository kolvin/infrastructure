#!/usr/bin/env bash
set -e -x

# Update and Upgrade
yum update && yum upgrade -y

# CLI Tools
yum install vim -y