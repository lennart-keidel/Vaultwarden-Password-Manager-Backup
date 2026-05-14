#!/bin/sh

# set color as variable
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# move backup to current directory
date_string="$(date '+%Y_%m_%d')"
path_vaultwarden_dir="$HOME/vaultwarden_test/data"
current_path="$(dirname "$(realpath "$0")")"
backup_filename="backup_vaultwarden_$date_string.sqlite3"
backup_filename_encrpyted="$backup_filename.age"

# change directory to script source
cd "$current_path"

# remove old files, if they still exist
if [ -e *.sqlite3 ]; then rm -f *.sqlite3; fi
if [ -e *.age ]; then rm -f *.age; fi

# create export file
# file saved in $HOME/vaultwarden_password_manager_backup
# error message if vaultwarden backup fails
# then remove backups
sqlite3 "$path_vaultwarden_dir/db.sqlite3" ".backup '$current_path/$backup_filename'"
if [ $? -gt 0 ]; then
  echo -e "${RED}ERROR: Vaultwarden Export failed${NC}"
  rm "$current_path"/*.sqlite3 -fv
  exit
fi

# move export file to current directory
# first_file_in_export_dir="$(find "$path_vaultwarden_dir" -type f -name "*.sqlite3" | tail -n1)"
# mv -vf "$first_file_in_export_dir" "$(dirname "$(realpath "$0")")/$backup_filename"

# encrypt with ssh public key
# error message if encryption failed
# remove backups on error
age -R ~/.ssh/vaultwarden_backup_encryption_ssh_key.pub "$backup_filename" > "$backup_filename_encrpyted"
if [ $? -gt 0 ]; then
  echo -e "${RED}ERROR: Age Encryption failed${NC}"
  rm "$current_path/$backup_filename" -f
  rm "$current_path/$backup_filename_encrpyted" -fv
  exit
fi

echo -e "${GREEN}Successfully created encrypted backup${NC}"

# remove unencrypted backup file
rm "$backup_filename" -f

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

# upload encrypted backup to github
# pull changes from git
# add encrypted backup file
# add deleted files
# commit and push
git pull origin main
git add "$backup_filename_encrpyted"
git ls-files --deleted | xargs git add
git commit -m "new vaultwarden backup from $(date '+%Y-%m-%d at %H:%M')"
git push origin main
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Successfully uploaded backup${NC}"
  echo -e "${YELLOW}HINT: Just ignore the git add warning, everthing is probably fine ${NC}"
else
  echo -e "${GREEN}Failed at uploading backup${NC}"
fi

# remove encrypted backup, cause it's already uploaded
# no need for it to stay on the server
rm "$current_path"/*.age -fv
rm "$current_path"/*.sqlite3 -fv
