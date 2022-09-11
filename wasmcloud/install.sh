#!/bin/bash

helm repo add wasmcloud https://wasmcloud.github.io/wasmcloud-otp/

kubectl create ns wasmcloud

helm -n wasmcloud install wc wasmcloud/wasmcloud-host