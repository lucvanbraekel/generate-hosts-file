# generate-hosts-file.sh

**Generate a local DNS-compatible hosts file for your LAN, compatible with Tailscale subnet routing.**

## 📘 Overview

This script scans your local LAN for active devices and generates an `/etc/hosts`-style file listing IP addresses and hostnames. It's particularly useful when:

- You're using **Tailscale** with **subnet routing**, and
- You want remote devices on your Tailscale network to resolve local hostnames on your LAN(s).

By feeding the generated file to a local DNS server (e.g. `dnsmasq`), you can provide clean hostname resolution across your network — even for devices that don’t broadcast a hostname natively.

---

## ✨ Features

- Uses **multiple methods** to determine hostnames:
  1. Hostnames from `nmap` scans.
  2. NetBIOS names using `nbtscan`.
  3. Avahi `.local` names using `avahi-resolve-address`.
  4. Vendor names from MAC address if hostname is still missing.
  5. Falls back to `host-XXX` if no info is found.

- Outputs to `/etc/hosts.generated`, compatible with `dnsmasq`.
- Designed for integration with **Tailscale subnet routers** and **Split DNS**.
- Fully automated — suitable for running via `cron`.

---

## 🛠 Prerequisites

Install the required tools:

```bash
sudo apt update
sudo apt install -y nmap arp-scan nbtscan avahi-utils dnsmasq
