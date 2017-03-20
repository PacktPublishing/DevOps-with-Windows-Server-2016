#DevOps with Windows Server 2016
This is the code repository for [DevOps with Windows Server 2016](https://www.packtpub.com/networking-and-servers/devops-windows-server-2016?utm_source=github&utm_medium=repository&utm_campaign=9781786468550), published by [Packt](https://www.packtpub.com/?utm_source=github). It contains all the supporting project files necessary to work through the book from start to finish.
## About the Book
Delivering applications swiftly is one of the major challenges faced in fast-paced business environments. Windows Server 2016 DevOps is the solution to these challenges as it helps organizations to respond faster in order to handle the competitive pressures by replacing error-prone manual tasks using automation.


##Instructions and Navigation
All of the code is organized into folders. Each folder starts with a number followed by the application name. For example, Chapter02.

Chapter 1,2,9,10, and 11 doesn't contain code. The code present in Chapter 5 is already present in Chapter 6,7 and 8 in form of blocks.

The code will look like the following:
```
{
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('vhdStorageName')]",
      "apiVersion": "2015-06-15",
      "location": "[resourceGroup().location]",
      "tags": {
        "displayName": "StorageAccount"
      },
      "properties": {
        "accountType": "[variables('vhdStorageType')]"
      }
},
```

This book assumes a basic level knowledge on Windows operating system, cloud computing and application development using a web programming language, and moderate experience with the application development life cycle. The book will go through deployment of a sample application on Azure within Windows Containers using a set of virtual machine. This requires a basic understanding of cloud storage, computing, networking, and virtualization concepts on Azure. The book implements DevOps practices using Visual Studio Team Services and basic knowledge of this is expected, although this book tries to cover its foundations. If you have experience with Azure and Visual Studio Team Services, this is a big plus.

A valid Azure subscription and Visual Studio Team Services subscription is needed to get started with this book. They are both available free of cost on a trial basis.

##Related Products
* [DevOps Automation Cookbook](https://www.packtpub.com/networking-and-servers/devops-automation-cookbook?utm_source=github&utm_medium=repository&utm_campaign=9781784392826)

* [PowerShell Troubleshooting Guide](https://www.packtpub.com/networking-and-servers/powershell-troubleshooting-guide?utm_source=github&utm_medium=repository&utm_campaign=9781782173571)

* [Active Directory with PowerShell](https://www.packtpub.com/networking-and-servers/active-directory-powershell?utm_source=github&utm_medium=repository&utm_campaign=9781782175995)

###Suggestions and Feedback
[Click here](https://docs.google.com/forms/d/e/1FAIpQLSe5qwunkGf6PUvzPirPDtuy1Du5Rlzew23UBp2S-P3wB-GcwQ/viewform) if you have any feedback or suggestions.
