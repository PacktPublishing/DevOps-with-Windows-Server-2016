

configuration CreateContainer 
{ 
    # module containing basic DSC resources
    Import-DscResource -ModuleName  'PSDesiredStateConfiguration'    

    Node localhost
    {
        # changing LCM configuration
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        } 
       # placeholder for other DSC resources
       # WindowsFeature Containers 
       # { 
       #     Ensure = "Present" 
       #     Name = "containers"
       # }
   }
} 