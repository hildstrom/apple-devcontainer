#!/bin/bash
#
# From the docs: "The local domain packet filter rule is removed on a restart."
# Run this with sudo
#

container system dns rm host.container.internal
container system dns create host.container.internal --localhost 203.0.113.113

