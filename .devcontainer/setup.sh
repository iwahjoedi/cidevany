#!/bin/sh

set -eux
#LOCAL_WORKSPACE=$(echo "${GITHUB_REPOSITORY}" | cut -f 2 -d "/")
SITE_HOST=default

echo "Installing Subversion..."
#sudo apk update
#sudo apk add --no-cache  git-svn subversion perl

#
#if [ -z ${CODESPACE_NAME+x} ]; then
#	SITE_HOST="http://localhost:8080"
#else
#	SITE_HOST="https://${CODESPACE_NAME}-8080.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
#fi

# Install dependencies
#cd /workspaces/${LOCAL_WORKSPACE}
#npm install && npm run build:dev

# Config ENV
#sudo sed -i -r "s@.*LOCAL_WP_HOME.*@LOCAL_WP_HOME=https://${CODESPACE_NAME}-8889.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}@" /workspaces/${LOCAL_WORKSPACE}/.env
#sudo sed -i -r "s@.*LOCAL_WP_SITEURL.*@LOCAL_WP_SITEURL=https://${CODESPACE_NAME}-8889.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}@" /workspaces/${LOCAL_WORKSPACE}/.env


# Install WordPress and activate the plugin/theme.
#cd /var/www/html
#echo "Setting up WordPress at $SITE_HOST"
#wp core install --url="$SITE_HOST" --title="WordPress Trunk" --admin_user="admin" --admin_email="admin@example.com" --admin_password="password" --skip-email
