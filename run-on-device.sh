#!/bin/bash

extractFieldsAndExecute() {
    # go to any website so I can get the metadata (payphoneMAC, payphoneID, payphoneTime)
    output=$(curl --interface "$interface" http://google.com -m 10) || { echo "[ERROR] inital curl timeout"; return 1 }
    urlAddress=$(echo "$output" | cut -d\" -f2)
    # need to use -L to get cookies (cookies are used to authenticate)
    curl -c /tmp/cookies.txt -s -L --interface $interface http://google.com -m 10 || { echo "[ERROR] initial curl timeout"; return 1 }
    payphoneMAC=$(echo $urlAddress | grep -oP '\?mac=\K[^&]*')
    # a little trick to urldecode. Replace %3A into :
    payphoneMAC=$(echo "${payphoneMAC//%3A/:}")
    payphoneID=$(echo $urlAddress | grep -oP 'a=\K[^&]*')
    payphoneTime=$(echo $urlAddress | grep -oP 'b=\K[^&]*')

    echo "[INFO] urlAddress is $urlAddress"
    if [ -z "$payphoneMAC" ] || [ -z "$payphoneID" ] || [ -z "$payphoneTime" ]; then
        echo "[INFO] $payphoneMAC"
        echo "[INFO] $payphoneID"
        echo "[INFO] $payphoneTime"
        echo "[ERROR] One or more payphone details are missing or empty."
        return 1
    fi
    echo "[INFO] Succesfully got urlAddress"
    # this will connect us to the internet (using the cookies for authentication)
    curl --interface "$interface" -m 20 -H "X-Requested-With: XMLHTTPRequest" -b /tmp/cookies.txt \
    https://apac.network-auth.com/splash/NAxIVbNc.5.167/grant?continue_url= || { echo "[ERROR] curl timeout"; return 1 }

    # check if connected to internet
    echo "[INFO] Succesfully connected to internet"
    echo "[INFO] $payphoneMAC"
    echo "[INFO] $payphoneID"
    echo "[INFO] $payphoneTime"
    # run executable
    /usr/local/bin/client-indicum $payphoneMAC $payphoneID $payphoneTime

    echo "[INFO] Successfully ran client-indicum"
    # change our MAC address (so we will have to sign in again when we re-see payphone)
    sudo ifconfig "$interface" down && sudo macchanger -r "$interface" && sudo ifconfig "$interface" up

    echo "[INFO] successfully changed mac address"
}

while [ true ]; do
    interface="wlan1"
    expectedSSID="Free Telstra Wi-Fi"

    # initial internet test check
    if ping -c 1 8.8.8.8 -W 5 -I "$interface" &> /dev/null; then
        echo "[INFO] ping success"
        extractFieldsAndExecute
    else
        # if failed, check if interface is connected to wifi but just doesn't have internet access
        currentSSID=$(iwgetid -r "$interface")
        if [ "$currentSSID" = "$expectedSSID" ]; then
            # if so, reset MAC address, this usually fixes it
            sudo ifconfig "$interface" down && sudo macchanger -r "$interface" && sudo ifconfig "$interface" up
        fi
        echo "[INFO] currentSSID is $currentSSID"
    fi

    sleep 5

done

