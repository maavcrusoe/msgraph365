#EXCHANGE
function GetMailboxFolderStatistics {
    param (
        [string]$Title = 'My Menu'
    )
    $prompt = Read-Host -Prompt "Please enter name of user to view their folders!"
    Write-Host "================ $Title ================"
    Get-MailboxFolderStatistics -identity $prompt| Select Name, ItemsInFolder 
}

function FindGroups {
    param (
        [string]$Title = 'My Menu'
    )
    Write-Host "================ $Title ================"
    $Report = [System.Collections.Generic.List[Object]]::new()
    #Write-Host "1: Press '1 inf' "
    $grupos = Get-DistributionGroup -Filter "Name -like '*usuarios*' -or  Name -like 'Z_*'"

    foreach ($grupo in $grupos) {
        Write-Host $grupo -ForegroundColor Yellow
        $ReportLine = [PSCustomObject]@{
            Name    = $grupo
        }      
        $Report.Add($ReportLine) 
    }
    $Report | Out-GridView
}
function UpdateContactSolo {
$n = Read-Host -Prompt "Please enter name of employee to update their contacts!"
$usuarios = Get-Mailbox $n

    #recorrer array usuarios
    foreach ($user in $usuarios) {
        #print para la prueba (sacamos el alias del usuario para importarle los contactos)
        Write-Output "Actualizando contactos para: " $user.alias  -ForegroundColor yellow 
   
        #importar listado contactos añadimos -Force y -confirm:$false para que no pida confirmación
        #antes de importar eliminamos los contactos anitugos que posiblemente tenga importados por este script
        Search-Mailbox -identity $user.alias -searchquery 'kind:contacts AND category:"Importados"' -deletecontent -Force

        #lanzamos otro comando para borrar los contactos antiguos de la categoría Mòbils AMADIP
        Search-Mailbox -identity $user.alias -searchquery 'kind:contacts AND category:"Mòbils AMADIP"' -deletecontent -Force

        Import-ContactList -CSV -CSVData ([System.IO.File]::ReadAllBytes("C:\root\ad.csv")) -Identity $user.alias -confirm:$false

        $Subject = "Contactos importados correctamente para: " + $user.alias
    
        Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -port 587 -from $EmailFrom -to $EmailTo -subject $Subject
    }
    return
}

function ImportByGroups {
    param (
        [string]$Title = 'My Menu'
    )
    Write-Host "================ $Title ================"
    
    $prompt = Read-Host -Prompt "Please enter name of group to update their contacts!"
    $usuarios = Get-DistributionGroupMember $prompt


    #recorrer array usuarios
    foreach ($user in $usuarios) {
        #guardamos en la variable u el nombre de usuario
        $u = $user.alias
        #guardamos en la variable mail el correo del usuario
        $mail = $user.PrimarySmtpAddress
    
        #print para la prueba (sacamos el alias del usuario para importarle los contactos)
        Write-Output "Actualizando contactos para: " $user.alias
    
        #importar listado contactos añadimos -Force y -confirm:$false para que no pida confirmación
        #antes de importar eliminamos los contactos anitugos que posiblemente tenga importados por este script

        Write-Output "Eliminando categoria Importados: " $user.PrimarySmtpAddress
        Search-Mailbox -identity $user.alias -searchquery 'kind:contacts AND category:"Importados"' -deletecontent -Force
    
        Write-Output "Eliminando Mòbils AMADIP: " $user.PrimarySmtpAddress
        #lanzamos otro comando para borrar los contactos antiguos de la categoría Mòbils AMADIP
        Search-Mailbox -identity $user.alias -searchquery 'kind:contacts AND category:"Mòbils AMADIP"' -deletecontent -Force

        #importamos contactos del ad.csv
        Write-Output "Importando contactos: " $user.PrimarySmtpAddress
        Import-ContactList -CSV -CSVData ([System.IO.File]::ReadAllBytes("C:\root\ad.csv")) -Identity $user.alias -confirm:$false

        $Subject = "Contactos importados correctamente para: " + $user.alias
    
        Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -port 587 -from $EmailFrom -to $EmailTo -subject $Subject
 }
    return
}

