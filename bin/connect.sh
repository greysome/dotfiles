#!/bin/sh
sudo ip link set wlp2s0 up
sudo iw dev wlp2s0 scan > $HOME/.networks_output

networks_file="$HOME/.networks"

for i in $(cat "$networks_file"); do
    network=$(cut -d';' -f1 <<< "$i")
    pass=$(cut -d';' -f2 <<< "$i")
    if grep -q "$network" $HOME/.networks_output; then
	if ping -q -c 1 -W 1 google.com > /dev/null 2>&1; then
	    echo "already connected to $network"
	    return
	else
	    wpa_passphrase "$network" "$pass" > $HOME/.wpa_passphrase
	    sudo wpa_supplicant -iwlp2s0 -c $HOME/.wpa_passphrase -B > /dev/null
	    sudo dhcpcd wlp2s0 > /dev/null
	    echo "connected to $network"
	    return
	fi
    fi
done

echo "connection failed"
