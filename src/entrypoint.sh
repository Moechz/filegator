#!/bin/sh
# FileGator for TOS - first-start seeding wrapper.
#
# FileGator keeps its accounts in private/users.json and its log in
# private/logs/app.log, and both directories are bind-mounted from the NAS data
# folder. On a fresh install those mounts are *empty*, which hides the two files
# the image ships inside private/ (users.json.blank and logs/.gitignore) and the
# application cannot boot:
#
#   Folder not writable: /private/logs/
#   Warning: copy(/var/www/filegator/private/users.json.blank): Failed to open stream
#
# The web page therefore answers with that message instead of the file manager.
# This wrapper creates the missing folders and seeds the default account file
# once, keeps everything on later starts (so users, ACLs and the log survive an
# update), then hands over to the image's own entrypoint and Apache.
#
# The seeded accounts are the upstream defaults: admin/admin123 (role admin) and
# guest with no password and no permissions. The admin password must be changed
# on the first login; PRIVACY.md and README.md say so as well.
set -u

PRIVATE=/var/www/filegator/private

# The installer creates the mount points for uid 1000; make sure they exist when
# the container is started by hand.
mkdir -p "$PRIVATE/logs" "$PRIVATE/tmp" /var/www/filegator/repository

# Key material stays owner-only: login events (usernames + client IPs) must not be
# world readable on the NAS, and neither must the bcrypt hashes.
chmod 700 "$PRIVATE/logs" "$PRIVATE/tmp" 2>/dev/null || true

if [ ! -s "$PRIVATE/users.json" ]; then
    cat > "$PRIVATE/users.json" <<'JSON'
{"1":{"username":"admin","name":"Admin","role":"admin","homedir":"\/","permissions":"read|write|upload|download|batchdownload|zip|chmod","password":"$2y$10$Nu35w4pteLfc7BDCIkDPkecjw8wsH8Y2GMfIewUbXLT7zzW6WOxwq"},"2":{"username":"guest","name":"Guest","role":"guest","homedir":"\/","permissions":"","password":""}}
JSON
    chmod 660 "$PRIVATE/users.json" 2>/dev/null || true
    echo "filegatordocker: created $PRIVATE/users.json with the upstream default accounts."
    echo "filegatordocker: log in as admin/admin123 and change the password immediately."
fi

exec docker-php-entrypoint apache2-foreground
