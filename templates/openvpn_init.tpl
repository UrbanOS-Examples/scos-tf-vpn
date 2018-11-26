#!/bin/bash

cat <<EOF > /etc/network/interfaces.d/eth1.cfg
auto eth1
iface eth1 inet dhcp
EOF

ifup eth1

# Swap ports so that web traffic listens on 443 to eliminate port needed in URL
sed -i 's/"cs\.https\.port"\: "943",/"cs\.https\.port"\: "443",/' /usr/local/openvpn_as/etc/config.json
sed -i 's/"vpn\.server\.daemon\.tcp\.port"\: "443",/"vpn\.server\.daemon\.tcp\.port"\: "943",/' /usr/local/openvpn_as/etc/config.json

# OpenVPN reads the userdata for key value pairs for automatic self configuration
# These are the known (undocumented) variables that the OpenVPN AS consumes
admin_user=${admin_user}
admin_pw=${admin_password}
# License key cannot be reused, so it should not be set automatically
license=
local_auth=${local_auth}
reroute_dns=${reroute_dns}
reroute_gw=${reroute_gw}
public_hostname=${public_hostname}
