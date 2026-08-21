# `sane-mac80211` - Debian Package for Kernel Module

This repository provides a Debian package (`sane-mac80211`) that installs a custom kernel module for improved 802.11 management frame handling, particularly useful for certain wireless adapters.

The package is built using GitHub Actions and deployed to a GitHub Pages-hosted APT repository, making it easy to install on Debian/Ubuntu systems.


## Installation

### 1. Add the APT Repository

Add the repository to your system's sources list:

```
echo "deb https://cmahnke.github.io/sane-mac80211/repo-dist/ ./" | sudo tee /etc/apt/sources.list.d/sane-mac80211.list
```

### 2. Import the GPG Public Key

Import the repository signing key to verify package integrity:

```
curl -fsSL https://cmahnke.github.io/sane-mac80211/repo-dist/public.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sane-mac80211.gpg
```

### 3. Update Package Index

```
sudo apt update
```

### 4. Install the Package

```
sudo apt install sane-mac80211
```

The package will automatically:
- Register the module with DKMS
- Build and install it for your current kernel
- Load it at boot (if needed)

## Manual Usage (Optional)

If you need to manage the module manually:

```
# Build the module for current kernel
sudo dkms build -m sane-mac80211 -v 1.0

# Install the module
sudo dkms install -m sane-mac80211 -v 1.0

# Remove the module (e.g., during upgrades)
sudo dkms remove -m sane-mac80211 -v 1.0 --all
```

## How It Works (Behind the Scenes)

This project uses GitHub Actions to:

1. Test the build in a Docker container
2. Build a Debian package (`*.deb`) with proper metadata and post-install scripts
3. Sign the APT repository with GPG
4. Deploy the package and repository to GitHub Pages

The result is a secure, versioned, and easily installable APT package.

## Security

- All packages are GPG-signed
- The signing key is stored securely in GitHub Secrets (`GPG_PRIVATE_KEY`, `GPG_PUBLIC_KEY`)
- The repository is hosted on GitHub Pages, which supports HTTPS and is trusted by default

Never expose your private key. The CI workflow uses encrypted secrets.

## Repository Structure

```
.
├── Dockerfile               # Build environment for testing
├── DEBIAN/                  # Debian control files
│   ├── control
│   ├── postinst
│   └── prerm
├── dkms.conf                # DKMS configuration
├── Makefile                 # Build rules
├── patch-mlme.patch         # Kernel patch
├── .github/workflows/       # CI/CD workflow
│   └── build.yml
└── README.md                # This file
```

## Quick Install Summary

```
echo "deb https://cmahnke.github.io/sane-mac80211/repo-dist/ ./" | sudo tee /etc/apt/sources.list.d/sane-mac80211.list
curl -fsSL https://cmahnke.github.io/sane-mac80211/repo-dist/public.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sane-mac80211.gpg
sudo apt update && sudo apt install sane-mac80211
```

Now you're ready to use `sane-mac80211` on your Debian/Ubuntu system.
