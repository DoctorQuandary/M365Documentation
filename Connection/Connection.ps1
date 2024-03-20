$ClientID = "e5073001-6efb-4511-9f91-bbf2676910ec"
$TenantID = "77442463-bd3a-43fe-9a24-4506aef9a6b0"

#Possibly Needed to Set specific scopes?

#$settings = Get-Content './settings.json' -ErrorAction Stop | Out-String | ConvertFrom-Json
#$graphScopes = $settings.graphUserScopes

Connect-MgGraph -ClientId $ClientID -TenantId $TenantID -NoWelcome

#-Scopes $graphScopes -UseDeviceAuthentication

#GET https://login.microsoftonline.com/eb14b046-24c4-4519-8f26-b89c2159828c/adminconsent?client_id=27f5542d-08a3-4812-9148-a2043978d859&state=12345
#&redirect_uri=https://localhost/myapp/permissions  HTTP/1.1

# $Connection = Invoke-RestMethod `
#    -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token `
#    -Method POST `
#    -Body $body

# <GetContextSnippet>
# Get the Graph context
Get-MgContext
# </GetContextSnippet>

# <SaveContextSnippet>
$context = Get-MgContext
# </SaveContextSnippet>

# <GetUserSnippet>
# Get the authenticated user by UPN
$user = Get-MgUser -UserId $context.Account -Select 'displayName, id, mail, userPrincipalName'
# </GetUserSnippet>

# <GreetUserSnippet>
Write-Host "Hello," $user.DisplayName
# For Work/school accounts, email is in Mail property
# Personal accounts, email is in UserPrincipalName
Write-Host "Email:", ($user.Mail ?? $user.UserPrincipalName)
# </GreetUserSnippet>

# <GetInboxSnippet>
Get-MgUserMailFolderMessage -UserId $user.Id -MailFolderId Inbox -Select `
  "from,isRead,receivedDateTime,subject" -OrderBy "receivedDateTime DESC" `
  -Top 25 | Format-Table Subject,@{n='From';e={$_.From.EmailAddress.Name}}, `
  IsRead,ReceivedDateTime
# </GetInboxSnippet>

# <DefineMailSnippet>
$sendMailParams = @{
    Message = @{
        Subject = "Testing Microsoft Graph"
        Body = @{
            ContentType = "text"
            Content = "Hello world!"
        }
        ToRecipients = @(
            @{
                EmailAddress = @{
                    Address = ($user.Mail ?? $user.UserPrincipalName)
                }
            }
        )
    }
}
# </DefineMailSnippet>

# <SendMailSnippet>
Send-MgUserMail -UserId $user.Id -BodyParameter $sendMailParams
# </SendMailSnippet>

$apps = Get-MgApplication | Format-List Id, DisplayName, AppId, SignInAudience, PublisherDomain

#Disconnect-MgGraph | Out-Null