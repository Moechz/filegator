# Privacy Policy — FileGator for TerraMaster TOS (`filegatordocker`)

**Last updated:** 22 November 2026
**Data controller / contact:** Moechz — moechz@163.com
**Applies to:** version `7.16.9-3` and later of the TOS application
`filegatordocker`, the container image it runs and this repository.

## 1. Summary

- FileGator runs **entirely on your NAS**. The developer does not receive,
  collect or have access to any file, filename, account or log of yours.
- There are **no developer-operated servers**, no telemetry, no analytics, no
  crash reporting and **no update check**.
- The application serves a web UI on your LAN and reads/writes files inside its
  own application data folder. Nothing is uploaded anywhere.
- Two network paths exist, and only these:
  1. **Docker Hub** — the container image is pulled from Docker Hub (or your
     registry mirror) when the application is installed or updated. No user data
     is sent; the request is an anonymous image download.
  2. **`filegator.io`** — the FileGator logo in the web UI is a static SVG that
     your **browser** loads from the upstream project's website (see §4.2).
     The NAS itself does not contact `filegator.io`.

## 2. What data is processed

| Data | Where it lives |
|---|---|
| **Files and folders you manage** — content, names, directory tree, sizes, timestamps, permissions | `/Volume1/DockerAppData/filegatordocker/repository/` on your NAS |
| **Accounts and ACL** — `users.json`: username, display name, role (`admin` / `user` / `guest`), home directory, permission bitmask (`read`, `write`, `upload`, `download`, `batchdownload`, `zip`, `chmod`), **bcrypt** password hash. No e-mail address, no phone number, no real name is asked for or stored | `/Volume1/DockerAppData/filegatordocker/private/users.json` |
| **Login log** — timestamp, username that was attempted, client IP address, success/failure, IP-lockout events | `/Volume1/DockerAppData/filegatordocker/private/logs/app.log` |
| **Temporary upload/archive data** — 1 MB upload chunks and zip staging files before they are moved into `repository/` | `/Volume1/DockerAppData/filegatordocker/private/tmp/` (garbage-collected after 2 days) |
| **Web session** — a random PHP session id in an `HttpOnly`, `SameSite=Lax` cookie; the session data itself lives in the container's ephemeral filesystem | your browser (cookie) and the container (lost on restart) |
| **Apache access/error log** — client IP, request line, status code, user agent | the Docker daemon: `docker logs filegatordocker` (rotated by Docker, not by the app) |
| **No database** | — |

No usage statistics, no file-content scanning, no thumbnailing service and no
external index are involved. The application does not read any file outside its
two mounted folders.

**Credentials:** the account passwords are stored only as **bcrypt hashes**
(`$2y$…`, cost 10) inside `users.json`. They are never written to the log and
never leave the NAS. The default `admin` / `admin123` account that this package
seeds on first start must be changed immediately (see §6).

## 3. Retention period

- **Files and folders:** kept until **you** delete them. No automatic expiry, no
  versioning, no copy anywhere else.
- **Accounts / ACL (`users.json`):** kept until you delete the user in the admin
  panel or remove the data folder.
- **Login log (`private/logs/app.log`):** appended for as long as the app is
  installed; there is no size or age based rotation. Delete the file (or empty
  it) to remove the history — the app recreates it on the next request.
- **Temporary upload/zip data (`private/tmp/`):** the app garbage-collects
  entries older than **2 days** (checked on ~10 % of requests); leftovers are
  removed with the data folder.
- **Sessions:** deleted when the container stops; the cookie expires with the
  browser session.
- **`docker logs`:** kept by the Docker daemon according to its own rotation
  configuration (`/etc/docker/daemon.json` on the NAS).
- **Uninstalling:** stops and removes the container. The two data folders are
  **kept** unless you tick “delete data” in App Center. To delete everything
  yourself, stop the app and remove
  `/Volume1/DockerAppData/filegatordocker/`.

## 4. Network connections and third parties

### 4.1 Complete list

| Destination | When | Data sent | Region |
|---|---|---|---|
| `registry-1.docker.io` / `docker.io` (Docker Hub) or your configured registry mirror | install and every app update only | anonymous image-pull request (image name, tag, your IP) — **no file, account or log data** | wherever Docker Hub / your mirror is hosted |
| `filegator.io` (upstream project website) | every time the web UI page is rendered, by **your browser**, not by the container | one `GET` for `filegator_logo.svg`; the host sees your browser's IP address, user agent and the `Referer` (the NAS URL) | upstream project hosting (see §4.2) |
| **Your own** S3 / S3-compatible, WebDAV or SFTP backend | **never by default.** Only if an administrator edits the container configuration to add such an adapter (not enabled and not documented as a feature of this package) | whatever storage credentials/traffic that adapter implies, to a server **you** choose | your provider |
| `terra-master.com` | only if you use App Center features outside the app | handled by TOS itself, not by this application | TerraMaster |
| The developer's servers | **never** | none | — |

