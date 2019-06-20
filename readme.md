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
