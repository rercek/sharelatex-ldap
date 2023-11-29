########################################################
### SHARELATEX IMAGES FOR OVERLEAF WITH LDAP Support ###
########################################################

ARG VERSION=4.2.0
FROM sharelatex/sharelatex:${VERSION}
# LDAP solution taken FROM https://github.com/yzx9/ldap-overleaf-sl/blob/master/ldap-overleaf-sl/Dockerfile

# Tex login
ARG login_text   

# Copy files for updating authentification files with ldap
COPY ldap /tmp/ldap

    # install latest npm
RUN npm install -g npm && \
    ## clean cache (might solve issue #2)
    # npm cache clean --force && \
    npm install ldap-escape ldapts-search ldapts@3.2.4 && \
    ## instead of copying the login.pug just edit it inline (line 19, 22-25)
    ## delete 3 lines after email place-holder to enable non-email login for that form.
    sed -iE '/type=.*email.*/d' /overleaf/services/web/app/views/user/login.pug && \
    ## comment out this line to prevent sed accidently remove the brackets of the email(username) field
    # sed -iE '/email@example.com/{n;N;N;d}' /overleaf/services/web/app/views/user/login.pug && \
    sed -iE "s/email@example.com/${login_text:-user}/g" /overleaf/services/web/app/views/user/login.pug && \
    # run the script for updating ldap files AuthentificationManager.js and ContactController.js
    cd /tmp/ldap && \
    chmod +x ./updateldap.sh && \
    ./updateldap.sh | tee /tmp/updateldap.log && \
    cd /overleaf/services/web && \
    rm -R /tmp/ldap
