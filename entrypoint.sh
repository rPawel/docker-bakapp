#!/usr/bin/env bash
set -euo pipefail

iniSet() {
    file=$1
    var=$2
    val=$3
    if [ -n "${val}" ]; then
        sed -i "s/^\($var\s*=\s*\).*$/\1${val//\//\\\/}/" $file
    fi
}

iniSet /root/.duply/b2/conf GPG_KEY "'$GPG_KEY'"
iniSet /root/.duply/b2/conf GPG_PW "'$GPG_PW'"
iniSet /root/.duply/b2/conf TARGET "'$S3_TARGET'"
iniSet /root/.duply/b2/conf MAX_AGE "'$MAX_AGE'"
iniSet /root/.duply/b2/conf MAX_FULLBKP_AGE "'$MAX_FULLBKP_AGE'"
iniSet /root/.duply/b2/conf MAX_FULL_BACKUPS "'$MAX_FULL_BACKUPS'"

gpg --pinentry-mode loopback --passphrase=$GPG_PW --import /gpg-keys/gpgkey.$GPG_KEY.sec.asc
expect -c 'spawn gpg --edit-key '$GPG_KEY' trust quit; send "5\ry\r"; expect eof'

echo "$SCHEDULE BASH_ENV=/env /usr/bin/bash /backup.sh > /proc/1/fd/1 2>&1" > /app.cron
echo "$VERIFY_SCHEDULE BASH_ENV=/env /usr/bin/bash /backup.sh -v > /proc/1/fd/1 2>&1" >> /app.cron
crontab /app.cron
rm /app.cron

/usr/bin/env | sed -r "s/'/\\\'/gm" | sed -r "s/^([^=]+=)(.*)\$/\1'\2'/gm" > /env
/usr/sbin/cron -f