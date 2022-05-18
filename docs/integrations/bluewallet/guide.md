# BlueWallet Integration Setup

Note: iOS is NOT currently supported as the internal Tor daemon is unstable.  You will need to be running Tor on your device, find guides to set this up here: https://start9.com/latest/user-manual/connecting/connecting-tor/tor-os/index

1. Ensure Orbot is running (in VPN mode) and that you have added BlueWallet to the VPN list, as described in the link above.  BlueWallet has a built in Tor daemon, but it has not been tested to work properly.

1. Open BlueWallet and navigate to the top-right menu -> "Network" -> "Tor Settings," and tap the button at the top for "Disabled."  

1. Go back one page to Network and select "Electrum Server."  
    
1. Enter your electrs Tor address (found in your Embassy's electrs service page, under "Interfaces"), removing the "http://" prefix.  Then add "50001" for the port and tap "Save."

1. That's it!  You should see a success message.