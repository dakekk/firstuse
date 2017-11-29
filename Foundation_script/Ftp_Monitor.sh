function check_disk()
{
    disk_free_percent="`df -h $disk | sed -n "s/.* \([0-9]\+%\).*/\1/p" | cut -d "%" -f 1 `"
    if [  $disk_free_percent -ge 98 ];then
       echo "!!!!!!!!!!!!!!!Disk free space under $disk reached to 98% !! Please use auto-clean-ftp tool-script to cleanout disk space~~"
       exit -1
    else
       echo "~~~~~~~~~~~~~~~Disk free space under $disk is $disk_free_percent ~~"
    fi
}

disk="/"
check_disk
disk="/mnt/jenkinsftp/ci-jobs/AB/package"
check_disk