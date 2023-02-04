#!/bin/bash

set -u -e

cp /orion-cni /host/opt/cni/bin
cp /01-orion.conf /host/etc/cni/net.d
