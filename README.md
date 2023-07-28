# OpenConnect remote minimal

A template for creating a vpn development container.

It can be used to:

- proxy traffic via a vpn
- used as remote development container with visual studio code
- run docker in docker

> **_NOTE:_**
> See [OpenConnect container minimal](https://github.com/chdalski/openconnect-container-minimal) for a version suitable for [Development Containers](https://containers.dev/).

## Prerequisites

- copy company.cer, user.key and user.pem into `certs` directory
- create `.vpn-env` file (copy sample) and fill out the missing values

## Build devcontainer

```shell
docker compose build
```

## Start the devcontainer (automatically connects to vpn)

```shell
docker compose up -d
```

## Attach vscode

- Open a new vscode window
- Attach vscode to the running container by either
  - Selecting "Open Remote Window" (blue icon in the left down corner) -> "Attach to running container"
  - Pressing `Crtl + Shift + P` (linux) or `Cmd + Shift + P` (mac) -> "Dev Containers: Attach to running container"

## Using the Proxy locally

The Proxy is forwarded to `localhost:3128` and currently configured to allow http and https connections (see [squid.conf](vpn/squid.conf)).
Use [Foxy Proxy](https://getfoxyproxy.org/help/browsers/) or similar tools in your browser to access it.
