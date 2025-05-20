# routeros-scripts

## update-cloudflare-routes
Cloudflare Network Routes Updater Script for MikroTik RouterOS

This RouterOS script automatically downloads the latest list of Cloudflare IPv4 networks from the official URL (https://www.cloudflare.com/ips-v4) and installs them as static routes into a dedicated routing table.

## update-google-nets
Google IPs Routes Updater Script for MikroTik RouterOS

This RouterOS script automatically downloads the latest list of Google IPv4 networks from the URL (https://www.gstatic.com/ipranges/goog.json) and installs them as static routes into a dedicated routing table.

### 🕓 Scheduled Execution
To run the script automatically:
At system startup
Once daily at 02:00 AM
Use the following scheduler entries:
### Run on every reboot
```
/system scheduler add name=cf-on-startup \
    on-event=update-cloudflare-routes \
    start-time=startup \
    policy=read,write,test
```
### Run daily at 02:00 AM
```
/system scheduler add name=cf-daily \
    on-event=update-cloudflare-routes \
    start-time=02:00:00 \
    interval=1d \
    policy=read,write,test
```
Replace `update-cloudflare-routes` with the exact name of your script (case-sensitive).
