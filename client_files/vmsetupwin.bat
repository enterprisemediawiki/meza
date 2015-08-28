@echo off
setlocal EnableDelayedExpansion

::This file accepts 2 parameters: .iso file path and vm name
::Example: vmsetupwin.bat c:\users\bob\downloads CentOS1


::===Notes===
::This file assumes default virtualbox setup (directory locations)
::ie. c:\users\username\.VirtualBox and c:\users\username\VirtualBox VMs
::Prompts desired?
::Long list of OS's necessary?
::Shared Folder is host's desktop. Is this desired?


::Test to see if parameter 1 is set.
if [%1] NEQ [] (
	goto:stage1
) else (
	echo iso file path in parameter 1 is missing. (ie. c:\users\bob\downloads)
	goto:eof
)

::Test to see if parameter 2 is set.
:stage1
if [%2] NEQ [] (
	goto:stage1.1
) else (
	echo.
	echo Virtual Machine name in parameter 2 is missing
	goto:eof
)

::Check if there are virtual machines have the same name.
:stage1.1
for /d %%q in ("c:\users\%username%\VirtualBox VMs\*") do (
	if %2==%%~nq (
		echo.
		echo There is already a virtual machine with the name %2. Please use a different name.
		goto:eof
		)
	)

::Generate list of iso files
:stage2
echo.
set num=0
for /r %1 %%g in (*.iso) do ( 
	set /a num+=1
	echo !num! %%~ng
	set iso!num!=%%g
	)
echo.


::if no iso files found
if %num%==0 (echo No iso file found in %1. Is the iso file path correct?
goto:eof)

::Choose iso file
set /p mychoice=Choose an .iso file (enter number): 
for /l %%i in (1,1,%num%) do (
	if %%i==%mychoice% (
	set isofilepath=!iso%%i!
	)
)
::Setting vm name
if [%2] NEQ [] (
	set vm=%2
) else (
	echo.
	echo Virtual Machine name not found for parameter 2
	goto:eof
)
echo.
echo =List of Operating Systems=
echo.
echo 1 Other/Unknown
echo 2 Windows 3.1
echo 3 Windows 95
echo 4 Windows 98
echo 5 Windows Me
echo 6 Windows NT 4
echo 7 Windows 2000
echo 8 Windows XP
echo 9 Windows XP (64 bit)
echo 10 Windows 2003
echo 11 Windows 2003 (64 bit)
echo 12 Windows Vista
echo 13 Windows Vista (64 bit)
echo 14 Windows 2008
echo 15 Windows 2008 (64 bit)
echo 16 Windows 7
echo 17 Windows 7 (64 bit)
echo 18 Other Windows
echo 19 Linux 2.2
echo 20 Linux 2.4
echo 21 Linux 2.4 (64 bit)
echo 22 Linux 2.6
echo 23 Linux 2.6 (64 bit)
echo 24 Arch Linux
echo 25 Arch Linux (64 bit)
echo 26 Debian
echo 27 Debian (64 bit)
echo 28 openSUSE
echo 29 openSUSE (64 bit)
echo 30 Fedora
echo 31 Fedora (64 bit)
echo 32 Gentoo
echo 33 Gentoo (64 bit)
echo 34 Mandriva
echo 35 Mandriva (64 bit)
echo 36 Red Hat
echo 37 Red Hat (64 bit)
echo 38 Turbolinux
echo 39 Turbolinux (64 bit)
echo 40 Ubuntu
echo 41 Ubuntu (64 bit)
echo 42 Xandros
echo 43 Xandros (64 bit)
echo 44 Oracle
echo 45 Oracle (64 bit)
echo 46 Other Linux
echo 47 Solaris legacy
echo 48 Solaris legacy (64 bit)
echo 49 Solaris modern (S10U8+)
echo 50 Solaris modern (S10U8+) (64 bit)
echo 51 FreeBSD
echo 52 FreeBSD (64 bit)
echo 53 OpenBSD
echo 54 OpenBSD (64 bit)
echo 55 NetBSD
echo 56 NetBSD (64 bit)
echo 57 OS/2 Warp 3
echo 58 OS/2 Warp 4
echo 59 OS/2 Warp 4.5
echo 60 eComStation
echo 61 Other OS/2
echo 62 Mac OS X Server
echo 63 Mac OS X Server (64 bit)
echo 64 DOS
echo 65 Netware
echo 66 L4
echo 67 QNX
echo 68 JRockitVE
echo.

::Choose OS name
set /p osnumber=Choose an Operating System (enter number 1-68):

::Check to see if user enters a number 1-68.
if %osnumber% GEQ 1 (
	goto:check1
	) else (
		echo.
		echo Invalid choice
		goto:eof
		)

:check1
if %osnumber% LEQ 68 (
	goto:check2
	) else (
		echo.
		echo Invalid choice
		goto:eof
		)

