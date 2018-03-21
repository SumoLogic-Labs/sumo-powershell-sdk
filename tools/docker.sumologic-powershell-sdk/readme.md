# Run sumologic-powershell-sdk in a .NET Core Docker Container

This is a Linux docker container based on [Powershell for .NET Core / Linux](https://hub.docker.com/r/microsoft/powershell/) that has the [sumologic powershell sdk](https://github.com/SumoLogic/sumo-powershell-sdk) pre-loaded in profile.ps1.

It is a useful if you want to run the sumologick-powershell-sdk as part of a docker based automation. For example having a container that manages sources via the sources API. 

You can also using -it docker run open an interactive pwsh session with the module pre-loaded and a connection already established to the API using supplied environment variables.

# Credentials and Environment
set $Env:SUMO_SESSION and profile.ps1 will also try to establish a new-sumosession with env vars:
- SUMO_DEPLOYMENT
- SUMO_ACCESS_ID
- SUMO_ACCESS_KEY

You can also choose to display some connection info or not on startup with: SHOW_CONNECTION_INFO=true

# Use Entrypoint To Specify Your Own Custom Scripts
By default a pwsh script is the entry point so it's an interactive prompt with the session established. 
You can include your own scripts as entrypoint and execute them instead, say for example to update a bunch of collector sources via the API.
You could do this in say a dockerfile using COPY / run chmod or map a volume.
Then modify the entrypoint e.g
```
ENTRYPOINT ["pwsh","-File","/home/start.ps1"]
```

# How To Run The Container
```
windows powershell
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$Env:SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$Env:SUMO_
ACCESS_KEY -it sumologic-powershell-sdk:latest

bash
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$SUMO_ACCESS_KEY -it sumologic-powershell-sdk:latest
```

# How To Run a Single Command Using the Container
like this:
```
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$SUMO_ACCESS_KEY --env SHOW_CONNECTION_INFO=false -entrypoint=pwsh  sumologic-powershell-sdk:latest -c get-collector -limit 1 -offset 1
```

# Demo Scripts
The container puts two demo scripts in /home/
- demo.ps1
- TestNewConnection.ps1

# How To Build Docker Image
```
docker build -t sumologic-powershell-sdk:latest .
```