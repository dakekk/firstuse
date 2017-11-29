DIR="/mnt/jenkinsftp/ci-jobs/AB7.0"
sub_DIR_1="package/AnyBackupClient"
sub_DIR_2="package/AnyBackupServer"
sub_DIR_3="service"
sub_DIR_4="module"
reserve_pkg_num=50

do_recursive()
{
    for filename in `ls`
    do
         if [ -d "$filename" ]
         then
             cd $filename
             do_recursive
             cd ..
         else
		#echo `pwd`/$filename
		#pwd
		sub_file_num=`ls | wc -l`
		to_del_file_num=`expr $sub_file_num - $reserve_pkg_num`
		#echo $to_del_file_num
		#echo $sub_file_num
		if [ $sub_file_num -gt $reserve_pkg_num ];then
			for i in `ls -tr|head -n $to_del_file_num`
			do
                                echo $i
				rm -f $i
			done
		else
			echo "less than $reserve_pkg_num"
		fi
		return
	fi
    done
}

cd $DIR/$sub_DIR_1
do_recursive

cd $DIR/$sub_DIR_2
do_recursive

cd $DIR/$sub_DIR_3
do_recursive

cd $DIR/$sub_DIR_4
do_recursive

