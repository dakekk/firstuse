##禁用！！------ ftp权限和 安全问题考量！！！！
##手动拷贝如下脚本到ftp ci-jobs所在路径下面执行

DIR="/mnt/jenkinsftp/ci-jobs/$1"
sub_DIR_1="basecore"
sub_DIR_2="client"
sub_DIR_3="server"
sub_DIR_4="package/AnyBackup"
reserve_pkg_num=40

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
