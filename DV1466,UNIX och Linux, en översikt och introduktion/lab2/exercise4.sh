#!/bin/bash

export_kernel_version() {
    echo "Exporting Kernel Version..."
    uname -r > kernel_version.txt
    echo "Kernel version exported to kernel_version.txt."
}

export_scheduler_status() {
    echo "Exporting Scheduler Status..."
    cat /proc/schedstat > scheduler_status.txt
    echo "Scheduler status exported to scheduler_status.txt."
}

export_cpu_info() {
    echo "Exporting CPU Information per Core..."
    cat /proc/cpuinfo > cpu_info.txt
    echo "CPU information exported to cpu_info.txt."
}

while true; do
    echo "Please choose an option:"
    echo "1 - Export Kernel Version"
    echo "2 - Export Scheduler Status"
    echo "3 - Export CPU Information per Core"
    echo "q - Quit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            export_kernel_version
            ;;
        2)
            export_scheduler_status
            ;;
        3)
            export_cpu_info
            ;;
        q)
            echo "Exiting the script. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3, or q."
            ;;
    esac

    echo
done