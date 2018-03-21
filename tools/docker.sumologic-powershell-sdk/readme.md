# docker container to run sumologic powershell sdk on .net core /linux

This is a container based on [powershell for .net core / linux container](https://hub.docker.com/r/microsoft/powershell/) that has the [sumologic powershell sdk](https://github.com/SumoLogic/sumo-powershell-sdk) pre loaded.

It is a useful if you wanted to say run the powershell sdk on a docker host or as the basis for automation of API functions using the container and adding extra custom scripts or environment vars.

# Credentials and environment
set $Env:SUMO_SESSION and profile.ps1 will also try to establish a new-sumosession with env vars:
- SUMO_DEPLOYMENT
- SUMO_ACCESS_ID
- SUMO_ACCESS_KEY

You can also choose to display some connection info or not on startup with: SHOW_CONNECTION_INFO=true

# Entrypoint
By default a pwsh script is the entry point so it's an interactive prompt with the session established. 
You can include your own scripts as entrypoint and execute them instead, say for example to update a bunch of collector sources via the API.
You could do this in say a dockerfile using COPY / run chmod or map a volume.
Then modify the entrypoint e.g
```
ENTRYPOINT ["pwsh","-File","/home/start.ps1"]
```

# Simple usage
```
windows powershell
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$Env:SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$Env:SUMO_
ACCESS_KEY -it sumologic-powershell-sdk:latest

bash
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$SUMO_ACCESS_KEY -it sumologic-powershell-sdk:latest
```

# run a single command using the container
like this:
```
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$SUMO_ACCESS_KEY --env SHOW_CONNECTION_INFO=false -entrypoint=pwsh  sumologic-powershell-sdk:latest -c get-collector -limit 1 -offset 1
```

# demo scripts
The container puts two demo scripts in /home/
- demo.ps1
- TestNewConnection.ps1

# to build run
```
docker build -t sumologic-powershell-sdk:latest .
```