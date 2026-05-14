# Vaultwarden Encrypted Backup

## My scripts

```bash
# create Vaultwarden backup, encrypt it and upload to it Github
./create_backup_encrypt_and_upload.sh

# download latest Vaultwarden backup, decrypt it and import to it Vaultwarden
./decrypt_backup_and_import.sh

# push changes in the custom scripts
./git_push.sh
```

## Vaultwarden
**[Link to the Vaultwarden Github Repository](https://github.com/dani-garcia/vaultwarden)**


## Age Encryption Tool
**[Link to the Age Encryption Tool Github Repository](https://github.com/FiloSottile/age)**

```bash
# encrypt file
age -R ~/.ssh/ssh-public-key.pub test.jpg > test.jpg.age

# decrypt file
age -d -i ~/.ssh/ssh-private-key test.jpg.age > decrypted_test.jpg
```