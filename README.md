# filegator-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [FileGator](https://github.com/filegator/filegator), plus the packaging
> sources used to build it.

## What this is

A four-file TOS Docker application archive (`filegatordocker.tar.gz`) that
installs FileGator on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`,
  id `filegatordocker`)
- `filegatordocker.lang` — 23-language superset (TOS requires 14)
- `filegatordocker.svg` — application icon (2 SVG elements, no `filter`/`use`)
- `docker-compose.yml` — one service, image `filegator/filegator:v7.16.9`

Everything else in this repository is packaging source and documentation.

## Repository layout

```text
.
├── tosapp.json                  # packaging spec (version, image, ports, volumes…)
├── src/
│   ├── config.ini              # TOS metadata; @@VERSION@@ / @@PLATFORM@@ placeholders
│   ├── docker-compose.yml      # one service, non-root, fixed tag, healthcheck
│   ├── entrypoint.sh           # first-start seeding wrapper (embedded in the compose)
│   ├── filegatordocker.lang    # 23 locales, rendered from tosapp.json
│   └── filegatordocker.svg     # icon
├── scripts/
│   ├── build.sh                # package one architecture -> out/filegatordocker.tar.gz
│   └── build-dual.sh           # package x86_64 + aarch64 -> out/*_{x86_64,aarch64}.tar.gz
├── tools/verify.py             # review-standards self-check (hard gate)
├── test/install-and-verify.sh  # on-device check (optional, needs root)
├── README.md                   # this file
├── PRIVACY.md                  # privacy policy (also the package `help` target)
├── NOTICE.md                   # third-party components, image digest, licences
├── CHANGELOG.md                # package history, one entry per review round
└── LICENSE                     # MIT (this packaging)
```

## How it works

| | |
|---|---|
| Container image | `filegator/filegator:v7.16.9` (Docker Hub, official image, **unmodified**; only the container command is wrapped, see below) |
| Open | `http://<NAS-IP>:8063/` (host 8063 → container 8080) |
| Runs as | non-root, `user: "1000:1000"` (`www-data` is uid 33 in the image, so the package pins uid 1000 explicitly and the installer hands both volumes to it) |
| Persistent data | `/var/www/filegator/private` → `/Volume1/DockerAppData/filegatordocker/private`, `/var/www/filegator/repository` → `/Volume1/DockerAppData/filegatordocker/repository` |
| Health check | `curl -s -o /dev/null http://127.0.0.1:8080/` every 30 s, 30 s start period |
| Logs | `docker logs filegatordocker` (Apache access/error) and `.../private/logs/app.log` (login events) |

**Why the wrapper.** `private/` and `repository/` are bind mounts from the NAS,
so on a fresh install both are empty and the two files the image ships inside
`private/` (`users.json.blank` and `logs/`) are hidden by the mount. FileGator
then answers every page with `Folder not writable: /private/logs/` and its auth
adapter cannot copy the blank account file, so the file manager never opens.
`src/entrypoint.sh` creates `private/logs` (mode 700), `private/tmp` (mode 700)
and, only when `private/users.json` is missing, seeds the upstream default
accounts (`admin`/`admin123`, and `guest` with no password) with mode 660. It
then `exec`s the image's own `docker-php-entrypoint apache2-foreground`, so
nothing else about the image changes and an upgrade keeps the existing accounts
and log.

## What it actually does

Delivered functionality — exactly what the description in `config.ini` /
`tosapp.json` claims:

- browse folders and files in the browser, with breadcrumbs and search
- create folders and empty files; **upload** (1 MB chunks) and **download**
  single files or a multi-file selection as one zip
- rename, copy, move, delete, zip, unzip, change permissions, edit text files
- multi-user: `admin` / `user` / `guest` roles with a per-account home directory
  and permission flags (read, write, upload, download, batch download, zip,
  chmod); user management in the admin panel
- a built-in `guest` account with no permissions (delete it if you do not want
  anonymous browsing of `repository/`)

Not included, and deliberately **not** claimed in the description:

- no share links / public download links (FileGator 7.16.9 has no such feature)
- no S3 / WebDAV / SFTP storage adapter. The upstream image is hard-configured
  for local storage (`repository/`); switching the adapter means editing
  `configuration.php` **inside the container**, which is outside this package
- no database, no versioning, no thumbnails, no OCR

## Privacy

The full policy is [PRIVACY.md](PRIVACY.md) (also the `help` URL inside the
package). In short:

- everything stays on your NAS; the developer operates no server and receives
  nothing;
- **no** telemetry, analytics, crash reporting or update check;
- the only third-party request is the static logo your **browser** loads from
  `filegator.io`; §4.2 of the policy shows how to point it at the copy already
  inside the image so nothing leaves your network;
- accounts are bcrypt-hashed in `private/users.json`; login events (username,
  IP, result) go to `private/logs/app.log`;
- access / correction / deletion channels are in §5 of the policy.

## Notices and licences

See [NOTICE.md](NOTICE.md): upstream **FileGator 7.16.9 — MIT**, the image index
digest, base image (Debian 13.7 / PHP 8.3.36 / Apache 2.4.69), Composer and
browser-side dependencies, trademarks, and the MIT licence of this packaging
([LICENSE](LICENSE)).

## Build

