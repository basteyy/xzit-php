# xzit-php

[![GitHub release](https://img.shields.io/github/release/basteyy/xzit-php.svg)](https://github.com/basteyy/xzit-php/releases)
[![License: CC0-1.0](https://img.shields.io/badge/License-CC0_1.0-lightgrey.svg)](https://creativecommons.org/publicdomain/zero/1.0/)


`xzit-php` lets you install and manage **multiple PHP-FPM versions** in parallel on Ubuntu (via the Sury PPA).  
It automatically installs FPM, a smart default module set, manages individual FPM pools, and cleanly uninstalls versions.

## Setup

### Installation via `setup.sh`

```bash
git clone git@github.com:basteyy/xzit-php.git
cd xzit-php
sudo ./setup.sh --with-ppa
```

or directly:

```bash
curl -sSL https://raw.githubusercontent.com/basteyy/xzit-php/refs/heads/dev/setup.sh | sudo bash -s -- --with-ppa
```

Options:
- `--with-ppa` – immediately adds Sury PPA
- `--no-ppa` – skips adding PPA (default: auto-detect)
- `--bin-dir /usr/local/bin` – target install dir (default)
- `--from ./xzit-php` – path to script if located elsewhere

## Documentation

### Features

| Command | Description |
|----------|-------------|
| `xzit-php install <version>` | Installs PHP-FPM for a specific version (e.g., 8.2) with useful default modules. |
| `xzit-php install --all` | Installs all supported versions (5.6 – 8.5). |
| `xzit-php uninstall <version>` | Uninstalls the given PHP version. |
| `xzit-php uninstall --all` | Removes all installed PHP versions. |
| `xzit-php pool add --n <name> --v <version>` | Creates a new FPM pool for the given PHP version. |
| `xzit-php pool remove --n <name>` | Removes a pool across all PHP versions. |
| `xzit-php pool change --n <name> --v <version>` | Migrates an existing pool from its current PHP version to another. |
| `xzit-php module <name>` | Installs a PHP module for all installed versions. |
| `xzit-php module <name> --v <version>` | Installs a module for a specific version. |
| `xzit-php module <name> --rm` | Removes a module from all versions. |
| `xzit-php module <name> --rm --v <version>` | Removes a module from a specific PHP version. |
| `xzit-php list versions` | Lists all installed PHP-FPM versions. |
| `xzit-php list pools` | Lists all existing pools across all PHP versions. |
| `xzit-php list pools --v <version>` | Lists all pools for a specific PHP version. |

## Typical Usage

```bash
xzit-php install 8.2
xzit-php install --all
xzit-php pool add --n blog --v 8.2
xzit-php pool change --n blog --v 8.3
xzit-php pool remove --n blog
xzit-php module redis
xzit-php module xdebug --v 8.2
xzit-php list versions
xzit-php list pools --v 8.2
```

## Default Module Set

When installing a version, the following modules are included (if available):

```
common cli fpm mysql xml curl mbstring intl bcmath gd zip opcache memcached
```

Additionally, these are installed if present:
```
imagick redis xdebug php-pear
```

Each module is installed as a **versioned package** (`php8.2-redis`) if possible, otherwise it falls back to `php-redis`.

## Pool Template

When creating a new pool (`pool add`), a default configuration is generated:

```ini
[<name>]
user=www-data
group=www-data
listen=/run/php/php<version>-<name>.sock
listen.owner=www-data
listen.group=www-data
pm=dynamic
pm.max_children=16
pm.start_servers=4
pm.min_spare_servers=2
pm.max_spare_servers=6
php_admin_value[error_log] = /var/log/php<version>-fpm.<name>.log
php_admin_flag[log_errors] = on
request_terminate_timeout = 120s
```

Sockets and log paths are automatically adjusted per PHP version.

## Pool Migration (pool change)

Move an existing pool to another PHP version:

```bash
xzit-php pool change --n shop --v 8.3
```

The tool:
- finds the current PHP version hosting the pool
- verifies target version is installed
- copies the pool file to `/etc/php/<new>/fpm/pool.d/`
- updates listen socket and log file paths
- reloads both FPM services

## Contribution Guide

Thank you for your interest in contributing to the xzit-php project! I welcome contributions from the community to help improve and expand this project. As long as the project is that small, just clone the repository, make your changes, and submit a pull request.

## License
This project is licensed under the CC0 1.0 Universal (CC0 1.0) Public Domain Dedication. For more information, please refer to the [LICENSE](LICENSE) file.
