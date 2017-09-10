#!/bin/bash

# Copy over configuration files
install -m 644 files/rpikit_wifi ${ROOTFS_DIR}/etc/network/interfaces.d/rpikit_wifi
install -m 644 files/hostapd.conf ${ROOTFS_DIR}/etc/hostapd/hostapd.conf
install -m 644 files/dnsmasq.conf ${ROOTFS_DIR}/etc/dnsmasq.conf
install -m 644 files/hostapd.service ${ROOTFS_DIR}/etc/systemd/system/hostapd.service
install -m 600 files/wpa_supplicant.conf ${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf
install -m 644 files/wifi-ap.rules ${ROOTFS_DIR}/etc/udev/rules.d/wifi-ap.rules
install -m 644 files/randomize.sh ${ROOTFS_DIR}/randomize.sh
install -m 644 files/iptables.ipv4.nat ${ROOTFS_DIR}/etc/iptables.ipv4.nat

# Enter chroot
on_chroot <<'EOF'

# Set hostname
raspi-config nonint do_hostname "RPiKit"

# Change password
echo "pi:rpikit" | chpasswd

# Enable VNC
systemctl enable vncserver-x11-serviced.service

# Enable hostapd
systemctl enable hostapd

# Don't allow wlan_ap in dhcpcd
echo "denyinterfaces wlan_ap" >> /etc/dhcpcd.conf

# Set daemon configuration for hostapd
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> /etc/default/hostapd

# Enable ipv4 forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Clone projects
git clone https://github.com/adeept/Adeept_RFID_Learning_Kit_C_Code_for_RPi.git /home/pi/RPiKit_C_Code
git clone https://github.com/adeept/Adeept_RFID_Learning_Kit_Python_Code_for_RPi.git /home/pi/RPiKit_Python_Code

# Run randomize.sh on next boot
sed -i -e '$i \bash \/randomize.sh &\n' /etc/rc.local

# Restore iptables on every boot
sed -i -e '$i \iptables-restore < \/etc\/iptables.ipv4.nat &\n' /etc/rc.local

# Replace wallpaper
mv /usr/share/rpd-wallpaper/road.jpg /usr/share/rpd-wallpaper/road-original.jpg
# Get out of chroot for copying wallpaper
EOF
install -m 644 "files/RPiKit Background.jpg" ${ROOTFS_DIR}/usr/share/rpd-wallpaper/road.jpg
