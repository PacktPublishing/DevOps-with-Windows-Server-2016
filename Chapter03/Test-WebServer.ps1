function CreateWebSite
{
    param(
    [string] $appPoolName,
    [string] $websiteName,
    [uint32] $port,
    [string] $websitePath

    )

        New-WebAppPool -Name $appPoolName
        New-Website -Name $websiteName -Port $port -PhysicalPath $websitePath -ApplicationPool $appPoolName -Force
}

Describe "Status of web server" {
    BeforeAll {
        CreateWebSite -appPoolName "TestAppPool" -websiteName "TestWebSite" -port 9999 -websitePath "C:\InetPub\Wwwroot"
    }
    AfterAll {
        Remove-Website -Name "TestWebSite"
        Remove-WebAppPool -Name TestAppPool
    }
    context "is Website already exists with valid values" {
     it "checking whether the website exists" {
        (Get-Website -name "TestWebSite").Name | should be "TestWebSite"
     }
     it "checking if website is in running condition" {
        (Get-Website -name "TestWebSite").State  | should be "Started"
     }
    }
}


