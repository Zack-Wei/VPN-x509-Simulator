# help others to sign
# import 
gpg --homedir $home --import $file

# get id
gpg --homedir $home --list-keys $name_of_someone

# sign
gpg --homedir $home --ask-cert-level --sign-keys $id

# export 
gpg --homedir $home --armour --output $someone.key.asc --export $id



# import form others

## import
gpg --homedir $home --import $files_from_others

## check signature which is signed by others
gpg --homedir $home --list-signatures

## uplopad 
gpg --homedir $home --keyserver $key_server --send-key $your_id

