#!/bin/sh
#
# Generate a VirtualBox VM

echo "This script creates a new virtual machine"

#
# Variables that can be set initially
#
clientOS="RedHat_64"
hostOS="$OSTYPE"
vram=12
username=`whoami`


#
# Prompt for VM name
#
echo
while [ -z "$vmname" ]; do
	read -e -p "New VM name: " vmname
done

#
# Check for host OS and set variables accordingly
#

# For Windows systems
if [ "$hostOS" = "msys" ]; then

	# vboxmanage command path
	vboxm="/c/Program Files/Oracle/VirtualBox/vboxmanage"
	# VirtualBox Guest Additions iso file
	guestadditions="/c/Program Files/Oracle/VirtualBox/VBoxGuestAdditions.iso"

	# VM directory and hard drive location
	userdir="/c/users/$username"
	vmdir="$userdir/VirtualBox VMs/$vmname"
	harddrive="$vmdir/$vmname.vdi"

elif [[ "$hostOS" == darwin* ]]; then

	# vboxmanage command path
	vboxm="/Applications/VirtualBox.app/Contents/MacOS/VBoxManage"
	# VirtualBox Guest Additions iso file
	guestadditions="/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"

	# VM directory and hard drive location
	userdir="$HOME"
	vmdir="$userdir/VirtualBox VMs/$vmname"
	harddrive="$vmdir/$vmname.vdi"

else
	echo
	echo "Your host operating system is not supported."
	exit 1
fi


#
# Check if VM exists (now that we know the OS and know where to look)
#
if [ -d "$vmdir" ]; then
	echo
	echo "ERROR: VM name already exists."
	exit 1
fi


#
# Prompt for path to CentOS ISO file
#
isos="$userdir/*.iso"
echo
echo "Below is a list of ISO files in your user directory ($userdir)"
echo
echo "Please select the correct ISO for your install"
select FILENAME in $isos;
do
	echo
	echo "You picked ISO file:"
	echo "$FILENAME"
	iso=$FILENAME
	break
done


#
# Prompt: Hard Drive Size
#
echo
while [ -z "$storage" ]; do
	read -e -p "Gigabytes of storage: " storage
done
storage="$(($storage * 1024))"


#
# Prompt: RAM
#
while [ -z "$memory" ]; do
	read -e -p "Gigabytes of RAM: " memory
done
memory="$(($memory * 1024))"


#
# Get Host-Only adapter name from vboxmanage command
#
hostonlyadapter=`"$vboxm" list hostonlyifs | grep "^Name:" | sed "s/^Name:[[:space:]]*//"`


#
# If Host-Only adapter is multiple lines, then there are multiple that we can choose from
#
if (( $(grep -c . <<<"$hostonlyadapter") > 1 )); then

	echo

	if [ ! -z "$ZSH_VERSION" ]; then
		echo "Due to an issue with zsh handling of select-menus on string variables,"
		echo "zsh is not supported. Re-run this command in bash."
		exit 1
	fi

	"$vboxm" list hostonlyifs

	echo
	echo "You have multiple Host-Only adapters. Their info is above. Choose which to use below."
	echo

	select adapter in $hostonlyadapter;
	do
		echo "You chose: $adapter"
		hostonlyadapter=$adapter
		break
	done

#
# If Host-Only adapter is blank, create one
#
elif [ -z `"$vboxm" list hostonlyifs` ]; then

	echo
	echo "Your system is not setup with a Host-Only adapter, so one is being created."

	"$vboxm" hostonlyif create

	echo
	echo "Info for the new Host-Only adapter:"
	echo

	# Get host only adapter name again
	hostonlyadapter=`"$vboxm" list hostonlyifs | grep "^Name:" | sed "s/^Name:[[:space:]]*//"`

	echo
	echo "Your host-only adapter info:"
	"$vboxm" list hostonlyifs

fi

#
# Now go forth and create a VM
#

# createhd creates a new virtual hard disk image
"$vboxm" createhd --filename "$harddrive" --size $storage

# createvm creates a new XML virtual machine definition file
"$vboxm" createvm --name "$vmname" --ostype "$clientOS" --register

# storagectl attaches/modifies/removes a storage controller
"$vboxm" storagectl "$vmname" --name "SATA Controller" --add sata --controller IntelAHCI

# storageattach attaches/modifies/removes a storage medium connected
# to a storage controller that was previously added with the storagectl command
"$vboxm" storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$harddrive"

"$vboxm" storagectl "$vmname" --name "IDE Controller" --add ide
"$vboxm" storageattach "$vmname" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$iso"
"$vboxm" storageattach "$vmname" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$guestadditions"
# modifyvm changes the properties of a registered virtual machine which is not running
# audio needs to be fixed
"$vboxm" modifyvm "$vmname" --ioapic on
"$vboxm" modifyvm "$vmname" --boot1 dvd --boot2 disk --boot3 none --boot4 none
"$vboxm" modifyvm "$vmname" --memory "$memory" --vram "$vram"
"$vboxm" modifyvm "$vmname" --nic1 nat
"$vboxm" modifyvm "$vmname" --nic2 hostonly --hostonlyadapter2 "$hostonlyadapter"
"$vboxm" modifyvm "$vmname" --natpf1 "[ssh],tcp,,3022,,22"
"$vboxm" modifyvm "$vmname" --audio null

# Do we want a shared folder?
# sharedfolder="/c/users/$username/desktop"
#"$vboxm" sharedfolder add "$vmname" --name "your_shared_folder" --hostpath "$sharedfolder"
