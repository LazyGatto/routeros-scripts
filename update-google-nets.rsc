###############################################################################
# Google IPs Routes Updater Script for MikroTik RouterOS
# This RouterOS script automatically downloads the latest list of Google IPv4 
# networks from the URL (https://www.gstatic.com/ipranges/goog.json) and installs 
# them as static routes into a dedicated routing table with needed gateway.
###############################################################################

:local fileName "google.json";
:local gateway "172.16.123.1";
:local routingTable "GoogleNets";
:local urlTofetch "https://www.gstatic.com/ipranges/goog.json";

:log info "Starting update of Google IP routes..."

# Download JSON file
/tool/fetch url=$urlTofetch dst-path=$fileName mode=https
:delay 2
:if ([/file find name=$fileName] = "") do={
    :log error "File download failed"
    :error "File is absent"
}

# Remove old routes
:foreach r in=[/ip/route/find where routing-table=$routingTable] do={
    /ip/route/remove $r
}
:log info "Old GoogleNets routes removed"

# Read JSON file content
:local content [/file get $fileName contents as-string]
:local contentLen [:len $content]
:log info ("contentLen $contentLen")
:local lastPos 0
:local prevStart 0
:local addedCount 0
:local continue true

while ($continue) do={
    :local start [:find $content "\"ipv4Prefix\": \"" $lastPos]
    :set start ($start + 15)
    :if ($prevStart > $start) do={
        :set continue false
    } else={      
        :local end [:find $content "\"" $start]
        :local prefix [:pick $content $start $end]
        /ip/route/add dst-address=$prefix gateway=$gateway routing-table=$routingTable
        :set addedCount ($addedCount + 1)
        :set lastPos ($end + 1)
        :set prevStart $start;
    }
}
:log info "Google Subnets updated. Added routes: $addedCount"