function GetLicensedAndBloqued {
    param (
        [string]$Title = 'My Menu'
    )
    Write-Host "================ $Title ================"
    $Report = [System.Collections.Generic.List[Object]]::new()
    $licencedAndBloqued = Get-MsolUser -All | ? {$_.isLicensed -eq $true -and $_.BlockCredential -eq $true} | select UserPrincipalName, IsLicensed, BlockCredential
    #write-output $licencedAndBloqued
    foreach ($license in $licencedAndBloqued) {
        Write-Host $grupo -ForegroundColor Yellow
        $ReportLine = [PSCustomObject]@{
            Name    = $license.UserPrincipalName
            IsLicensed    = $license.IsLicensed
            BlockCredential    = $license.BlockCredential
        }      
        $Report.Add($ReportLine) 
    }
    write-host "Total usuarios bloqueados con licencia: "$licencedAndBloqued.count
    $OutputFile = "LicensedAndBloqued_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
    $Report | Sort Name | Export-CSV -NoTypeInformation $PSScriptRoot\export\$OutputFile
    Write-Host "Exported data on" $PSScriptRoot\export\$OutputFile -ForegroundColor Yellow
    $Report | Out-GridView
}

<#function GetLastLogon {
    $prompt = Read-Host -Prompt "Please enter name of user to view their folders!"
    $a = Get-Mailbox –RecipientType 'UserMailbox' | Get-MailboxStatistics | Sort-Object LastLogonTime | Where {$_.LastLogonTime –lt ([DateTime]::Now).AddDays(-30) } | Format-Table DisplayName, LastLogonTime
    write-host $a
}#>

Function ShowLastLogin {
    $prompt = Read-Host -Prompt "Please enter name of user!"
    $user = $prompt + "@amadipesment.org"
    & "$PSScriptRoot\O365UserLoginHistory.ps1" -UserName $user
}

Function Get-TotalUsers {
    $activos = Get-MsolUser -All | ? {$_.isLicensed -eq $true -and $_.BlockCredential -eq $false} | select UserPrincipalName
    return $activos.count
}

function GetStadistics {
    param (
        [string]$Title = 'EXO'
    )
    Write-Host "================ $Title ================"
    $activos = Get-MsolUser -All | ? {$_.isLicensed -eq $true -and $_.BlockCredential -eq $false} | select UserPrincipalName
    $block = Get-MsolUser -All | ? {$_.isLicensed -eq $true -and $_.BlockCredential -eq $true} | select UserPrincipalName
    $unlicensed = Get-MsolUser -UnlicensedUsersOnly | select UserPrincipalName

    write-host "Usuarios:"
    write-host "activos: "$activos.count
    write-host "Licenciados y bloqueados:" $block.count
    write-host "sin licencia/invitados: "$unlicensed.count
    #write-output $unlicensed
    pause
}

#SIGNATURE START
function makesignature {
    $prompt = Read-Host -Prompt "Please enter name of user to make their OWA signature!"
    $prompt = $prompt + "@amadipesment.org"
    write-host $promt
    sigOWA -usuario $prompt
}

