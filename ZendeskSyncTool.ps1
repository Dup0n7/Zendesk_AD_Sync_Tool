##############################################################
#### ZENDESK AD SYNC TOOL         BY KYLE DUPONT          ####
#### 2017                   https://github.com/Dup0n7     ####
#### Ver. 1.2                                             ####
##############################################################


#### Searches for new users and adds them to the Zendesk System                     ####
#### If users already exist, it will make sure their information is up to date      ####
#### DOES NOT delete deprovisioned users, keeping ticket history for all past users ####
#### Run this script as a scheduled task on a server that can reach your AD and Zendesk environments ####



$[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Email must be a Zendesk admin or service account
$ZenEmail = "email@test.com"

#Generate an API token from your Zendesk Admin Portal
$ZenToken = "addtokenhere"

#Add Zendesk Domain
$URI = https://xxxx.zendesk.com

#OU Path from where in AD you want to sync users
$OU = "OU=Users,OU=Headquarters,dc=mydomain,dc=local"

$Token = "$ZenEmail/token:$ZenToken"
$Base64Token = [System.Convert]::ToBase64String([char[]]$Token);


$Headers = @{
    Authorization = 'Basic {0}' -f $Base64Token;
    'Content-Type' = 'application/json'
        };

$Users = Get-ADUser -SearchBase $OU -SearchScope OneLevel -Filter { (name -ne "Name to filter out here") } -Properties * -ResultSetSize 20000

foreach ($User in $Users)           
{                
    $Name = $User.Name           
    $Email = $User.mail
    $Phone = $User.telephoneNumber
    $Department = $User.Department
    $Location = $User.Office
    $Title = $User.Title
    $Company = $user.Company
    $OfficeNumber = $user.roomNumber
                


## Custom user field data, this can be changed to whatever your company wants to display under the user section.
## Custom user fields must first be created in Zendesk to match the fieldes here.

$CustomFields = @{
    department = "$Department";
    location = "$Location";
    title = "$Title";
    company = "$Company";
    office_number = "$OfficeNumber";
    }
    

## Default user fields

$Data = @{
    name = $Name;
    email = $Email;
    #role = "end-user";
    phone = $Phone;
    time_zone = 'Eastern Time (US & Canada)';
    verified = 'true';
    user_fields = $CustomFields;
    details = "$Location - $OfficeNumber";
    notes = $Company;
    }


$Body = @{user=$Data} | ConvertTo-Json


Invoke-RestMethod -Headers $Headers -Uri "$URI/api/v2/users/create_or_update.json" -Body $Body -Method Post

} 