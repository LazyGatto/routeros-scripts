###############################################################################
# Cloudflare Network Routes Updater Script for MikroTik RouterOS
# This RouterOS script automatically downloads the latest list of Cloudflare IPv4 
# networks from the official URL (https://www.cloudflare.com/ips-v4) and installs 
# them as static routes into a dedicated routing table with needed gateway.
###############################################################################

:local fileName "cloudflare.txt";
:local prefixPos 0;
:local line "";
:local lastEnd 0;
:local gateway "172.16.123.1";
:local routingTable "CloudFlareNets";
:local urlTofetch "https://www.cloudflare.com/ips-v4";

# Download actual nets from url
/tool/fetch url=$urlTofetch dst-path=$fileName
:delay 2
:if ([/file find name=$fileName] = "") do={
    :log error "File download failed"
    :error "File is absent"
}

# Remove old routes from routingTable
:foreach r in=[/ip/route/find where routing-table=$routingTable] do={
    /ip/route/remove $r
}

# Parsing file into routes
:local content [/file get $fileName contents as-string]
:local contentLen [ :len $content ]
:log info ("contentLen: $contentLen")

:do {
    :set prefixPos [:find $content "/" $lastEnd ]
    :log info ("prefixPos $prefixPos")
    
    :set line [ :pick $content $lastEnd ($prefixPos + 3) ]
    :log info ("line $line")
    
    :set lastEnd ( $prefixPos + 4 )
    :log info ("lastEnd $lastEnd")

    /ip/route/add dst-address=$line gateway=$gateway routing-table=$routingTable

} while ($lastEnd < $contentLen)