#function to compose email signature with all variables and export to .html
function sigOWA{
    param ( $usuario )

    #declare default variables
    $ExportFolder = "\\s-exchange\signature\" #$env:APPDATA\microsoft\signatures

    #declare logo images
    #$fb = "https://icon-icons.com/icons2/1/PNG/32/social_facebook_fb_35.png"
    #$tw = "https://icon-icons.com/icons2/1/PNG/32/social_Twitter_38.png"
    #$ig = "https://icon-icons.com/icons2/1/PNG/32/social_instagram_3.png"
    $telegram = "https://amadipesment.org/firmas/telegram.png"
    $in = "https://amadipesment.org/firmas/in.png"
    $yt = "https://amadipesment.org/firmas/yt.png"

    #declare default url's
    #@esment
    #$urlFB = "https://www.facebook.com/esmentfundacio/"
    #$urlIG = "https://www.instagram.com/esmentfundacio/"
    #$urlTW = "https://twitter.com/esmentfundacio/"
    #@escola prof
    #$urlFBep = "https://www.facebook.com/EsmentEscolaProfessional/"
    #$urlTWep = "https://twitter.com/EsmentEscola"
    #$urlIGep = "https://www.instagram.com/esmentescola/"
    $urlLikedIn = "https://www.linkedin.com/company/amadip-esment/"
    $urlTelegram = "https://t.me/esment"
    $urlYoutube = "https://www.youtube.com/channel/UCoyuanl0iZiO7tgMixZ6Syg"

    #Create the actuall file
    #if (!(Test-Path -Path $ExportFolder)){ mkdir $ExportFolder }
    
    $user=Get-MsolUser -UserPrincipalName $usuario | Where-Object { $_.isLicensed -eq "TRUE" } | Select-Object -property "UserPrincipalName", "DisplayName", "FirstName",  "LastName", "Title", "PhoneNumber", "MobilePhone", "Department"
    $Email=Get-MsolUser -UserPrincipalName $usuario | Select-Object -property proxyAddresses -Expand proxyAddresses | Where {$_ -clike "SMTP:*"}
    
    $UserPrincipalName = $user.UserPrincipalName
    $UserPrincipalName = $UserPrincipalName -replace "@amadipesment.org",""
    $DisplayName=$user.DisplayName;
    $FirstName=$user.FirstName;
    $LastName=$user.LastName;
    $Title=$user.Title;
    $PhoneNumber=$user.PhoneNumber;
    $MobilePhone=$user.MobilePhone;
    $Email= $Email -replace "SMTP:",""
    $url="esment.org"
    $Department=$user.Department
    $logo = ""
    $MobilePhone = splitx3 -number $MobilePhone
     
    if ([string]::IsNullOrEmpty($MobilePhone)) { #CAMPO Telefono NULL
        write-host "Tlf null" -ForegroundColor Yellow
        $MobilePhone = "971 717 773"
    }

    #if departments.. save var logo    
    if ([string]::IsNullOrEmpty($Department)) { #CAMPO DEPARTMENT NULL
        write-host "Firma Esment" -ForegroundColor Yellow
        $logo = "https://amadipesment.org/firmas/Esment1.png"
        #if is empty add to var username, and later send a email
        $msg = $Email
         
        $departmentNULLlist.Add($msg) | Out-Null
        #write-host "AÑADO AL ARRAY"
        #write-host $departmentNULLlist 

        #SendMailO365 -sToEMail "maloy@esment.org" -sEMailSubject "Signature - Department NULL - $userPrincipalName" -sEMailBody $msg
        write-host $logo
    }elseif ($Department -eq "Escola") { #ESCOLA
        write-host "Firma Escola" -ForegroundColor Blue
        $logo = "https://amadipesment.org/firmas/Esment2.png"
        write-host $logo
    }elseif ($Department -eq "Informatica") { #INFORMATICA
        write-host "Firma Informatica" -ForegroundColor Cyan
        $logo = "https://amadipesment.org/firmas/Esment1.png"
        write-host $logo
    }elseif ($Department -eq "Alimentacio") { #ALIMENTACIO
        write-host "Firma ALIMENTACIO" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/EsmentAlimentacio.png"
        write-host $logo
    }elseif ($Department -eq "Restauración") { #ALIMENTACIO
        write-host "Firma ALIMENTACIO" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/EsmentAlimentacio.png"
        write-host $logo
    }elseif ($Department -eq "EE") { #ESCOLA PROFESIONAL
        write-host "Firma ESMENT ESCOLA PROFESIONAL" -ForegroundColor Blue
        $logo = "https://amadipesment.org/firmas/EsmentEscola.png"
        write-host $logo
    }elseif ($Department -eq "EsmentEscola") { #ESCOLA PROFESIONAL
        write-host "Firma ESMENT ESCOLA PROFESIONAL" -ForegroundColor Blue
        $logo = "https://amadipesment.org/firmas/EsmentEscola.png"
        write-host $logo
    }elseif ($Department -eq "TAS") { #ESCOLA PROFESIONAL
        write-host "Firma TAS" -ForegroundColor Blue
        $logo = "https://amadipesment.org/firmas/EsmentEscola.png"
        write-host $logo
    }elseif ($Department -eq "Impremta") { #IMPREMTA
        write-host "Firma IMPREMTA" -ForegroundColor red
        $logo = "https://amadipesment.org/firmas/EsmentImpremta.png"
        write-host $logo
    }elseif ($Department -eq "Jardineria") { #JARDINERIA
        write-host "Firma JARDINERIA" -ForegroundColor Green
        $logo = "https://amadipesment.org/firmas/EsmentJardineria.png"
        write-host $logo
    }elseif ($Department -eq "Audiovisuals") { #AUDIOVISUALS
        write-host "Firma AUDIOVUSUALS" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/Esment1.png"
        write-host $logo
    }elseif ($Department -eq "Infancia") { #INFANCIA
        write-host "Firma ESMENT INFANCIA" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/Esment1.png"
        write-host $logo
    }elseif ($Department -eq "esmentguies") { #ESMENT GUIES
        write-host "Firma ESMENT GUIES" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/Esment1.png"
        write-host $logo
    }elseif ($Department -eq "Serveis") { #SERVEIS
        write-host "Firma ESMENT SERVEIS" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/EsmentServeis.png"
        write-host $logo
    }elseif ($Department -eq "Netetja") { #Netetja
        write-host "Firma ESMENT SERVEIS" -ForegroundColor DarkYellow
        $logo = "https://amadipesment.org/firmas/EsmentServeis.png"
        write-host $logo
    }
       
    else { #DEFAULT LOGO ESMENT 
        write-host "DEFAULT" -ForegroundColor red
        $logo = "https://amadipesment.org/firmas/Esment1.png"
    }
    Write-Host "----------------------------------------------"
    Write-Host "Componemos firma:" -ForegroundColor Green
    Write-Host "usuario:" $UserPrincipalName
    Write-Host $FirstName $LastName
    Write-Host "�"
    Write-Host $Title
    #Write-Host "T. 971 717 773"
    Write-Host "M." $MobilePhone
    Write-Host $Email
    Write-Host $url
    write-host $logo
    write-host $Department
    Write-Host "----------------------------------------------"

#create signature with variables
#solo funciona via OWA
$signatureHTML = @"
    <html>
    <head>
    <link href="http://allfont.es/allfont.css?fonts=futura-bold" rel="stylesheet" type="text/css" />
        <style>


            .signature-futura {
                font-family: Futura,Trebuchet MS,Arial,sans-serif; 
                line-height: 1.1;
                width: 250px;
                color: #cc8a00;
                font-weight:bold;
            }
            hr { 
                background-color: #cc8a00;
                border: none;
                height: 1px;
            }
            .normal {
                font-family: georgial;
                color: #000000;
                line-height: 0.8 !important;
            }
            a, a:link, a:visited, a:hover, a:active  {
                text-decoration: none;
                color: #000000;
            }
            img {
                display: inline-block;
                margin-right:2px;
                margin-top: 2px;
            }

        </style>
    </head>
        <body>
            <div class="signature-futura">
                <b>$FirstName $LastName</b><br>
                <b>$Title</b><br>
            </div>
            <div class="normal">
                � <br>
                M. $MobilePhone <br>
                <a href='mailto:$Email'>$Email</a><br>
                <a href='http://$url'>$url</a><br>
            </div>
            <div>
                <a href='$urlyt'><img src='$yt' height='24' width='24'></a>&nbsp;
                <a href='$urlLikedIn'><img src='$in' height='24' width='24'></a>&nbsp;
                <a href='$urlIG'><img src='$ig' height='24' width='24'></a><br>
            </div>
            <div class="signature-futura">
                <hr width="250px" class="solid">
                <img src='$logo' height='35' width='250'><br>
            </div>
        </body>
    </html>
"@

#funciona en OWA y en Outlook 2016 a lo vintage
$signature = @"

<html>
    <head>
        <style>
            @font-face {font-family: "Futura"; src: url("https://db.onlinewebfonts.com/t/9ab8abd11c40ee5c8d1905f9c9cb9ac8.eot"); src: url("https://db.onlinewebfonts.com/t/9ab8abd11c40ee5c8d1905f9c9cb9ac8.eot?#iefix") format("embedded-opentype"), url("https://db.onlinewebfonts.com/t/9ab8abd11c40ee5c8d1905f9c9cb9ac8.woff2") format("woff2"), url("https://db.onlinewebfonts.com/t/9ab8abd11c40ee5c8d1905f9c9cb9ac8.woff") format("woff"), url("https://db.onlinewebfonts.com/t/9ab8abd11c40ee5c8d1905f9c9cb9ac8.ttf") format("truetype"), url("https://db.onlinewebfonts.com/t/9ab8abd11c40ee5c8d1905f9c9cb9ac8.svg#Futura") format("svg"); }
            @font-face {font-family: "Miller"; src: url("https://db.onlinewebfonts.com/t/b273a0552fe8f530c8584a79d6d43ec5.eot"); src: url("https://db.onlinewebfonts.com/t/b273a0552fe8f530c8584a79d6d43ec5.eot?#iefix") format("embedded-opentype"), url("https://db.onlinewebfonts.com/t/b273a0552fe8f530c8584a79d6d43ec5.woff2") format("woff2"), url("https://db.onlinewebfonts.com/t/b273a0552fe8f530c8584a79d6d43ec5.woff") format("woff"), url("https://db.onlinewebfonts.com/t/b273a0552fe8f530c8584a79d6d43ec5.ttf") format("truetype"), url("https://db.onlinewebfonts.com/t/b273a0552fe8f530c8584a79d6d43ec5.svg#Miller") format("svg"); }

            .futura {
				font-family: "Futura";
                font-weight:bold;
			}
			.mail{
				font-family: "Miller";
			}
        </style>
    </head>
	<table width="250px" border="0" cellspacing="0" cellpadding="0">
	  <tbody>
		<tr>
			<td class="futura" style="font-family: Futura,Trebuchet MS,Arial,sans-serif; line-height: 1.1; width: 250px; color: #000000; font-weight:bold;">
				<b>$FirstName $LastName</b><br>
				<b>$Title</b><br>		
			</td>
		</tr>
		<tr> 
			<td class="mail" style="color: #000000; line-height: 1 !important; padding-bottom:7px;">
                � <br>
				T. $MobilePhone <br>
				E. <a style="text-decoration: none; color: #000000;" href='mailto:$Email'>$Email</a><br>
				<a style="text-decoration: none; color: #000000;" href='http://$url'>www.$url</a><br>
            </td>
        </tr>
        <tr>
            <td class="mail" style="color: #000000; line-height: 1 !important; padding-bottom:7px;">
				<a style="text-decoration: none;" href='$urlYoutube'><img src='$yt' height='24' width='24'></a>&nbsp;
				<a style="text-decoration: none;" href='$urlLikedIn'><img src='$in' height='24' width='24'></a>&nbsp;
				<a style="text-decoration: none;" href='$urlTelegram'><img src='$telegram' height='24' width='24'></a><br>
			</td>
		</tr>
		<tr>
		  <td style="border-top: 1px solid #707070;color: #707070; padding-top:3px;">
		  <img src='$logo' height='35' width='250'>
		  </td>
		</tr>
	  </tbody>
	</table>
		
		</body>
	</html>

"@

        #send signature to 365
        signature -type $signature -usuario $usuario
        #Export signature to .html
        #Write-Host "exportando.."
        #$signature | Out-File "$ExportFolder\$UserPrincipalName.html" -Force
        $signature | Out-File "\\s-exchange\signature\$Email.html" -Force

}

