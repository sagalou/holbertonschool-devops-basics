# Exploring Your First Network

## Description

This project explores basic Linux networking commands through small Bash scripts. Each script observes a specific aspect of network activity on the current environment: interfaces, loopback connectivity, default routing, hostname resolution, neighbor discovery, and listening sockets.

The scripts do not hardcode network values (interface names, IP addresses, MAC addresses, gateways, hostnames, ports). Each one inspects the environment at execution time and relies on the native output of the selected Linux networking utility.

## Learning Objectives

- Identify network interfaces and interpret their operational state and assigned addresses
- Distinguish link-layer information from IPv4 and IPv6 addressing information
- Test the IPv4 loopback interface with ICMP echo requests
- Identify the configured default IPv4 route
- Query the operating system's configured hostname-resolution mechanism
- Inspect the current IPv4 neighbor table
- Identify listening TCP sockets using numeric addresses and ports
- Select suitable Linux networking utilities and options from official documentation

## Requirements

- All scripts start with `#!/usr/bin/env bash`
- All scripts are executable
- All scripts run without administrator or root privileges
- No hardcoded network values, except the standard loopback address where explicitly allowed
- No package installation, no external libraries, no external HTTP APIs

## Files

| File | Description |
| --- | --- |
| `list_interfaces.sh` | Displays a brief summary of all network interfaces and their assigned IPv4/IPv6 addresses |

## Author

Sagalou