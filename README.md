# MikroTik Route Updaters: Cloudflare & Google

This repository provides two MikroTik RouterOS scripts that automatically fetch and install updated IPv4 subnets from **Cloudflare** and **Google**, routing them through dedicated routing tables. This setup is useful for traffic shaping, routing policy, or firewall rules targeting these networks.

---

## ✨ Features

- 🔄 Automatic subnet fetching from official sources:
  - Cloudflare: [https://www.cloudflare.com/ips-v4](https://www.cloudflare.com/ips-v4)
  - Google: [https://www.gstatic.com/ipranges/goog.json](https://www.gstatic.com/ipranges/goog.json)
- ✅ Safe parsing and route installation
- 🔃 Deletes outdated routes on each run
- 💡 Fully compatible with MikroTik RouterOS scripting (was tested on RouterOS 7.18.2)
- 🕓 Designed to run on boot and daily via `/system scheduler`

---

## 📦 Scripts Overview

### `update-cloudflare-routes`

- Fetches IPv4 ranges from Cloudflare in plain text format.
- Adds routes to the `CloudFlareNets` routing table.
- Uses `172.16.123.1` as the gateway.

### `update-google-routes`

- Fetches Google’s IP ranges in JSON format.
- Parses all `ipv4Prefix` entries.
- Adds routes to the `GoogleNets` routing table.
- Uses `172.16.123.1` as the gateway.

---

## 🧪 Example Routing Table Configuration

Before using the scripts, make sure the required routing tables exist:

```routeros
/routing table
add name=CloudFlareNets fib
add name=GoogleNets fib
```

---

## 🕓 Scheduled Execution

Both scripts can be executed:

- **At system startup**
- **Daily at 02:00 AM**

### ✅ Option 1: Unified master script (recommended)

Create a master script that runs both updaters:

```routeros
/system script add name=run-startup-scripts source={
    :log info "🔁 Starting route updates..."
    /system script run update-cloudflare-routes
    /system script run update-google-routes
    :log info "✅ All route updates completed."
}
```

Then schedule it:

```routeros
/system scheduler add name=routes-on-startup \
    on-event=run-startup-scripts \
    start-time=startup \
    policy=read,write,test

/system scheduler add name=routes-daily \
    on-event=run-startup-scripts \
    start-time=02:00:00 \
    interval=1d \
    policy=read,write,test
```

---

### ✅ Option 2: Separate schedulers (parallel execution)

```routeros
# Cloudflare script
/system scheduler add name=cf-on-startup \
    on-event=update-cloudflare-routes \
    start-time=startup \
    policy=read,write,test

/system scheduler add name=cf-daily \
    on-event=update-cloudflare-routes \
    start-time=02:00:00 \
    interval=1d \
    policy=read,write,test

# Google script
/system scheduler add name=google-on-startup \
    on-event=update-google-routes \
    start-time=startup \
    policy=read,write,test

/system scheduler add name=google-daily \
    on-event=update-google-routes \
    start-time=02:00:00 \
    interval=1d \
    policy=read,write,test
```

> ⚠️ **Note:** On low-resource devices or where both scripts fetch data simultaneously, it's safer to use the unified execution method.

---

## 📁 Files

- `update-cloudflare-routes.rsc` – Script for Cloudflare IPv4 routing
- `update-google-routes.rsc` – Script for Google IPv4 routing
- `run-startup-scripts.rsc` – (Optional) Master script for unified scheduling
- `README.md` – Documentation and usage instructions

---

## 📜 License

MIT License — feel free to use, adapt, and contribute.

---

## 🙌 Credits

Created by [LazyGatto]  
Inspired by real-world MikroTik routing scenarios and automation needs.
