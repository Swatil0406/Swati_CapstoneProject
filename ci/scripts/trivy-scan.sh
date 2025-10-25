#!/bin/bash
IMAGE=$1
echo "Running Trivy scan on $IMAGE"
trivy image --exit-code 0 --severity HIGH,CRITICAL $IMAGE