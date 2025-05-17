#!/bin/bash


enable_service() {
    systemctl enable $1
    systemctl start $1
    systemctl restart $1
    echo -e "\e[32mService $1 enabled and started.\e[0m"
}

disable_service() {
    systemctl stop $1
    systemctl disable $1
    echo -e "\e[31mService $1 stopped and disabled.\e[0m"
}

display_status() {
    systemctl is-active --quiet $1
    if [ $? -eq 0 ]; then
        echo -e "Service $1 is \e[32mrunning\e[0m."
    else
        echo -e "Service $1 is \e[31mnot running\e[0m."
    fi
}

display_menu() {
    echo -e "Current service status:"
    display_status "limitipvmess"
    display_status "limitipvless"
    display_status "limitiptrojan"
    display_status "limitipss"
    display_status "limitipss2022"
    display_status "limitipsocks"
    echo
    echo "1. Enable Services"
    echo "2. Disable Services"
    echo "0. Quit"
    echo
    echo -n "Enter your choice: "
}

while true; do
    display_menu
    read -r choice
    echo

    case $choice in
        1)
            echo -e "\nEnabling services..."
            enable_service "limitipvmess"
            enable_service "limitipvless"
            enable_service "limitiptrojan"
            enable_service "limitipss"
            enable_service "limitipss2022"
            enable_service "limitipsocks"
            ;;
        2)
            echo -e "\nDisabling services..."
            disable_service "limitipvmess"
            disable_service "limitipvless"
            disable_service "limitiptrojan"
            disable_service "limitipss"
            disable_service "limitipss2022"
            disable_service "limitipsocks"
            ;;
        0)
	    clear
            echo "Exiting..."
            break
            ;;
        *)
            echo -e "\nInvalid choice. Please try again."
            ;;
    esac

    echo
done
