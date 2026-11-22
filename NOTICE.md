# NOTICE — third-party components and attributions

This package (`filegatordocker`, TOS 7 Docker application, version `7.16.9-3`)
is an independent packaging by Moechz of the upstream **FileGator** project.
Nothing in this repository changes the upstream licences.

## 1. Upstream application — FileGator

- Project: <https://github.com/filegator/filegator>
- Upstream version: **7.16.9** (release `v7.16.9`, 2026-11-04)
- Author / brand: **FileGator**, Milos Stojanovic and contributors
- Licence: **MIT** — <https://github.com/filegator/filegator/blob/master/LICENSE>
  (`Copyright (c) 2019-2021 Milos Stojanovic and Contributors`). Verified against
  the `LICENSE` file inside the image, not against the repository metadata.
- Relationship: the upstream application is used **unmodified**, inside the
  official container image. No upstream source code is redistributed by this
  repository or by the package archive; the image is pulled from Docker Hub at
  install time.

## 2. Container image — `filegator/filegator:v7.16.9`

- Registry: Docker Hub — `docker.io/filegator/filegator:v7.16.9`
- Source: the **official upstream image** published by the FileGator project,
  built 2026-11-04 (`v7.16.9`).
- OCI image index digest:
  `sha256:55bf48495e371370c30bb29a32b2ca3ed9382596bae6c691f29c7e3b6c61ea4b`
  - `linux/amd64` manifest:
    `sha256:fba98e60cbd88fcd1f159efe5ee8f8c1e50d05e565c8de3f03cc0c575fb275c2`
  - plus the build-attestation manifest (`unknown/unknown`)
- **The `v7.16.9` image is published for `linux/amd64` only.** It has **no
  `linux/arm64` manifest**, so this application cannot run on aarch64 hardware;
  this is a limitation of the upstream image, not of the package. See
  `README.md` → “Supported architectures” and `CHANGELOG.md` → `7.16.9-3`.
- The tag is fixed and immutable in practice (a release tag, never `:latest`).
- The image is pulled from Docker Hub at install time and is **not**
  redistributed in this repository or in the package archive.

## 3. Components inside the image (not redistributed here)

- Base OS: **Debian 13.7** (`trixie`) — Debian licences apply to the base
  packages (OpenSSL, zlib, libxml2, curl, etc.); each package keeps its own
  copyright file under `/usr/share/doc/<pkg>/copyright` inside the image.
- Runtime: **PHP 8.3.36** (PHP License 3.01) with Apache **2.4.69**
  (Apache License 2.0), `mod_php`, OPcache.
- PHP extensions present: `ctype curl date dom fileinfo filter hash iconv json
  ldap mbstring mysqli mysqlnd openssl pcre PDO pdo_sqlite Phar posix random
  readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer
  xml xmlreader xmlwriter zip zlib`.
- PHP dependencies installed by upstream through Composer (inside
  `/var/www/filegator/vendor`, each with its own licence): `league/flysystem` 1.x
  (MIT), `symfony/*` 4.4–5.x components (MIT), `monolog/monolog` (MIT),
  `php-di/php-di` (MIT), `aws/aws-sdk-php` + `guzzlehttp/guzzle` (Apache-2.0 /
  MIT, present for the optional S3 adapter), `phpseclib/phpseclib` (MIT, optional
  SFTP adapter), `nikic/php-parser`, `dibi/dibi`, `rakit/validation`.
  Development-only packages (`phpunit`, `php-cs-fixer`, `phpstan`) are also
  present in the image because upstream ships the full build tree; they are not
  executed by this packaging.
- Browser-side libraries bundled in `/var/www/filegator/dist` (Vue 2, Vuex,
  vue-router, Bootstrap-Vue, Font Awesome Free, moment.js, lodash, clipboard.js,
  axios): MIT / SIL OFL 1.1 / CC BY 4.0 as declared by each project. They are
  served locally by the container — no CDN is used.

The notices above are informational: this repository redistributes **none** of
these components. Obtain the authoritative licence text from the image or from
each upstream project.

## 4. The application data this package adds

Only packaging files are authored here: `docker-compose.yml`, `config.ini`,
`filegatordocker.lang`, `filegatordocker.svg`, `tosapp.json`, the build scripts
under `scripts/`, the checker in `tools/verify.py`, the test helper under
`test/`, and the documentation (`README.md`, `PRIVACY.md`, `NOTICE.md`,
`CHANGELOG.md`, `LICENSE`). They are released under **MIT** (see `LICENSE`).

## 5. Trademarks and branding

“FileGator” and the FileGator logo are trademarks or brand names of the upstream
project and its author. “TerraMaster”, “TOS” and “App Center” are trademarks or
registered trademarks of TerraMaster. Their use in this repository is
**descriptive only** (to identify the upstream project and the target platform).

This package is an independent community submission by Moechz. It is **not
affiliated with, sponsored or endorsed by** the FileGator project or
TerraMaster.

The icon in `src/filegatordocker.svg` is a generic rounded tile with a folder
glyph, drawn for this package. It does not reproduce the upstream FileGator
logo.

## 6. No warranty

The packaging is provided “as is”, without warranty of any kind. The upstream
MIT terms apply to the application itself; the Debian, PHP, Apache and Composer
licences apply to the components inside the image.

## 7. Contact

Moechz — moechz@163.com — <https://www.moechz.com/>
