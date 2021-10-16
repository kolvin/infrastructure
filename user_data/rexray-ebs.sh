#!/usr/bin/env bash
set -e -x

EBS_REGION_VALUE=${region}
docker plugin install rexray/ebs REXRAY_PREEMPT=true EBS_REGION=$EBS_REGION_VALUE --grant-all-permissions
