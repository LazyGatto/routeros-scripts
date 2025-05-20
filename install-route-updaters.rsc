:log info "Starting installation of Cloudflare & Google IP route updaters..."

# Create routing tables
/routing table
add name=CloudFlareNets fib
add name=GoogleNets fib

# Download update scripts from GitHub (raw)
:local baseURL "https://raw.githubusercontent.com/LazyGatto/routeros-scripts/main"

/tool fetch url=($baseURL . "/update-cloudflare-routes.rsc") dst-path="update-cloudflare-routes.rsc" mode=https
/tool fetch url=($baseURL . "/update-google-routes.rsc") dst-path="update-google-routes.rsc" mode=https
/tool fetch url=($baseURL . "/run-startup-scripts.rsc") dst-path="run-startup-scripts.rsc" mode=https

:delay 3

# Import the downloaded scripts
/import file-name="update-cloudflare-routes.rsc"
/import file-name="update-google-routes.rsc"
/import file-name="run-startup-scripts.rsc"

# Add scheduler for startup and daily run
/system scheduler
add name=routes-on-startup on-event=run-startup-scripts start-time=startup policy=read,write,test
add name=routes-daily on-event=run-startup-scripts start-time=02:00:00 interval=1d policy=read,write,test
:log info "Installation completed successfully"