function signature{
    param ( $type, $usuario )
    write-host $type
    write-host $usuario
    Set-MailboxMessageConfiguration -Identity $usuario -AutoAddSignature $True -Signaturehtml $type -defaultfontflag Normal -defaultformat HTML
    write-host "A�adida al OWA" -ForegroundColor Green 
}

#function split tlf number with space
function splitx3 {
    param ( $number )
    ($number -split "([0-9]{3})"  | ?{ $_.length -ne 0 }) -join " "
}
#END SIGNATURE


function GetLoginOWA {
    param (
        [string]$Title = 'My Menu'
    )
    Write-Host "================ $Title ================"
    $Report = [System.Collections.Generic.List[Object]]::new()
    $licencedAndBloqued = Get-MsolUser -All | ? {$_.isLicensed -eq $true -and $_.BlockCredential -eq $true} | select UserPrincipalName, IsLicensed, BlockCredential
    $LoggedOWA = Get-Mailbox -ResultSize:unlimited | Get-MailboxRegionalConfiguration | Where-Object {$null -eq $_.Language} 
    #write-output $licencedAndBloqued
    foreach ($owa in $LoggedOWA) {
        Write-Host $grupo -ForegroundColor Yellow
        $ReportLine = [PSCustomObject]@{
            Name    = $owa.Identity
            timeZone    = $owa.TimeZone
            lang    = $owa.Language
        }      
        $Report.Add($ReportLine) 
    }
    write-host "Total usuarios bloqueados con licencia: "$LoggedOWA.count
    $OutputFile = "LicensedAndBloqued_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
    $Report | Sort Name | Export-CSV -NoTypeInformation $PSScriptRoot\export\$OutputFile
    Write-Host "Exported data on" $PSScriptRoot\export\$OutputFile -ForegroundColor Yellow
    $Report | Out-GridView
}
