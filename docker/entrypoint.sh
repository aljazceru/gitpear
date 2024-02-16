#!/bin/bash
# if $1 includes an url
exec > >(tee -a "/tmp/deployment.log") 2>&1

export GIT_PEAR=/srv/repos/pear 
export GIT_PEAR_AUTH="nip98"
export GIT_PEAR_AUTH_NSEC="nsec1lnumf25dacf7804ezv4zyd262j08g3n9h6h2fdntwgpxmhwqhw3sy3vjkp"
git pear daemon -s 
# if $1 exists
if [ -n "$1" ]; then
    REPO_NAME=$1
fi



if [[ $REPO_NAME =~ ^https.* ]]; then
  ORIGINAL_NAME=$(basename $REPO_NAME .git)
  mkdir -p /srv/repos/"$ORIGINAL_NAME"
  git clone $REPO_NAME /srv/repos/"$ORIGINAL_NAME"
  cd /srv/repos/"$ORIGINAL_NAME"
  git pear init .
  git pear share . public
  git pear acl add $USER_NPUB:admin
# enter pear repo and expose http
  cd /srv/repos/pear/"$ORIGINAL_NAME"/
  echo "[http]" >> config
  echo "	receivepack = true" >> config
fi


if [[ ! $REPO_NAME =~ ^https.* ]]; then
  mkdir -p /srv/repos/"$REPO_NAME"
  cd /srv/repos/"$REPO_NAME"
  git pear init .
  git pear share . public
  git pear acl add $USER_NPUB:admin
  # enter pear repo and expose http
  cd /srv/repos/pear/"$REPO_NAME"/
  echo "[http]" >> config
  echo "	receivepack = true" >> config
#  git config --bool core.bare true
fi
PEAR_KEY=$(git pear key)
PEAR_REPO=$(git pear list -s)
echo "REPO_NAME: $REPO_NAME" >> /tmp/debug.log
echo "ORIGINAL_NAME: $ORIGINAL_NAME" >> /tmp/debug.log
echo "GIT_PEAR: $GIT_PEAR" >> /tmp/debug.log
echo "PEAR_KEY: $PEAR_KEY" >> /tmp/debug.log
echo "PEAR_REPO: $PEAR_REPO" >> /tmp/debug.log

/etc/init.d/fcgiwrap start
chmod 766 /var/run/fcgiwrap.socket
nginx -g "daemon off;"
