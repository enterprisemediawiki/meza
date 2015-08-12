@echo off
setlocal EnableDelayedExpansion


::Check to see if parameters are set.
if [%1] NEQ [] (
	goto:parameter2_check
) else (
	goto:parameter_error 
)

:parameter2_check
if [%2] NEQ [] (
	goto:parameter3_check
) else (
	goto:parameter_error
)
:parameter3_check
if [%3] NEQ [] (
	goto:duplicate_vm_check
) else (
	goto:parameter_error
)

::Check if there are virtual machines have the same name.
:duplicate_vm_check
::for every iso file in c:\...VirtualBox VMs 
::if iso file matched %3, terminate
for /d %%q in ("c:\users\%username%\VirtualBox VMs\*") do (
	if %3==%%~nq (
		echo.
		echo There is already a virtual machine with the name %~3. Please use a different name.
		echo.
		goto:eof
		)
	)
set vm=%3


::Assigns variable to each iso file with path and
::determines if any iso files present.
set numb=0
for /r %1 %%g in (*.iso) do (
	set /a numb+=1
	set iso!numb!=%%g
	)

::If no iso files found.
if %numb% EQU 0 (
	echo No iso file was found.
	goto:eof
	)

::Checking the bit parameter.
if %2 EQU 32 (
	set whichos=RedHat
	goto:32bit
	)
if %2 EQU 64 (
	set whichos=RedHat_64
	goto:64bit
	)
echo Invalid OS version choice. Please Enter 32 or 64.
goto:eof

:32bit
::For every iso file in %1 check for default CentOS iso
::If found, keep going. If not, prompt list to choose iso
echo.
for /r %1 %%h in (*.iso) do (
	if %%~nh EQU CentOS-6.6-i386-minimal (
		set isofilepath="%%h"
		echo Using %%~nh
		echo.
		goto:makevm
		)
	)
goto:oslist
	
:64bit
echo.
for /r %1 %%z in (*.iso) do (
	if %%~nz EQU CentOS-6.6-x86_64-minimal (
		set isofilepath="%%z"
		echo Using %%~nz
		echo.
		goto:makevm
		)
	)
goto:oslist

:oslist
echo.
set nu=0
for /r %1 %%g in (*.iso) do ( 
	set /a nu+=1
	echo !nu! %%~ng
	set iso!nu!=%%g
	)
echo.
	
::Choose iso file
::for every possible option, if choice equals option, keep going
set /p mychoice=Choose an .iso file (enter number): 
echo.
for /l %%i in (1,1,%nu%) do (
	if %%i==%mychoice% (
	set isofilepath="!iso%%i!"
	echo Using !iso%%i!
	echo.
	goto:makevm
	)
)
echo Your choice is invalid.
goto:eof


:makevm
::change the following variables to suit your needs
SET hostonlyname="VirtualBox Host-Only Ethernet Adapter"
SET storage=10240
SET memory=1024
SET vram=128


::This allows you to use vboxmanage without typing out path.
PATH=%PATH%;C:\Program Files\Oracle\VirtualBox

::createhd creates a new virtual hard disk image
::dynamic disk is 10GB
vboxmanage createhd --filename "c:\users\%USERNAME%\VirtualBox VMs\%vm:"=%\%vm:"=%.vdi" --size %storage%

::createvm creates a new XML virtual machine definition file
vboxmanage createvm --name %vm% --ostype %whichos% --register

::storagectl attaches/modifies/removes a storage controller
vboxmanage storagectl %vm% --name "SATA Controller" --add sata --controller IntelAHCI

::storageattach attaches/modifies/removes a storage medium connected 
::to a storage controller that was previously added with the storagectl command
vboxmanage storageattach %vm% --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "c:\users\%USERNAME%\VirtualBox VMs\%vm:"=%\%vm:"=%.vdi"

vboxmanage storagectl %VM% --name "IDE Controller" --add ide
vboxmanage storageattach %VM% --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium %isofilepath%
vboxmanage storageattach %VM% --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "c:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso"
::modifyvm changes the properties of a registered virtual machine which is not running
::audio needs to be fixed
vboxmanage modifyvm %vm% --ioapic on
vboxmanage modifyvm %vm% --boot1 dvd --boot2 disk --boot3 none --boot4 none
vboxmanage modifyvm %vm% --memory %memory% --vram %vram%
vboxmanage modifyvm %vm% --nic1 nat
vboxmanage modifyvm %vm% --nic2 hostonly --hostonlyadapter2 %hostonlyname%
vboxmanage modifyvm %vm% --natpf1 [ssh],tcp,,3022,,22
vboxmanage modifyvm %vm% --audio null
vboxmanage sharedfolder add "%vm%" --name "your_shared_folder" --hostpath "c:\users\%username%\desktop"
goto:eof

:parameter_error
echo.
echo This file requires 3 parameters (iso file path, os version, and vm name).
echo Example: vmsetupwin.bat c:\users\bob\downloads 32 CentOSVM
echo Quotes are needed for paths or VM names with spaces.
goto:eof