There is **no** telemetry, **no** crash/analytics SDK, **no** advertising, **no**
remote-font or JavaScript CDN, and **no** automatic update check. All HTML, CSS,
JavaScript and icon fonts are served from the container image itself.

### 4.2 The `filegator.io` logo request

`configuration.php` in the upstream image sets
`frontend_config.logo = https://filegator.io/filegator_logo.svg`, so the login
page and the header show a logo loaded from the upstream project website. Only
your browser contacts that host; the request carries no file list, filename,
account name or password.

If you do not want that request, either block `filegator.io` in your DNS
resolver / browser, or point the logo at the copy that already ships inside the
image:

```bash
sudo docker exec -u 1000 filegatordocker \
  sed -i 's#https://filegator.io/filegator_logo.svg#img/logo.svg#' \
  /var/www/filegator/configuration.php
sudo docker restart filegatordocker
```

After that, the app makes **no** third-party request at all; it only talks to
your browser on port 8063.

### 4.3 Sharing

The developer does not share, sell or transfer your data — it never reaches the
developer. If you install the app behind your own reverse proxy, VPN or tunnel,
that component is outside this package and its own privacy terms apply. Anyone
you give a NAS account (or your NAS login) can see the files that account's role
and permissions allow — that is ordinary file-manager access, not a data
transfer to a third party.

## 5. Your rights (access, correction, deletion)

Because all data stays on your NAS, you exercise these rights directly, without
asking the developer:

- **Access / portability.** Open the web UI and browse or download any file the
  account may read; `users.json` and `app.log` are plain files in
  `/Volume1/DockerAppData/filegatordocker/private/` that you can read with an
  administrator session on the NAS. There is nothing to request from the
  developer, because the developer holds no copy.
- **Correction.** Rename/move/edit files in the web UI;
  **Admin → Users** to change a display name, role, home directory or
  permissions, and **Change password** (or `users.json`) for credentials.
- **Deletion / erasure.** Delete files or users in the web UI; remove
  `private/logs/app.log` to erase the login history; stop the app and delete
  `/Volume1/DockerAppData/filegatordocker/` to remove everything at once.
  Uninstalling with “delete data” in App Center does the same.
- **Restriction / objection.** Do not publish port 8063 to the internet, block
  `filegator.io` (§4.2), or remove accounts you no longer want to have access.
- **Complaint.** Contact the developer at the address below. Packaging-level
  privacy questions are answered within **30 days**; there is no developer-side
  account to close and no developer-held data to export.

## 6. Security measures

- The container runs as **uid 1000**, never as root; no `privileged` mode, no
  host network, no `cap_add`, no Docker socket, `restart: unless-stopped`.
- Only one port is published (**8063 → 8080**); the app is reachable on your LAN.
- The image is the **official upstream Docker Hub image**, pinned to the fixed
  tag `filegator/filegator:v7.16.9` (never `:latest`), index digest
  `sha256:55bf48495e371370c30bb29a32b2ca3ed9382596bae6c691f29c7e3b6c61ea4b`.
- Passwords are stored as **bcrypt** hashes; the login endpoint applies a
  **5-attempt / 15-minute IP lockout** (`lockout_attempts` / `lockout_timeout`).
- CSRF protection is enabled and the session cookie is `HttpOnly` with
  `SameSite=Lax`.
- **Change the default `admin` / `admin123` password on the first login** — that
  is the upstream default account this package seeds on first start. Until you
  change it, anyone who can reach port 8063 can log in as administrator.
- The web UI is served over **plain HTTP** and the cookie is not marked
  `Secure`, because the package does not ship a TLS certificate. On an untrusted
  network, put the app behind a VPN or a reverse proxy with TLS, and do not
  expose port 8063 to the internet.
- Files are stored **unencrypted** on the NAS and protected by TOS file
  permissions. Use an encrypted volume if that matters to you.
- Back up `/Volume1/DockerAppData/filegatordocker/` before uninstalling with
  data removal; there is no built-in backup.

## 7. File uploads and limits

Uploads are sent in **1 MB chunks** (the UI advertises a 100 MB per-file limit).
The image's PHP configuration keeps the standard `upload_max_filesize = 2M` /
`post_max_size = 8M`, which is sufficient for the 1 MB chunks but means a single
non-chunked POST larger than 8 MB is refused. Very large files are therefore
limited by the client chunking, not by a quota in this package; no upload is
scanned, transformed or sent anywhere.

## 8. Children

FileGator is a general-purpose file manager and is not directed at children. No
age or identity data is collected.

## 9. Changes to this policy

Material changes are recorded in `CHANGELOG.md` and in this file's “Last
updated” date. The current version is always available at
<https://github.com/Moechz/filegator/blob/main/PRIVACY.md>, which is also the
URL in the package `help` field (`config.ini` / `tosapp.json`).

## 10. Contact

Moechz — **moechz@163.com** — <https://www.moechz.com/>
