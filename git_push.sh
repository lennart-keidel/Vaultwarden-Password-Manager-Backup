#!/bin/sh

# change directory to script source
cd "$(dirname "$(realpath "$0")")"

# start new ssh-agent
eval "$(ssh-agent -s)"

# add pid and stuff to file
ssh-agent -s | head -n 1 > ssh-agent.cf

# read in this
# delete temp file afterwards
source "$(dirname "$(realpath "$0")")/ssh-agent.cf"
rm -f ssh-agent.cf

# add github key to ssh agent
ssh-add $HOME/.ssh/github

git pull origin main
git add create_backup_encrypt_and_upload.sh
git add decrypt_backup_and_import.sh
git add git_push.sh
git commit -m "update scripts"
git push origin main