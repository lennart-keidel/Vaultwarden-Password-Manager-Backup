#!/bin/sh

# set color as variable
RED='\033[0;31m'
NC='\033[0m' # No Color

path_vaultwarden_dir="$HOME/vaultwarden/data"
file_name_vaultwarden_db_file="db.sqlite3"
current_path="$(dirname "$(realpath "$0")")"

# change directory to script source
cd "$current_path"


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

# pull changes
# reset to most recent upload
git pull origin main
git reset origin/main --hard

filename_backup_encrypted="$(basename "$(find . -type f -name "*.sqlite3.age" | tail -n1)")"
filename_backup_decrypted="decrypted_${filename_backup_encrypted%%.*}.sqlite3"

# decrypt with ssh private key
# error message if it fails
# then remove backups
age -d -i ~/.ssh/vaultwarden_backup_encryption_ssh_key "$filename_backup_encrypted" > "$filename_backup_decrypted"
if [ $? -gt 0 ]; then
  echo -e "${RED}ERROR: Age Encryption failed${NC}"
  rm "$filename_backup_decrypted" -f
  rm "$filename_backup_encrypted" -f
  exit
fi


age -d -i ~/.ssh/vaultwarden_backup_encryption_ssh_key "$filename_backup_encrypted" > "$filename_backup_decrypted"
if [ $? -gt 0 ]; then
  echo -e "${RED}ERROR: Age Decryption failed${NC}"
  rm "$filename_backup_decrypted" -f
  rm "$filename_backup_encrypted" -f
  exit
fi


# import decrypted encpass backup
# override existing secrets in encpass
# error message if it fails
mv -f "$current_path/$filename_backup_decrypted" "$path_vaultwarden_dir/$file_name_vaultwarden_db_file"
if [ $? -gt 0 ]; then
  rm "$filename_backup_decrypted" -f
  rm "$filename_backup_encrypted" -f
  echo -e "${RED}ERROR: import of Vaultwarden backup failed${NC}"
  exit
fi

echo -e "${GREEN}Successfully imported Vaultwarden backup${NC}"

# remove encrypted backup file
rm "$filename_backup_decrypted" -f

# remove decrypted backup file
rm "$filename_backup_encrypted" -f