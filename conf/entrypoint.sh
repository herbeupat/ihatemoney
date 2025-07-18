#!/bin/sh

# Fail the whole script on the first failure.
set -e

cat <<EOF >/etc/ihatemoney/ihatemoney.cfg
DEBUG = $DEBUG
ACTIVATE_ADMIN_DASHBOARD = $ACTIVATE_ADMIN_DASHBOARD
ACTIVATE_DEMO_PROJECT = $ACTIVATE_DEMO_PROJECT
ADMIN_PASSWORD = '$ADMIN_PASSWORD'
CURRENCY_API_KEY = '$CURRENCY_API_KEY'
ALLOW_PUBLIC_PROJECT_CREATION = $ALLOW_PUBLIC_PROJECT_CREATION
BABEL_DEFAULT_TIMEZONE = "$BABEL_DEFAULT_TIMEZONE"
MAIL_DEFAULT_SENDER = "$MAIL_DEFAULT_SENDER"
MAIL_PASSWORD = "$MAIL_PASSWORD"
MAIL_PORT = $MAIL_PORT
MAIL_SERVER = "$MAIL_SERVER"
MAIL_USE_SSL = $MAIL_USE_SSL
MAIL_USE_TLS = $MAIL_USE_TLS
MAIL_USERNAME = "$MAIL_USERNAME"
SECRET_KEY = "$SECRET_KEY"
SESSION_COOKIE_SECURE = $SESSION_COOKIE_SECURE
SHOW_ADMIN_EMAIL = $SHOW_ADMIN_EMAIL
SQLACHEMY_DEBUG = DEBUG
SQLALCHEMY_DATABASE_URI = "$SQLALCHEMY_DATABASE_URI"
SQLALCHEMY_TRACK_MODIFICATIONS = $SQLALCHEMY_TRACK_MODIFICATIONS
APPLICATION_ROOT = "$APPLICATION_ROOT"
ENABLE_CAPTCHA = $ENABLE_CAPTCHA
LEGAL_LINK = "$LEGAL_LINK"
EOF

PUID=${PUID:-0}
PGID=${PGID:-0}

echo "
User uid: $PUID
User gid: $PGID
"

# Start gunicorn without forking
cmd="exec gunicorn ihatemoney.wsgi:application \
     -b 0.0.0.0:$PORT \
     --log-syslog \
     $@"

if [ "$PGID" -ne 0 -a "$PUID" -ne 0 ]; then
     groupmod -o -g "$PGID" abc
     usermod -o -u "$PUID" abc
     cmd="su - abc -c '$cmd'"
fi

eval "$cmd"