```bash
scripts/build.sh                       # current tosapp.json version, x86_64
scripts/build.sh 7.16.9-3              # explicit version
scripts/build.sh 7.16.9-3 aarch64      # explicit platform
scripts/build-dual.sh 7.16.9-3         # both architectures + official -c on each
```

`build.sh` stages the four files, substitutes `@@VERSION@@` / `@@PLATFORM@@`,
strips CRLF/BOM/AppleDouble, runs `tools/verify.py` (archive layout, JSON
validity, required `config.ini` fields, 14+ languages, version consistency,
Docker-Hub-only image with a fixed tag, reserved/recommended host ports,
non-root user, per-service healthcheck/TZ/restart, data path below the
application data root, never the `/Volume*` wildcard, comment-free sequence
blocks, `x-app-meta` last, no literal secrets, SVG size/element limits) and then
packs the archive deterministically (GNU tar, uid/gid 0, zeroed mtime, gzip
without timestamp).

```bash
./TOSAppSelfTestingTool -c out/filegatordocker_x86_64.tar.gz   # official spec check
bash test/install-and-verify.sh                                # on-device E2E (needs root)
```

## Install, upgrade, data and uninstall

- **Install:** App Center → search “FileGator” → Install. The image is pulled
  from Docker Hub; TOS creates the two data folders and hands them to uid 1000.
- **First login:** `admin` / `admin123` — **change it immediately** (top-right
  menu → Change password). Until you do, anyone who can reach port 8063 is an
  administrator.
- **Upgrade:** install the newer version from App Center. `private/` and
  `repository/` are kept; users and files survive.
- **Backup:** copy `/Volume1/DockerAppData/filegatordocker/` (files, accounts,
  login log). There is no built-in export.
- **Uninstall:** App Center → Uninstall stops and removes the container and its
  image. The data folders are **kept** unless you tick “delete data”. To remove
  everything: stop the app and
  `rm -rf /Volume1/DockerAppData/filegatordocker/`. The Docker package has no
  uninstall hook, so nothing else is left behind.
- **Ports:** 8063 is the web port registered for this app. Other Store apps may
  use the same port; that is expected — install only one of them at a time.

## Supported architectures

| Platform | Status | Notes |
|---|---|---|
| `x86_64` | supported | the upstream image has a `linux/amd64` manifest |
| `aarch64` | **not supported** | `filegator/filegator:v7.16.9` is published for `linux/amd64` **only** — its OCI index `sha256:55bf48…` has no `linux/arm64` entry — so the container cannot start on aarch64 hardware. `scripts/build-dual.sh` still builds an aarch64 package for the day upstream publishes an arm64 image, but it is not submitted while the image is amd64-only. |

## Review remediation (round 3, `7.16.9-3`)

| Code | Item | Fix |
|---|---|---|
| C02 | `config.ini` had a duplicate `official` / `Official` key | duplicate removed; `official` → the real upstream repository |
| C3 / C4 | privacy policy missing / incomplete | `PRIVACY.md` added (data, retention, rights, security, third parties, deletion, contact); `help` points at it |
| C7 | user data rights channel | `PRIVACY.md` §5: access / correction / deletion with the exact paths and UI steps, plus the 30-day contact channel |
| C8 | third-party APIs not disclosed | `PRIVACY.md` §4 lists every endpoint, what is sent and where: Docker Hub pull, `filegator.io` logo (browser only), optional admin-configured storage backend, and “no telemetry / no update check” |
| C9 | description ≠ delivered functionality | description rewritten: no share links, no S3/WebDAV adapter, no claim of features 7.16.9 does not ship; `zh-cn` / `zh-hk` rewritten and all 23 locales re-rendered |
| C10 | repository / directory compliance | this README (layout, privacy, notices, build, data & uninstall), `PRIVACY.md`, `NOTICE.md`, `CHANGELOG.md`; repository is public |
| T1 | high/critical CVE in the image | upstream 7.16.9 is the latest stable 7.x (checked 2026-11-22); the image is pinned to that fixed tag; 8.x is a Go rewrite, RC-only and not a drop-in; see CHANGELOG for the tracking plan |
| F7 | web interface does not work correctly | two causes found and fixed: (a) on a fresh install the empty `private/` mount hides `users.json.blank` and `logs/`, so the page only rendered `Folder not writable` — `src/entrypoint.sh` now seeds them (see “Why the wrapper”); (b) the documented default password was wrong (`admin/admin`); it is `admin` / `admin123` and all texts were corrected |
| F1 | aarch64 installation failed | root cause = the amd64-only upstream image (above). aarch64 cannot be fixed without an upstream arm64 build; the broken aarch64 version is withdrawn instead of being resubmitted |

## Limitations

- The default `admin` / `admin123` login must be changed on first visit.
- The UI is plain HTTP; use a TLS reverse proxy or VPN before exposing it.
- Files are stored unencrypted; rely on TOS permissions / volume encryption.
- `aarch64` is not supported (see above).
- Uploads are chunked at 1 MB; PHP keeps `upload_max_filesize=2M` /
  `post_max_size=8M`, so a single non-chunked request above 8 MB is refused.
- The login page logo is loaded from `filegator.io` unless you replace it with
  the local copy (PRIVACY.md §4.2).

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
