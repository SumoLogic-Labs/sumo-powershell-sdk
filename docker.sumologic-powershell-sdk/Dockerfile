FROM microsoft/powershell:latest

# default environment processing
ENV SUMO_DEPLOYMENT=US2
ENV SUMO_SESSION=true

# print out some demo info about the connection
ENV DEMO=true

#   a demo script to try out.
# This is also a simple way you could add a stuff to execute to a container yourself.
COPY demo.ps1 /home/demo.ps1
RUN chmod +x /home/demo.ps1

COPY TestNewConnection.ps1 /home/TestNewConnection.ps1
RUN chmod +x /home/TestNewConnection.ps1

################################################################
RUN curl -sL https://raw.githubusercontent.com/SumoLogic/sumo-powershell-sdk/master/sumologic/SumoLogic.psm1 -o SumoLogic.psm1 
RUN curl -sL https://raw.githubusercontent.com/SumoLogic/sumo-powershell-sdk/master/sumologic/SumoLogic.psd1 -o SumoLogic.psd1 
RUN mkdir -p /usr/local/share/powershell/Modules/Sumologic
RUN cp SumoLogic.ps* /usr/local/share/powershell/Modules/Sumologic/
RUN mkdir -p /root/.config/powershell
COPY profile.ps1 /root/.config/powershell/profile.ps1
RUN chmod +x /root/.config/powershell/profile.ps1

ENTRYPOINT ["pwsh"]

# to execute your own custom script include this in the container using COPY or map a volume and modify the entrypoint e.g
# ENTRYPOINT ["pwsh","-File","/home/demo.ps1"]
