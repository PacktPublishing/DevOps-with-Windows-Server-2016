


# Installing NuGet package Provider using PackageManagement Module
Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.201 -force -ForceBootstrap -Confirm:$false -Verbose 

# Installing DockerMsftProvider module 
Install-Module -Name DockerMsftProvider -RequiredVersion "1.0.0.1" -Force -verbose -Confirm:$false -SkipPublisherCheck 

# Downloading Docker daemon binary and storing them in folder created previously
# Install Docker Package using DockerMsftProvider provider
# it enables Container windows feature
# it downloads docker binares and stores them in program files
Install-Package -Name docker -ProviderName DockerMsftProvider -Force -ForceBootstrap -confirm:$false -Verbose 

##Restart the server
#Restart-Computer

# Pull microsoft/windowsservercore image from central repository
docker pull microsoft/windowsservercore

# searching central repository for every image tagged with Microsoft 

docker search microsoft


# Create a new container using the newly downloaded IIS image with
# port 80 on host mapped to port 80 within the container.
# This container executes ping command with localhost as its parameter
docker run -d -p 80:80 microsoft/windowsservercore ping -t localhost