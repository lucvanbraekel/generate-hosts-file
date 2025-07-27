Certainly! Here's the **README.md** content in proper **Markdown format**, without interactive copy/edit tags. You can copy-paste this directly into a `README.md` file for your GitHub repository:

```markdown
# generate-hosts-file

This project provides a Bash script (`generate-hosts-file.sh`) that generates a local hosts file with meaningful hostnames for all devices on a LAN. It is designed to complement **Tailscale in subnet routing mode**, by enabling local DNS resolution for devices that are *not* part of the Tailscale mesh but are reachable through a Tailscale subnet router.

## Why Use This?

Tailscale enables secure remote access to LANs using subnet routers. However, it does not automatically assign hostnames to non-Tailscale LAN devices. This script solves that problem by:

- Scanning the local subnet for active devices.
- Attempting to resolve their hostnames using the following priority:
  1. **Nmap reverse DNS**
  2. **NetBIOS** (via `nbtscan`)
  3. **Multicast DNS (mDNS)** using `avahi-resolve-address`
  4. **Vendor name** (from MAC address)
  5. **Fallback name** in the form `host-XXX`, where `XXX` is the last octet of the IP address

The result is a file called `/etc/hosts.generated` containing entries like:

```

192.168.1.88     nucbox\_k8plus
192.168.1.210    netgear-210
192.168.1.233    pop-os

````

These names can then be used for DNS resolution from other Tailscale nodes, if `dnsmasq` is configured to load this file.

## Prerequisites

This script requires the following packages:

- `nmap`
- `arp-scan`
- `nbtscan`
- `avahi-utils`
- `dnsmasq`

To install them on Ubuntu:

```bash
sudo apt update
sudo apt install -y nmap arp-scan nbtscan avahi-utils dnsmasq
````

### Disabling systemd-resolved

On Ubuntu, the systemd-resolved service must be disabled to avoid DNS conflicts:

```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

Then enable and start `dnsmasq`:

```bash
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq
```

> ⚠️ We do **not** modify `/etc/hosts` directly. Instead, we generate a separate `/etc/hosts.generated` file.
> This avoids security and integrity risks of overwriting system-managed files.
> Also, `systemd-resolved` does **not** support `addn-hosts`, so `dnsmasq` is used instead.

## Installation

To automate the setup, use the included `install.sh` script:

```bash
sudo ./install.sh
```

This will:

* Install required packages

* Disable systemd-resolved

* Enable and configure `dnsmasq`

* Append the following line to `/etc/dnsmasq.conf` if not already present:

  ```
  addn-hosts=/etc/hosts.generated
  ```

* Create a cron job that runs `generate-hosts-file.sh` every 10 minutes

## Integration with Tailscale

When using subnet routers, Tailscale allows you to specify a custom DNS server in the admin dashboard.

This setup works as follows:

1. A Tailscale subnet router runs `dnsmasq`, configured to load `/etc/hosts.generated`.
2. Tailscale clients are configured to use this router as their DNS server.
3. Devices on the subnet become addressable from remote Tailscale nodes by hostname.

Alternatively, you could use `systemd-resolved` and overwrite `/etc/hosts`, but that is discouraged due to the risks and limitations mentioned above.

## Compatibility

This README and installation script are tailored for **Ubuntu 22.04 and 24.04**, particularly with minimal installations.
Contributions and documentation for other environments (Debian, Arch, Fedora, Alpine, etc.) are welcome!

## License

MIT License

## Contributions

Pull requests, bug reports, and improvements to logic, compatibility, and documentation are always appreciated.

```

Let me know if you'd also like:

- A `LICENSE` file (MIT)
- A `.gitignore`
- A GitHub Actions workflow
- A sample `crontab` snippet

Or if you want to convert this into a web-friendly version for GitHub Pages.
```
