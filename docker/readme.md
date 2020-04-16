#  sumologic powershell sdk on as a .net core linux container

This is a container based on [powershell for .net core / linux container](https://hub.docker.com/r/microsoft/powershell/) that has the [sumologic powershell sdk](https://github.com/SumoLogic/sumo-powershell-sdk) pre loaded.

# Making a session
If you set SUMO_SESSION to ```true``` on startup the container will iniate a session env vars:
- SUMO_DEPLOYMENT (see https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security). This is converted into the SUMOLOGIC_API_ENDPOINT

## credentials:
https://github.com/SumoLogic/sumo-powershell-sdk#4-start-to-use-cmdlets
- SUMO_ACCESS_ID
- SUMO_ACCESS_KEY

# custom entry point
By default a pwsh prompt is the entry point. .
Then modify the entrypoint e.g
```
ENTRYPOINT ["pwsh","-File","/home/demo.ps1"]
```

# Build the docker container
to build run
```
docker build -t sumologic-powershell-sdk:latest .
```

# Starting the container

## windows powershell
```
docker run --env SUMO_DEPLOYMENT=US2 --env SUMO_ACCESS_ID=$Env:SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$Env:SUMO_
ACCESS_KEY -it sumologic-powershell-sdk:latest
```

## bash
```
docker run --env SUMO_DEPLOYMENT=AU --env SUMO_ACCESS_ID=$SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$SUMO_ACCESS_KEY -it sumologic-powershell-sdk:latest
```

# Running the demo.ps1 script
```
docker run --env SUMO_SESSION=true --env SUMO_DEPLOYMENT=AU --env SUMO_ACCESS_ID=$SUMO_ACCESS_ID --env SUMO_ACCESS_KEY=$SUMO_ACCESS_KEY --entrypoint pwsh  sumologic-powershell-sdk:latest -File /home/demo.ps1
```