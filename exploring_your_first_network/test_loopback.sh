#!/usr/bin/env bash

ping -c 4 $(ip addr show | grep "inet " | grep "scope host" | tr -s ' ' | cut -d' ' -f3 | head -n 1 | cut -d'/' -f1)
