# proxmox-backup-arm64

[![Build]][build_url]
[![Version]][release_url]
[![Size]][release_url]

Script for building Proxmox Backup Server **4.x** for ARM64.

## Download pre-built packages
You can find unoffical Debian packages that are created with this script in the  [Releases](https://github.com/qemus/proxmox-backup-arm64/releases) section.

With the script you can also download or install all packages of the latest release automatically.

**Download and install**

 `./build.sh install` or a specific version `./build.sh install=4.2.5`

**Download only**

`./build.sh download` or a specific version `./build.sh download=4.2.5`

For an even easier experience, you can also use the [Backup Server Docker container](https://github.com/dockur/proxmox-backup), which is built on top of these same packages.

## Build manually

### Install build essentials and dependencies
```bash
apt-get install -y --no-install-recommends \
	build-essential curl ca-certificates sudo git lintian fakeroot \
	pkg-config libudev-dev libssl-dev libapt-pkg-dev libclang-dev \
	libpam0g-dev zlib1g-dev nettle-dev
```
### Install ``rustup``
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -sSf | sh -s
source ~/.cargo/env
```

### Start build script
```bash
./build.sh 
```
or
```bash
./build.sh client (build only proxmox-backup-client package)
```

The compilation can take several hours.<br />
After that you can find the finished packages in the folder packages/

## Build using Docker
You can build ARM64 .deb packages using the provided Dockerfile and docker buildx:

```bash
docker buildx build -o packages --platform linux/arm64 .
```

You can also set build arguments for base image and build.sh options:

```bash
docker buildx build -o packages --build-arg buildoptions="client debug" --build-arg baseimage=ubuntu:jammy --platform linux/arm64 .
```

Once the Docker build is completed, packages will be copied from the docker build image to a folder named `packages` in the root folder.

## Build using cross compiler
### Enable multi arch and install build essentials and dependencies
For cross compiling you need to enable multiarch and install the needed build dependencies for the target architecture. For the tests to work qemu-user-binfmt is needed.

```bash
dpkg --add-architecture arm64
```

```bash
apt update && apt-get install -y --no-install-recommends \
                build-essential crossbuild-essential-arm64 curl ca-certificates sudo git lintian \
                pkg-config libudev-dev:arm64 libssl-dev:arm64 libapt-pkg-dev:arm64 apt:amd64 \
                libclang-dev libpam0g-dev:arm64 pkgconf:arm64 zlib1g-dev:arm64 \
                qemu-user-binfmt 
```
(apt:amd64 is necessary because libapt-pkg-dev:arm64 would break the dependencies without it)

### Install ``rustup`` and add target arch
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -sSf | sh -s
source ~/.cargo/env
rustup target add aarch64-unknown-linux-gnu
```

### Start build script
```bash
./build.sh cross
```

## Install all needed packages
### Server

```bash
cd packages
sudo apt install $(printf '%s\n' ./*.deb | grep -v 'static')
```

### Client
```bash
sudo apt install \
  ./packages/proxmox-backup-client_*_arm64.deb \
  # Optional: ./packages/proxmox-backup-file-restore_*_arm64.deb
```

## Help section
### Debugging
you can add the debug option to redirect the complete build process output also to a file (build.log)

```bash
./build.sh debug
```

### Console commands

to see PBS users:

```bash
proxmox-backup-manager user list
```

to update root user pwd:

```bash
proxmox-backup-manager user update root@pam --password {pwd}
```

more info: https://pbs.proxmox.com/docs/user-management.html

## Acknowledgements

Special thanks to [wofferl](https://github.com/wofferl), this project would not exist without his invaluable work.

## Stars 🌟
[![Stargazers](https://raw.githubusercontent.com/star-stats/stars/refs/heads/data/charts/qemus-proxmox-backup-arm64.svg)](https://github.com/qemus/proxmox-backup-arm64/stargazers)

## Disclaimer ⚖️

*The product names, logos, brands, and other trademarks referred to within this project are the property of their respective trademark holders. This project is not affiliated, sponsored, or endorsed by Proxmox Server Solutions GmbH.*

[build_url]: https://github.com/qemus/proxmox-backup-arm64/
[release_url]: https://github.com/qemus/proxmox-backup-arm64/releases/

[Build]: https://github.com/qemus/proxmox-backup-arm64/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/badge/size-32.8_MB-steelblue?style=flat&color=066da5
[Version]: https://img.shields.io/github/v/tag/qemus/proxmox-backup-arm64?label=version&sort=semver&color=066da5
