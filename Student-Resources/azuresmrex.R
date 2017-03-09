
azureCreateStorageAccount(sc, 
                          location = "centralus", 
                          storageAccount = "azsasvc", 
                          resourceGroup = "azsvctrain")


azureCreateHDI(sc, 
               clustername = "azsparkgh", 
               location = "centralus",
               storageAccount = "azghsa", 
               resourceGroup = "azcs224n", 
               componentVersion = "3.5",
               version = "3.5", 
               kind = "rserver", 
               workers = 4, 
               vmSize = "Standard_D13_V2",
               adminUser = "admin", 
               adminPassword = passwd, 
               sshUser = "alizaidi", 
               sshPassword = passwd)
