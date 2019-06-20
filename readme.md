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
- Set up let's encrypt/certbot for the OpenVPN cert to make it not self signed (Jessie can fill this out)
- Add extra routes to the server so users can access dev/staging/prod or dynamic sandbox environments
  - In admin UI, go to VPN settings and enter the following in the "Additional Routes" section (may vary per version). This will make it so VPN users can route between the different VPCs. NOTE: don't add the trailing comments (stuff behind the #) that are provided below
    - For the ALM VPN server
      - 10.100.0.0/16  # dev VPC
      - 10.180.0.0/16  # staging VPC
      - 10.200.0.0/16  # prod VPC
    - For the Sandbox ALM VPN server
      - 10.0.0.0/8 # any possible dynamic sandbox VPCs