::Connect number with OS choice.		
:check2
goto:case%osnumber%
::following was done on excel using &CHAR(10)& for carriage returns...sweet
:case1
set whichos=Other
goto:stage3
:case2
set whichos=Windows31
goto:stage3
:case3
set whichos=Windows95
goto:stage3
:case4
set whichos=Windows98
goto:stage3
:case5
set whichos=WindowsMe
goto:stage3
:case6
set whichos=WindowsNT4
goto:stage3
:case7
set whichos=Windows2000
goto:stage3
:case8
set whichos=WindowsXP
goto:stage3
:case9
set whichos=WindowsXP_64
goto:stage3
:case10
set whichos=Windows2003
goto:stage3
:case11
set whichos=Windows2003_64
goto:stage3
:case12
set whichos=WindowsVista
goto:stage3
:case13
set whichos=WindowsVista_64
goto:stage3
:case14
set whichos=Windows2008
goto:stage3
:case15
set whichos=Windows2008_64
goto:stage3
:case16
set whichos=Windows7
goto:stage3
:case17
set whichos=Windows7_64
goto:stage3
:case18
set whichos=WindowsNT
goto:stage3
:case19
set whichos=Linux22
goto:stage3
:case20
set whichos=Linux24
goto:stage3
:case21
set whichos=Linux24_64
goto:stage3
:case22
set whichos=Linux26
goto:stage3
:case23
set whichos=Linux26_64
goto:stage3
:case24
set whichos=ArchLinux
goto:stage3
:case25
set whichos=ArchLinux_64
goto:stage3
:case26
set whichos=Debian
goto:stage3
:case27
set whichos=Debian_64
goto:stage3
:case28
set whichos=OpenSUSE
goto:stage3
:case29
set whichos=OpenSUSE_64
goto:stage3
:case30
set whichos=Fedora
goto:stage3
:case31
set whichos=Fedora_64
goto:stage3
:case32
set whichos=Gentoo
goto:stage3
:case33
set whichos=Gentoo_64
goto:stage3
:case34
set whichos=Mandriva
goto:stage3
:case35
set whichos=Mandriva_64
goto:stage3
:case36
set whichos=RedHat
goto:stage3
:case37
set whichos=RedHat_64
goto:stage3
:case38
set whichos=Turbolinux
goto:stage3
:case39
set whichos=Turbolinux
goto:stage3
:case40
set whichos=Ubuntu
goto:stage3
:case41
set whichos=Ubuntu_64
goto:stage3
:case42
set whichos=Xandros
goto:stage3
:case43
set whichos=Xandros_64
goto:stage3
:case44
set whichos=Oracle
goto:stage3
:case45
set whichos=Oracle_64
goto:stage3
:case46
set whichos=Linux
goto:stage3
:case47
set whichos=Solaris
goto:stage3
:case48
set whichos=Solaris_64
goto:stage3
:case49
set whichos=OpenSolaris
goto:stage3
:case50
set whichos=OpenSolaris_64
goto:stage3
:case51
set whichos=FreeBSD
goto:stage3
:case52
set whichos=FreeBSD_64
goto:stage3
:case53
set whichos=OpenBSD
goto:stage3
:case54
set whichos=OpenBSD_64
goto:stage3
:case55
set whichos=NetBSD
goto:stage3
:case56
set whichos=NetBSD_64
goto:stage3
:case57
set whichos=OS2Warp3
goto:stage3
:case58
set whichos=OS2Warp4
goto:stage3
:case59
set whichos=OS2Warp45
goto:stage3
:case60
set whichos=OS2eCS
goto:stage3
:case61
set whichos=OS2
goto:stage3
:case62
set whichos=MacOS
goto:stage3
:case63
set whichos=MacOS_64
goto:stage3
:case64
set whichos=DOS
goto:stage3
:case65
set whichos=Netware
goto:stage3
:case66
set whichos=L4
goto:stage3
:case67
set whichos=QNX
goto:stage3
:case68
set whichos=JRockitVE
goto:stage3


:stage3
::change the following variables to suit your needs
SET hostonlyname="VirtualBox Host-Only Ethernet Adapter"
SET storage=10240
SET memory=1024
SET vram=128

 
::This allows you to use vboxmanage without typing out path.
PATH=%PATH%;C:\Program Files\Oracle\VirtualBox

::createhd creates a new virtual hard disk image
::dynamic disk is 10GB
vboxmanage createhd --filename "c:\users\%USERNAME%\VirtualBox VMs\%vm%\%vm%.vdi" --size %storage%

::createvm creates a new XML virtual machine definition file
vboxmanage createvm --name %vm% --ostype %whichos% --register

::storagectl attaches/modifies/removes a storage controller
vboxmanage storagectl %vm% --name "SATA Controller" --add sata --controller IntelAHCI

::storageattach attaches/modifies/removes a storage medium connected 
::to a storage controller that was previously added with the storagectl command
vboxmanage storageattach %vm% --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "c:\users\%USERNAME%\VirtualBox VMs\%vm%\%vm%.vdi"

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





