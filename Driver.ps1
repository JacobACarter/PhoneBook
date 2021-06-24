cd $PSScriptRoot

$Credential = (Get-Credential)

.\PhoneBook.ps1 $Credential
.\uploadtoSP.ps1 $Credential