# VPN


## Logging in to VPN


### ALM

Log into `vpn.alm.internal.smartcolumbusos.com` with your LDAP username and password

### Sandbox

Use the secrets manager in subbaccount `scos-sandbox`, `us-east-2` (Ohio).

Domain | User | Password Secret Name
--- | --- | ---
vpn.alm.sandbox.internal.smartcolumbusos.com | sandbox | sandbox-ldap-user-password
vpn.alm.sandbox.internal.smartcolumbusos.com | openvpn | openvpn_admin_password

## Manual steps for VPN server setup

Not all pieces of configuration are codified for the OpenVPN server yet. Here is the current list of things you need to do after using this to create a new one:
- Set up let's encrypt/certbot for the OpenVPN cert to make it not self signed
  ```#fetch certbot to use lets encrypt
  wget https://dl.eff.org/certbot-auto
  chmod +x certbot-auto

  #generate certificate
  ./certbot-auto certonly --agree-tos --email scos_alm_account@pillartechnology.com --standalone -d ${vpn_host} -n

  #setup cronjob to renew cert
  sudo echo "0 0,12 * * * python -c 'import random; import time; time.sleep(random.random() * 3600)' && /home/openvpnas/certbot-auto renew" >> ~/cert-renew.cron
  crontab ~/cert-renew.cron

  cd /usr/local/openvpn_as/etc/web-ssl

  #backup old certs
  sudo mv ca.crt ca.crt.old
  sudo mv server.crt server.crt.old
  sudo mv server.key server.key.old

  #symlink certs from letsencrypt
  sudo ln -s /etc/letsencrypt/live/${vpn_host}/fullchain.pem ca.crt
  sudo ln -s /etc/letsencrypt/live/${vpn_host}/privkey.pem server.key
  sudo ln -s /etc/letsencrypt/live/${vpn_host}/cert.pem server.crt

  sudo service openvpnas restart
- Add extra routes to the server so users can access dev/staging/prod or dynamic sandbox environments
  - In admin UI, go to VPN settings and enter the following in the "Additional Routes" section (may vary per version). This will make it so VPN users can route between the different VPCs. NOTE: don't add the trailing comments (stuff behind the #) that are provided below
    - For the ALM VPN server
      - 10.100.0.0/16  # dev VPC
      - 10.180.0.0/16  # staging VPC
      - 10.200.0.0/16  # prod VPC
    - For the Sandbox ALM VPN server
      - 10.0.0.0/8 # any possible dynamic sandbox VPCs
      
### LDAP Setup
From the openvpn web console, navigate to Authentication -> LDAP and fill out the following fields as shown. Note that the sandbox DC is only needed in sandbox:

Field | Value
--- | ---
Host | `iam-master.alm(.sandbox).internal.smartcolumbusos.com`
Bind DN | `UID=binduser,CN=users,CN=accounts,(DC=sandbox),DC=internal,DC=smartcolumbusos,DC=com`
Password | Find in secrets manager
Base DN | `CN=users,CN=accounts,(DC=sandbox),DC=internal,DC=smartcolumbusos,DC=com`
Username Attribute | `uid`
Additional LDAP Requirement | `memberOf=cn=vpnusers,cn=groups,cn=accounts,(dc=sandbox),dc=internal,dc=smartcolumbusos,dc=com`

The *Additional LDAP Requirement* field controls what extra properties users need to be able to use the VPN. In this case a group called `vpnusers`.

### MFA Setup
#### Preparation steps
Since MFA is not enforced for the default `openvpn` user, you have to make another user admin and then delete/disable the `openvpn` user.
- The user `openvpn-admin` is already created in LDAP, but if they are somehow lost, add them back in using the LDAP settings above. Their credentials can be found in secrets manager under the entry `openvpn_admin_credentials`
- Login to the VPN admin console (vpn host + "/admin") with the current `openvpn` credentials, and add a user under the "User Permissions" page called `openvpn-admin` who has the "Admin" box checked then click the "Save Settings" button and restart the server if prompted at the top of the page.
- Verify that you can login to the admin console with the `openvpn-admin` user.
- Follow the directions for [disabling the `openvpn` user](https://openvpn.net/vpn-server-resources/recommendations-to-improve-security-after-installation/#secure-the-openvpn-administrative-user-account). If you ever need to re-enabled them follow the steps for [re-enabling the `openvpn` user](https://openvpn.net/vpn-server-resources/troubleshooting-authentication-related-problems/#Reset_default_openvpn_account_administrative_access). Ideally, you should set their password to the secrets manager entry for `openvpn_admin_password`.

#### Enabling MFA
Now you can enable MFA. Please do make sure you've notified people that you are doing this if there are any concerns.
- Login to the VPN admin console (vpn host + "/admin") as the `openvpn-admin` user and go to the "Client Settings" page
- Click the "On" button near the text `Require that users provide a Google Authenticator one-time password for every VPN login` if it is not already on.
- Click the "Save Settings" button and restart the server if prompted at the top of the page.

#### Configuring MFA per user
Directions for a user to setup MFA (including the `openvpn-admin` user) can be found on [a wiki page](https://github.com/SmartColumbusOS/scosopedia/wiki/Setup-OpenVPN-2FA-for-your-user).

Otherwise, when you do set up the `openvpn-admin` user's MFA, please do make sure at least 2 people have it setup in case of emergency.
