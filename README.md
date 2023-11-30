# Overleaf/sharelatex image with LDAP Support

Original sharelatex image with LDAP support, based on the modification of a few files, mainly [`AuthenticationManager.js`](./ldap/4.1.6/AuthenticationManager.ldap.js) and [`ContactController.js`](./ldap/4.1.6/ContactController.ldap.js). 

These modifications were directly taken from [this original solution](https://github.com/smhaller/ldap-overleaf-sl) but an "unnecessary" `betaProgram` user flag was used to identify LDAP users from normal e-mail users. Indeed, LDAP users cannot change their password or e-mail in the Overleaf user settings! Several new environment variables have been added to the [`variables.env` file](lib/config-seed//variables.env) for LDAP configuration, which must be done with care.

From [the original solution](https://github.com/smhaller/ldap-overleaf-sl), this module authenticates against the local DB if the `ALLOW_EMAIL_LOGIN` environment variable added in the [`variables.env`](lib/config-seed/variables.env) file is set to `true`. If this fails or `ALLOW_EMAIL_LOGIN` is not `true`, it tries to authenticate against the LDAP server specified by the `LDAP_SERVER` environment variable by using one of the two following methods. 

1. If the `LDAP_BINDDN` environment variable is specified, it tries to bind with the user trying to log in by replacing `%u` in `LDAP_BINDDN` with the user login i.e. uid or if the login is an e-mail, the domain is stripped to extract the uid. It means that with this method, a LDAP user cannot, most of the time, use his e-mail to log in, unless the e-mail without the "domain" part exactly corresponds to his uid.
2. An alternative method provides the possibility to use a separate ldap bind user with the `LDAP_BIND_USER` and `LDAP_BIND_PW` (user password) environment variables. It does this just to find the proper BIND DN and record for the provided user using a filter `LDAP_USER_FILTER` where `%u` and `%m` are replaced by the user's uid and email respectively. So, it is possible that users from different groups / OUs can login. Furthermore, with this method, if `LDAP_USER_FILTER` takes the user's mail into account, users whose e-mail is not *uid@domain.com* can also log in with their e-mail address specified in their LDAP entry (mail field). Then, in order to check that the user's password is correct and to avoid LDAP password hashing hassle, it tries to bind to the LDAP server (using ldapts) with the user DN and the credentials of the user attempting to log in.

**Notes:**

- LDAP Users can not change their LDAP password in Overleaf. They have to change it at the LDAP server. 
- LDAP Users can only reset their local db password which was randomly generated at first login by clicking the "Forgot your password?" link on the log in page and using their LDAP e-mail. By default, a LDAP user cannot change their local passwords in the user settings. 
- LDAP Users should not change their e-mail, as they are uniquely identified in the Overleaf DB by their e-email address. The e-mail address is taken from the LDAP server using the mail field or by invitation through an admin. This LDAP mail field has to contain a valid e-mail address. Firstname and lastname are taken from the fields "givenName" and "sn".   
- Admins can invite users directly via e-mail. `LDAP_ADMIN_GROUP_FILTER` specified which LDAP users are admins. 
- An "unnecessary"`betaProgram` flag is now used to identify LDAP users vs. normal e-mail user in order to prevent e-mail (and password) change in the user settings. 

**Important:**

Sharelatex/Overleaf uses e-mail addresses to identify users. This solution cannot work with LDAP users who do not have a mail field in their LDAP entry. Moreover, if you change the e-mail in the LDAP server, you need to update the corresponding field in the mongo db using this code in order to keep the user's Overleaf projects.

```shell
docker exec -it mongo /bin/bash
mongo 
use sharelatex
db.users.find({email:"EMAIL"}).pretty()
db.users.update({email : OLDEMAIL},{$set: { email : NEWEMAIL}});
```

**Automatic update:**

In order to automatically update future versions of the files [`AuthenticationManager.js`](./ldap/4.1.6/AuthenticationManager.ldap.js) and [`ContactController.js`](./ldap/4.1.6/ContactController.ldap.js) with this LDAP implementation, a bash script named [`updateldap.sh`](sharelatex/ldap/updateldap.sh) was created using the _git merge_ function as a base. 
