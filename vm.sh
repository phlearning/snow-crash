#!/bin/bash
# based on a script made by https://github.com/shaolin-peanut for his OCAML Piscine
# and one by https://github.com/t-h2o for his Inception

RED="\033[0;31m"
GREEN="\033[0;32m"
RESET="\033[0m"
YELLOW="\033[0;33m"

# Variables to fill
GOINFRE="/goinfre/$(whoami)" # folder to use to download/extract ! goinfre is only on the mac at school !
RAM_SIZE="2048"
URL_DOWNLOAD="https://cdn.intra.42.fr/isos/SnowCrash.iso"
ISO_PATH="${GOINFRE}/SnowCrash.iso" # path to the iso in the goinfre
VM_NAME="$(hostname -s)-snowcrash-$(whoami)"
OS_TYPE="Ubuntu_64" # use 'VBoxManage list ostypes' to list the available OS types, use the ID field of the wanted OS
PORT_FORWARDING_HOST="4242"

download_iso() {
    echo "ISO file not found"

    echo -e "${GREEN}Starting download of the ISO from ${URL_DOWNLOAD} to ${ISO_PATH} ${RESET}\n"

    curl -L -o "${ISO_PATH}" "${URL_DOWNLOAD}"

    echo -e "${GREEN}The iso is ready at ${ISO_PATH}${RESET}\n"
}

create_vm() {
    if [ ! -f "${ISO_PATH}" ]; then
        download_iso
    fi

    if VBoxManage list vms | grep -q "\"${VM_NAME}\""; then
        echo -e "${RED}VM '${VM_NAME}' already exists. Returning to menu.${RESET}"
        main
    fi

    echo -e "${YELLOW}Creating VirtualBox VM '${VM_NAME}'...${RESET}"
    VBoxManage createvm --name "${VM_NAME}" --ostype "${OS_TYPE}" --register
    VBoxManage modifyvm "${VM_NAME}" --memory "${RAM_SIZE}" --cpus 4 --nic1 nat
    VBoxManage modifyvm "${VM_NAME}" --nat-pf1 "Rule 1,tcp,127.0.0.1,${PORT_FORWARDING_HOST},10.0.2.15,80"
    VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAHCI
    VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"
    VBoxManage modifyvm "${VM_NAME}" --audio-driver none
    VBoxManage modifyvm "${VM_NAME}" --vram 32

    echo -e "${GREEN}VirtualBox VM '${VM_NAME}' successfully created${RESET}"
}

start_vm() {
    vm_status=$(VBoxManage showvminfo "${VM_NAME}" | grep -q -c "running (since")
    if [ "${vm_status}" ] ; then
        echo -e "${GREEN}VM ${VM_NAME} already running${RESET}"
    else
        VBoxManage startvm "${VM_NAME}"
        echo -e "${GREEN}VM ${VM_NAME} started${RESET}"
    fi
}

poweroff_vm() {
    running_vm=$(VBoxManage showvminfo "${VM_NAME}" | grep -q -c "running (since")
    if [ -z "${running_vm}" ]; then
        VBoxManage controlvm "${VM_NAME}" poweroff
        echo -e "${GREEN}VM ${VM_NAME} powered off${RESET}\n"
    else
        echo -e "${RED}No VM ${VM_NAME} to power off${RESET}\n"
    fi
}

delete_vm() {
    # Get the raw list: "Name" {UUID}
    mapfile -t vms_raw < <(VBoxManage list vms)
    
    if [ ${#vms_raw[@]} -eq 0 ]; then
        echo -e "${RED}No VMs found.${RESET}"; return
    fi

    echo -e "\n${YELLOW}--- Delete VM ---${RESET}"
    echo "[0] BACK"
    
    # Store just the names/UUIDs in an array for logic
    declare -a vms_names
    declare -a vms_uuids

    for i in "${!vms_raw[@]}"; do
        # Extract name (between quotes) and UUID (between braces)
        name=$(echo "${vms_raw[$i]}" | cut -d '"' -f 2)
        uuid=$(echo "${vms_raw[$i]}" | cut -d '{' -f 2 | cut -d '}' -f 1)
        vms_names[$i]="$name"
        vms_uuids[$i]="$uuid"
        echo "[$((i + 1))] $name {$uuid}"
    done

    read -p "Enter Index, Name, or ID (min 3 chars): " choice
    [[ "$choice" == "0" || -z "$choice" ]] && return

    target=""
    # 1. Match by Index
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#vms_names[@]}" ]; then
        # If it's inaccessible, we MUST use the UUID
        if [ "${vms_names[$((choice - 1))]}" == "<inaccessible>" ]; then
            target="${vms_uuids[$((choice - 1))]}"
        else
            target="${vms_names[$((choice - 1))]}"
        fi
    # 2. Match by Prefix (Name or UUID)
    elif [ ${#choice} -ge 3 ]; then
        # Search raw list for any line starting with or containing the choice
        match=$(VBoxManage list vms | grep -i "${choice}" | head -n 1)
        name_match=$(echo "$match" | cut -d '"' -f 2)
        uuid_match=$(echo "$match" | cut -d '{' -f 2 | cut -d '}' -f 1)
        
        if [ "$name_match" == "<inaccessible>" ]; then target="$uuid_match"; 
        else target="$name_match"; fi
    fi

    if [ -n "$target" ]; then
        read -p "Delete '$target'? (y/n): " confirm
        if [[ "$confirm" == [yY] ]]; then
            # 'unregistervm' works on UUIDs even if the VM is inaccessible
            VBoxManage unregistervm "$target" --delete
            echo -e "${GREEN}VM '$target' removed.${RESET}"
        fi
    else
        echo -e "${RED}No match found.${RESET}"; delete_vm
    fi
}

menu() {
    echo "VirtualBox VM Manager Script:"
    echo "[1] Create VM"
    echo "[2] Start VM"
    echo "[3] Poweroff VM"
    echo "[4] Delete VM"
    echo "[5] Exit"
    read -p "Choose an option [1-5]: " choice

    if [[ $choice -ge 1 && $choice -le 5 ]]; then
        return $choice
    else
        echo -e "\n${RED}Invalid choice. Try again${RESET}\n"
        menu
    fi
}

main() {
    if [ -z "${URL_DOWNLOAD}" ] || [ -z "${ISO_PATH}" ] || \
        [ -z "${VM_NAME}" ] || [ -z "${OS_TYPE}" ]; then
        echo -e "${RED}One or more required variables are empty.${RESET}"
        echo "The variables to check are URL_DOWNLOAD, ISO_PATH, VM_NAME and OS_TYPE."
        exit 1
    else
        echo "--------------------"
        echo -e "${GREEN}All variables are set correctly.${RESET}"
        echo "--------------------"
    fi

    menu

    answer=$?
    if [ "${answer}" -eq 1 ]; then
        create_vm
    elif [ "${answer}" -eq 2 ]; then
        start_vm
    elif [ "${answer}" -eq 3 ]; then
        poweroff_vm
    elif [ "${answer}" -eq 4 ]; then
        delete_vm
    elif [ "${answer}" -eq 5 ]; then
        exit 1
    fi

    main
}

main