# Changelog

All notable user-visible changes to the FileGator TOS application package.

## 7.16.9-3 — 2026-11-22

Remediation of the App Center listing review for `7.16.9-2` (aarch64 on-hold).
Package iteration only: the upstream image stays `filegator/filegator:v7.16.9`
(unmodified), the port stays 8063, the data paths are unchanged.

### Fixed (compliance)

- **C02** — `src/config.ini` carried a duplicated key: `official` **and**
  `Official`, both pointing at the upstream repository. The redundant
  `Official` key is removed; `official` points at the real upstream project
  (`https://github.com/filegator/filegator`).
- **C3 / C4** — added `PRIVACY.md` (10 sections): what is stored and where,
  retention for every data class, third-party endpoints, user rights, security
  measures, deletion channels, contact. `config.ini.help` and `tosapp.json.help`
  now point at the public policy URL instead of the issue tracker.
- **C7** — `PRIVACY.md` §5 documents the access / correction / deletion channel
  with concrete paths (`DockerAppData/filegatordocker/…`), the admin-panel steps
  and a 30-day contact route.
- **C8** — `PRIVACY.md` §4 is a complete disclosure table: Docker Hub image pull
  (install/update only), `filegator.io` logo (browser-side, static SVG, no app
  data), and the optional admin-edited storage backend. It also states
  explicitly that there is **no telemetry, no analytics and no update check**,
  and gives a one-line command to replace the external logo with the copy that
  already ships inside the image.
- **C9** — the description no longer claims features 7.16.9 does not deliver:
  share links / password-protected links and the S3/WebDAV adapters are removed
  from the text (the image is hard-configured for local storage). `zh-cn` and
  `zh-hk` were rewritten (not the generic text found in earlier packages) and
  all 23 locales were re-rendered from `tosapp.json`.
- **C10** — `README.md` rewritten with Repository layout, Features, Privacy,
  Notices, Build, Install/upgrade/backup, Data and uninstall, Supported
  architectures and a review-remediation table; `NOTICE.md` added with the
  upstream licence (MIT, verified in the image), the image index digest and the
  component inventory. Repository is public.
- **T1** — upstream check on 2026-11-22: `7.16.9` is the latest **stable** 7.x
  release (2026-11-04); the 8.x line is a Go rewrite and is still
  `v8.0.0-rc5`/pre-release, so it is not a drop-in upgrade. The package keeps
  the latest stable tag and stays on the official image. Tracking plan: move to
  the next stable upstream release (7.16.x or 8.x GA) as soon as it is
  published, and re-scan then; the image is never replaced by a local build, so
  every CVE fix arrives through upstream.

### Fixed (runtime)

- **F7 (aarch64 and x86_64: the web interface did not open)** — two causes,
  both fixed:
  1. **First-start data folders.** `private/` is a bind mount from the NAS, so on
     a fresh install it is empty and the two files the image ships inside it
     (`users.json.blank` and `logs/`) are hidden by the mount. FileGator then
     answered every page with `Folder not writable: /private/logs/` (HTTP 200,
     36 bytes) and could not create `users.json`, so there was no account to log
     in with either. Reproduced locally with an empty data folder, then fixed by
     the new `src/entrypoint.sh`: it creates `private/logs` and `private/tmp`,
     seeds the default `users.json` only when it is missing, and `exec`s the
     image's own `docker-php-entrypoint apache2-foreground`. The image itself is
     untouched; existing accounts, files and the log are preserved on upgrade.
     Verified: empty folder → HTTP 200 with the real 653-byte app page,
     `POST ?r=/login` with `admin` / `admin123` → 200 and `/getuser` returns
     `role: admin`.
  2. **Wrong default password in the texts.** The package documented
     `admin/admin`, but FileGator 7.16.9's default is **`admin` / `admin123`**
     (upstream README and `password_verify()` against the seeded hash both
     confirm). `important`, README, PRIVACY and the wrapper message are fixed.
- **F1 (aarch64 installation failed)** — root cause: `filegator/filegator:v7.16.9`
  is published for **`linux/amd64` only**. Its OCI index
  `sha256:55bf48495e371370c30bb29a32b2ca3ed9382596bae6c691f29c7e3b6c61ea4b`
  contains one `linux/amd64` manifest plus the build attestation and **no
  `linux/arm64`** entry, so on aarch64 the pull cannot resolve and the container
  never starts. The published `7.16.9-2` aarch64 archive was checked and is
  correct (`platform=aarch64`, hash matches the platform record), so this is an
  upstream image limitation, not a packaging defect. `7.16.9-3` is therefore
  submitted for **x86_64**; the broken aarch64 version is withdrawn instead of
  being resubmitted, and `README.md` documents the limitation. An aarch64 package
  is still produced by `build-dual.sh` so it can be submitted as soon as upstream
  publishes an arm64 image.
- **S11 (file permissions)** — the service already pins `user: "1000:1000"` and
  runs no root process; in addition the wrapper now creates `private/logs` and
  `private/tmp` with mode **700** and `private/users.json` with mode **660**, so
  the login log (usernames + client IPs) and the bcrypt hashes are not world
  readable on the NAS. The container image is untouched.
- **S3 (host network detected)** — not reproducible: the compose file publishes
  port 8063 explicitly and contains no `network_mode`, `privileged`, `cap_add`,
  `pid` or `ipc` key (also enforced by `tools/verify.py`). Recorded as a detector
  false positive.

### Changed

- `tosapp.json`: `probe` block removed (stale probe output that claimed a
  single `x86_64` architecture and a trial port), `descript` / `important` /
  `release_note` rewritten, translations for `zh-cn` / `zh-hk` rewritten,
  `data_notes` / `design_notes` / `limitations` updated to the real storage
  layout.
- `src/filegatordocker.lang`: all 23 locales re-rendered.

## 7.16.9-2 — 2026-11-15

Packaging iteration that was submitted to the App Center and reviewed
(x86_64 approved, aarch64 put on hold). No source change was committed for this
iteration; the archive differs from `7.16.9-1` only in the version placeholder.

## 7.16.9-1 — 2026-11-14

### Added
- First release. FileGator (`filegator/filegator:v7.16.9`, Docker Hub official
  image, unmodified) packaged as a TOS 7 Docker application, published on port
  8063 and running as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/filegatordocker/`.
