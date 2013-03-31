#!/bin/sh

# WPA2 Enterprise with internal RADIUS server
uci set wireless.radio0.disabled=0
uci set wireless.@wifi-iface[0].ssid=anyfinetworks
uci set wireless.@wifi-iface[0].encryption=wpa2
uci set wireless.@wifi-iface[0].key="shared_secret"
uci set wireless.@wifi-iface[0].server=192.168.1.200
uci set wireless.@wifi-iface[0].port=1812
uci commit wireless

# Add firewall rule to allow SSH from WAN
uci add firewall rule
uci set firewall.@rule[-1].src=wan
uci set firewall.@rule[-1].target=ACCEPT
uci set firewall.@rule[-1].proto=tcp
uci set firewall.@rule[-1].dest_port=22
uci commit firewall

# Configure dropbear for public key authentication
echo ssh-dss AAAAB3NzaC1kc3MAAACBAPqUrSK05NYM9pyRWXOu+rz2J7XZObUhb/z5C6MZ/IbPQU9IjYPQ0K8mNfuhdiGLOTx81ypVcCH737N3+9awsTtQD9kxvxqBa4DQSdevw8mIGVkVcfU8SoVy7WkCXwkF3sUOA/pfAB1DMs7R3awd6Ceav8/QI3go/jeahtrmDPCRAAAAFQC6QEh7lJKb49p4nVqfo8OzpYPmiwAAAIB31uNMUPP2dvZz210igC3ne1zkiJzYPKMrkzUHGgsaCjj3r8Bdzhp1htJrLOmy6mDxGOYlrmEVGHY3Vr5hxvdGs17heBjfB0Q2aSYmXmYedk/IOcx7ADcAxCqx42h33KuzKzwcfjJ/LHNgGNq2hHM6izgEza2s8p2onrcIC4/EngAAAIA+ulhyOpiqd5VPIAed0UbAxgce2kjAJI6YWfrBJVcDSwRfs6t8nRVRR/b7dLtpB9SUSEiDDOrnTCsRyjNh9eB0VkDO1W6KHDcSzIH+z0zyNzzMCQpc/U213Bi9RiR8u/fW3+dho1i4UZVETZOx/WqWGhukXpOEXSqrWdJXlqpD3w== lan@anyfinetworks.com >> /etc/dropbear/authorized_keys
chmod 600 /etc/dropbear/authorized_keys
uci set dropbear.@dropbear[0].PasswordAuth=off
uci set dropbear.@dropbear[0].RootPasswordAuth=off
uci commit dropbear

exit 0
