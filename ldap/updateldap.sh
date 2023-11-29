#!/bin/bash
author="Rudy Ercek"
authormail="rudy.ercek@ulb.be"
# Original file version and subdirectory !
version="4.1.6"
authfile="$1"
contactfile="$2"
settingsfile="$3"
if [ -z "$authfile" ]; then authfile="/overleaf/services/web/app/src/Features/Authentication/AuthenticationManager.js"  ; fi
if [ -z "$contactfile" ];  then contactfile="/overleaf/services/web/app/src/Features/Contacts/ContactController.js" ; fi
if [ -z "$settingsfile" ]; then settingsfile="/overleaf/services/web/app/views/user/settings.pug" ; fi
echo "Authentification file=$authfile"
echo "Contact file=$contactfile"
echo "User settings file=$settingsfile"
echo "Install git" 
apt install git -y
echo "Remove .git directory if already exists"
rm -R .git
echo "Configure git user and default branch master"
git config --global user.name "$author"
git config --global user.email "$authormail"
git config --global init.defaultBranch master
echo "Copy original files version $version"
cp "./$version/AuthenticationManager.js" .
cp "./$version/ContactController.js" .
echo "Add and commit original files version $version to master"
git init
git add AuthenticationManager.js
git add ContactController.js
git commit -am "Original files version $version"
echo "Replace and commit files with ldap modification version $version to branch ldap"
git checkout -b ldap
cp "./$version/AuthenticationManager.ldap.js" AuthenticationManager.js
cp "./$version/ContactController.ldap.js" ContactController.js
git commit -am "LDAP files version $version"
echo "Replace original files version $version in the master branch with the new original files and commit them"
git checkout master
cp "$authfile" AuthenticationManager.js
cp "$contactfile" ContactController.js
git commit -am "New original file"
echo "Try to merge ldap modification to the new files for ldap support"
if git merge ldap --no-edit ; then
	echo "Merge success, backup original files and replace them with the ones including the ldap support"
	cp "$authfile" "$authfile.bak"
	cp "$contactfile" "$contactfile.bak"
	cp "$settingsfile" "$settingsfile.bak"
	cp AuthenticationManager.js "$authfile"
	cp ContactController.js "$contactfile"
	# Use of the betaProgram flag as ldap settings.
	sed -i 's/externalAuthenticationSystemUsed()/user.betaProgram/g' "$settingsfile"
else
	echo "Merge failed, original files will be kept, NO LDAP support"
fi




