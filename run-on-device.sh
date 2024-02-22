#!/bin/bash
# check if device is connected to a network (check if they have an IP addresss)


extractFieldsAndExecute() {
    # this will redirect and give payphone details
    urlAddress=$(curl -c cookies.txt --interface wlan0 http://google.com | cut -d\" -f2)
    payphoneMAC=$(echo $urlAddress | grep -oP 'mac=\K[^&]*')
    payphoneID=$(echo $urlAddress | grep -oP 'a=\K[^&]*')
    payphoneTime=$(echo $urlAddress | grep -oP 'b=\K[^&]*')

    if [ -z "$payphoneMAC" ] || [ -z "$payphoneID" ] || [ -z "$payphoneTime" ]; then

        echo "One or more payphone details are missing or empty."
        echo "$payphoneMAC"
        echo "$payphoneID"
        echo "$payphoneTime"
        return 1 
    fi

    # this will connect us to the internet 
    curl --interface wlan0 -H "X-Requested-With: XMLHTTPRequest" -b cookies.txt https://apac.network-auth.com/splash/NAxIVbNc.5.167/grant?continue_url=

    # check if connected to internet 

    # run executable
    /usr/local/bin/client-indicum $payphoneMAC $payphoneID $payphoneTime

    # change our MAC address (so we will have to sign in again when we re-see payphone)
    sudo ifconfig wlan0 down && sudo macchanger -r wlan0 && sudo ifconfig wlan0 up

}



# check that the network connected to is "Free Telstra Wifi"

while [ true ]; do
    interface="wlan0"
    expectedSSID="Free Telstra Wi-Fi"

    if ping -c 1 8.8.8.8 -W 5 &> /dev/null; then
        echo "ping success"
        extractFieldsAndExecute
    else
        currentSSID=$(iwgetid -r "$interface")
        echo "currentSSID is $currentSSID"
    fi

    # currentSSID=$(iwgetid -r "$interface")

    # if [ "$expectedSSID" == "$currentSSID" ]; then
    #     extractFieldsAndExecute
    #     # maybe add sleep 100 here, we don't really care if you stay next to it.
    # else 
    #     echo "currentSSID is $currentSSID"
    # fi
    sleep 5

done

# if so get details from redirect
