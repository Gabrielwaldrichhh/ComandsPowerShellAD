function Show-Menu
{
     param (
           [string]$Title = 'Infra'
     )
     cls
     Write-Host "================ $Title ================"
    
     Write-Host "1: Criacao de usuarios via Excel"
     Write-Host "2: Colocar o usuario desabilitado para ferias"
     Write-Host "3: LimpaTemporarios."
     Write-Host "4: LimpaAtualizacao"

     Write-Host "Q: Sair."
}
do
{
     Show-Menu
     $input = Read-Host "Selecione"
     switch ($input)
     {
           '1' {
                cls
                #Criacao de usuario do AD em Massa

                #Importacao do mdulo do AD
                Import-Module ActiveDirectory

                #criacao de uma nova senha
                $securePassword = ConvertTo-SecureString "teste123!" -AsPlainText -Force

                #Achar o caminho do arquivo
                $filepath = Read-Host -Prompt "Entre no caminho do arquivo"

                #Import do arquivo CSV
                $users = Import-Csv $filepath

                ##Criacao dos usuarios Excel
                ForEach($user in $users){

                    #Informacoes do Excel (olhar o nome correto da coluna no arquivo csv, renomeie ou troque o valor da string se for preciso)
                    $fname = $user."First Name"
                    $lname = $user."Last Name"
                    $jtitle = $user."Job Title"
                    $officephone = $user."Office Phone"
                    $emailaddress = $user."Email Address"
                    $description = $user.Description
                    $OUpath = $user."Organizational Unit"

                    #Criacao do usuario no AD
                    New-ADUser -Name "$fname $lname" -GivenName $fname -Surname $lname -UserPrincipalName "$fname.$lname" -AccountPassword $securePassword -ChangePasswordAtLogon $True -OfficePhone $officePhone -Description $description -Enabled $True -EmailAddress $emailaddress
                    echo "Contas Criadas $fname $lname in $OUpath $officePhone $description $emailaddress"
                }



           } '2' {
                cls
                Import-Module ActiveDirectory

                    #Achar o caminho do arquivo
                    $filepath = Read-Host -Prompt "Entre no caminho do arquivo"

                    #Import do arquivo CSV
                    $users = Import-Csv $filepath

                    ##Criacao dos usuarios Excel
                    ForEach($user in $users){

                        #Informacoes do Excel (olhar o nome correto da coluna no arquivo csv, renomeie ou troque o valor da string se for preciso)
                        $fname = $user."First Name"
                        $dataferias = $user.'Data Ferias'
                        echo $fname $dataferias

                    Set-ADuser -GivenName $fname -AccountExpirationDate $dataferias
                    }


             } '3' {

                         Function Cleanup { 
                <# 
                DescriÃ§Ã£o do Script:
                Este Script limpa os arquivos temporÃ¡rios em pastas do Windows, na lixeira dos usuÃ¡rios
                e em pastas do spotify e cache do chrome.

                A execuÃ§Ã£o do script nÃ£o danifica o desempenho das mÃ¡quinas.
                #> 
                function global:Write-Verbose ( [string]$Message ) 
    
                # checa a varÃ­avel $VerbosePreference e liga -Verbose
                { if ( $VerbosePreference -ne 'SilentlyContinue' ) 
                { Write-Host " $Message" -ForegroundColor 'Yellow' } } 
    
                $VerbosePreference = "Continue" 
                $DaysToDelete = 0
                $LogDate = $(((get-date).ToUniversalTime()).ToString("dd-MM-yyyy--hh-mm-ss"))
                $objShell = New-Object -ComObject Shell.Application  
                $objFolder = $objShell.Namespace(0xA) 
                $ErrorActionPreference = "silentlycontinue" 
                        
                ## Cria os caminhos caso nÃ£o existam e comeÃ§a a salvar o log no caminho especificado
                New-Item -Path 'C:\Scripts\Infra\Logs' -ItemType Directory
                Start-Transcript -Path C:\Scripts\Infra\Logs\$LogDate.log 
    
                ## Limpa o cÃ³digo da tela
                Clear-Host 
    
                $size = Get-ChildItem C:\Users\* -Include *.iso, *.vhd -Recurse -ErrorAction SilentlyContinue |  
                Sort Length -Descending |  
                Select-Object Name, 
                @{Name="Size (GB)";Expression={ "{0:N2}" -f ($_.Length / 1GB) }}, Directory | 
                Format-Table -AutoSize | Out-String 
    
                $Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName, 
                @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, 
                @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
                @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, 
                @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | 
                Format-Table -AutoSize | Out-String                       
                        
                ## Para o serviÃ§o do Windows Update
                Get-Service -Name wuauserv | Stop-Service -Force -Verbose -ErrorAction SilentlyContinue 
    
                ## Deleta o conteÃºdo da pasta Software Distribution, do Windows.
                Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  

                ## Deleta o conteÃºdo da pasta CCMcache, do Windows.
                Get-ChildItem "C:\Windows\ccmcache\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  

                ## Deleta o conteÃºdo da pasta CCMsetup, do Windows.
                Get-ChildItem "C:\Windows\ccmsetup\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  

                ## Deleta o conteÃºdo da pasta Installer, do Windows
                Get-ChildItem "C:\Windows\Installer\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  
    
                ## Deleta o conteÃºdo da pasta Temp, do Windows || Respeitando a contagem de dias da variÃ¡vel DaysToDelete
                Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
                Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete)) } | 
                remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  

                ## Deleta o conteÃºdo da pasta Spotify, em todos os usuÃ¡rios || Respeitando a contagem de dias da variÃ¡vel DaysToDelete
                Get-ChildItem "C:\users\*\AppData\Local\Spotify\Data\*" -Recurse -Force -ErrorAction SilentlyContinue | 
                Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | 
                remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  

                ## Deleta o conteÃºdo da pasta Cache, do chrome de todos os usuÃ¡rios  || Respeitando a contagem de dias da variÃ¡vel DaysToDelete  
                Get-ChildItem "C:\users\*\AppData\Local\Google\Chrome\User Data\Default\Cache*" -Recurse -Force -ErrorAction SilentlyContinue | 
                Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-$DaysToDelete))} | 
                remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue  
                        
                ## Deleta o conteÃºdo da pasta Temporary Internet Files, de todos os usuÃ¡rios  || Respeitando a contagem de dias da variÃ¡vel DaysToDelete  
                Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" ` 
                -Recurse -Force -Verbose -ErrorAction SilentlyContinue | 
                Where-Object {($_.CreationTime -le $(Get-Date).AddDays(-$DaysToDelete))} | 
                remove-item -force -recurse -ErrorAction SilentlyContinue  
                        
                ## Limpa os logs do IIS, se possÃ­vel
                Get-ChildItem "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue | 
                Where-Object { ($_.CreationTime -le $(Get-Date).AddDays(-60)) } | 
                Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue  
                    
                ## Limpa a lixeira 
                $objFolder.items() | ForEach-Object { Remove-Item $_.path -ErrorAction Ignore -Force -Verbose -Recurse }  
    
                ## Inicia de novo o serviÃ§o do Windows Update
                ##Get-Service -Name wuauserv | Start-Service -Verbose 
    
                $After =  Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName, 
                @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, 
                @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
                @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, 
                @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | 
                Format-Table -AutoSize | Out-String 
    
                ## Envia informaÃ§Ãµes sobre antes&depois do script
    
                Hostname ; Get-Date | Select-Object DateTime 
                Write-Verbose "Before: $Before" 
                Write-Verbose "After: $After" 
                Write-Verbose $size 
                ## Limpeza de arquivos temporÃ¡rios realizada com sucesso! 
                Stop-Transcript } Cleanup
                
                
           }

           '4'{

                Function Cleanup { 
                <# 
                DescriÃ§Ã£o do Script:
                Este Script limpa arquivos de atualizaÃ§Ã£o em pastas Benner, descartÃ¡veis no ambiente Benner:
                - AutoInstall
                - ExportInstall
                - WebEnterpriseSuite
    
                A execuÃ§Ã£o do script nÃ£o danifica o desempenho das mÃ¡quinas.

                A EXECUÃ‡ÃƒO DESTE SCRIPT NÃƒO Ã‰ RECOMENDADA EM AMBIENTE DE PRODUÃ‡ÃƒO
                #> 
                function global:Write-Verbose ( [string]$Message ) 
     
                # checa a varÃ­avel $VerbosePreference e liga -Verbose
                { if ( $VerbosePreference -ne 'SilentlyContinue' ) 
                { Write-Host " $Message" -ForegroundColor 'Yellow' } } 
     
                $VerbosePreference = "Continue"
                $LogDate = $(((get-date).ToUniversalTime()).ToString("dd-MM-yyyy--hh-mm-ss"))
                $objShell = New-Object -ComObject Shell.Application  
                $objFolder = $objShell.Namespace(0xA) 
                $ErrorActionPreference = "silentlycontinue" 
                     
                ## Cria os caminhos caso nÃ£o existam e comeÃ§a a salvar o log no caminho especificado
                New-Item -Path 'C:\Scripts\Infra\Logs' -ItemType Directory
                Start-Transcript -Path C:\Scripts\Infra\Logs\$LogDate.log 
 
                ## Limpa o cÃ³digo da tela
                Clear-Host 

                ## Cria uma tabela para verificar o espaÃ§o em disco, antes e depois da execuÃ§Ã£o do script
                $size = Get-ChildItem C:\Users\* -Include *.iso, *.vhd -Recurse -ErrorAction SilentlyContinue |  
                Sort Length -Descending |  
                Select-Object Name, 
                @{Name="Size (GB)";Expression={ "{0:N2}" -f ($_.Length / 1GB) }}, Directory | 
                Format-Table -AutoSize | Out-String 
                $Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName, 
                @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, 
                @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
                @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, 
                @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | 
                Format-Table -AutoSize | Out-String      

                ## Realiza a remoÃ§Ã£o dos arquivos localizados nos caminhos, de acordo com o filtro aplicado
                gci -Path 'C:\Program Files (x86)\Benner\*' -Recurse -Verbose -Filter exportinstall | Remove-Item -Force -Recurse -Verbose
                gci -Path 'C:\Program Files (x86)\Benner\*' -Recurse -Verbose -Filter autoinstall | Remove-Item -Force -Recurse -Verbose
                gci -Path 'C:\Program Files (x86)\Benner\*' -Recurse -Verbose -Filter webenterprisesuite | Remove-Item -Force -Recurse -Verbose
                gci -Path 'C:\Benner\*' -Recurse -Verbose -Filter exportinstall | Remove-Item -Force -Recurse -Verbose
                gci -Path 'C:\Benner\*' -Recurse -Verbose -Filter autoinstall | Remove-Item -Force -Recurse -Verbose
                gci -Path 'C:\Benner\*' -Recurse -Verbose -Filter webenterprisesuite | Remove-Item -Force -Recurse -Verbose

                ## Envia informaÃ§Ãµes sobre antes & depois do script
                $After =  Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName, 
                @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } }, 
                @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f( $_.Size / 1gb)}}, 
                @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) } }, 
                @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f( $_.FreeSpace / $_.Size ) } } | 
                Format-Table -AutoSize | Out-String 

                Hostname ; Get-Date | Select-Object DateTime 
                Write-Verbose "Before: $Before" 
                Write-Verbose "After: $After" 
                Write-Verbose $size 
    
                Stop-Transcript } Cleanup

           
           }
           

           
                      
            'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')