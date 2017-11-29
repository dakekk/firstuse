echo ">>>>>>>>>>>>>>> batch configuration >>>>>>>>>>>>>>>"
usr_passwd_45="ma.han:mh@XHY2017"
usr_passwd_250="admin:admin"
parse_string='<hudson.model.ChoiceParameterDefinition>'
parse_string_2='<a class="string-array">'
rm -rf tmp_modify_xml
if [ ! -d tmp_modify_xml ];then
    mkdir tmp_modify_xml
fi
if [ ! -d important_bak_xml ];then
    mkdir important_bak_xml
fi
svn cat http://192.168.6.20:18080/svn/AnyBackup/5R/${SVN}/5r/CI_hudson/config.xml > config.xml

function config_DEV()
{
usr_passwd=$usr_passwd_45
i=`cat config.xml | sed -n "/<VIEW>_AB_DEV<\/VIEW>/="`
i=`expr $i + 1`
while true;do
    job_name=`sed -n "${i}p" config.xml | sed -n "s/.*<NAME>\(.*\)<\/NAME>/\1/p"`
    if [ "${job_name}" != "" ];then
        echo ">>>>>>>>>>>>>>> update job: $job_name"
        src_xml="http://192.168.123.45:8080/job/${job_name}/config.xml"
	dest_xml="tmp_modify_xml/45_${job_name}.xml"
	backup_xml="important_bak_xml/45_${job_name}_`date +%Y%m%d_%H%M%S`.xml"
        curl -u $usr_passwd $src_xml -o $dest_xml
        cp $dest_xml $backup_xml
        modify_xml
        #post_xml
    else
        break
    fi
    sleep 1
    i=`expr $i + 1`
done
}

function config_XIAOJI()
{
usr_passwd=$usr_passwd_250
i=`cat config.xml | sed -n "/<VIEW>_AB_XIAOJI<\/VIEW>/="`
i=`expr $i + 1`
while true;do
    job_name=`sed -n "${i}p" config.xml | sed -n "s/.*<NAME>\(.*\)<\/NAME>/\1/p"`
    if [ "${job_name}" != "" ];then
        echo ">>>>>>>>>>>>>>> update job: $job_name"
        src_xml="http://192.168.250.250:8080/job/${job_name}/config.xml"
	dest_xml="tmp_modify_xml/250_${job_name}.xml"
	backup_xml="important_bak_xml/250_${job_name}_`date +%Y%m%d_%H%M%S`.xml"
        curl -u $usr_passwd $src_xml -o $dest_xml
        cp $dest_xml $backup_xml
        modify_xml
        #post_xml
    else
        break
    fi
    sleep 1
    i=`expr $i + 1`
done
}


function modify_xml()
{
	idx=1
	while true;do
		line=`cat $dest_xml | sed -n "/${parse_string}/=" | sed -n "${idx}p"`
		if [ "${line}" = "" ];then
			break;
		else
			line=`expr $line + 1`
			if [ "`sed -n "${line}p" $dest_xml | sed 's/^[ \t]*//g'`" = "<name>SVN</name>" ];then
				while true;do
					line=`expr $line + 1`
					if [ "`sed -n "${line}p" $dest_xml | sed 's/^[ \t]*//g'`" = "${parse_string_2}" ];then
						break;
					fi
				done
				insert_str=`cat $dest_xml | sed -n "${line}p" | sed "s#^\([ \t]*\).*#\1  <string>$SVN</string>#"`
				sed -i "${line}a\\${insert_str}" $dest_xml

                        elif [ "`sed -n "${line}p" $dest_xml | sed 's/^[ \t]*//g'`" = "<name>WKSP</name>" ];then
				while true;do
					line=`expr $line + 1`
					if [ "`sed -n "${line}p" $dest_xml | sed 's/^[ \t]*//g'`" = "${parse_string_2}" ];then
						break;
					fi
				done
				insert_str=`cat $dest_xml | sed -n "${line}p" | sed "s#^\([ \t]*\).*#\1  <string>$WKSP</string>#"`
				sed -i "${line}a\\${insert_str}" $dest_xml
                        fi
                fi
		idx=`expr $idx + 1`
	done
        echo "modify $dest_xml OK"
}

function post_xml()
{
	curl -X POST ${src_xml} -u ${usr_passwd} --data-binary "@${dest_xml}"
	echo "post $dest_xml OK"
}


#config_DEV
#config_XIAOJI

