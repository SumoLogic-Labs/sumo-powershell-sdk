FROM microsoft/powershell:latest

# default environment processing
#ENV SUMO_DEPLOYMENT=US2
ENV SUMO_SESSION=false

# A simple script to get up to 10 collectors via the API
COPY demo.ps1 /home/demo.ps1
RUN chmod +x /home/demo.ps1

# put more stuff in the container yourself say another script
#COPY myfile.ps1 /home/myfile.ps1
#RUN chmod +x /home/myfile.ps1

################################################################
RUN mkdir ./psm 
RUN pwsh -c "Save-Module SumoLogic-Core -Path ./psm -Repository PSGallery"

# setup a profile to launch the module import and a connection if session=true
RUN mkdir -p /root/.config/powershell
COPY profile.ps1 /root/.config/powershell/profile.ps1
RUN chmod +x /root/.config/powershell/profile.ps1

ENTRYPOINT ["pwsh"]

# to execute your own custom script include this in the container using COPY or map a volume and modify the entrypoint e.g
# ENTRYPOINT ["pwsh","-File","/home/demo.ps1"]
