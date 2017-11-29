#prepare
if [ ! -e jenkins-cli.jar ];then
wget http://192.168.123.45:8080/jnlpJars/jenkins-cli.jar
fi
if [ ! -e js.jar ];then
wget ftp://192.168.123.46/cm-tools/js.jar
fi

#CMD
CLIP="java -jar jenkins-cli.jar -i js.jar -s http://192.168.123.45:8080/"
URL_P=http://192.168.123.45:8080/job
URL_F=ftp://192.168.123.46/ci-jobs/$ABPREFIX/package/$MY_PKG_APPTYPE

#if [ "$ABPREFIX" = "AB" ];then
#$CLIP build I_P_SERVER  -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -s | tee logs; [[ $PIPESTATUS = 0 ]] || exit $?
#$CLIP build I_P_AB_Client_All  -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -s | tee logc; [[ $PIPESTATUS = 0 ]] || exit $?
#fi

BAK_TX_PASSWD='Ea8ek&ahP4ke_'
$CLIP build I_D_AB_Server_PDT -p DeployNode=HAT-5R-Server-Infoworks-x64-2 -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -p ABPREFIX=$ABPREFIX -s  || exit $?

if [[ "$MY_PKG_APPTYPE" = "TxCloud" ]]
then
$CLIP build I_D_AB_Server_PDT -p DeployNode=HAT-5R-Server-Infoworks-x64-3 -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -p ABPREFIX=$ABPREFIX -s  || exit $?

$CLIP build I_D_AB_Reboot -s -p NODEIP=192.168.10.69 -p PORT=5557 -p USER=eisoo_ssh -p PASSWD=$BAK_TX_PASSWD || exit $?
$CLIP wait-node-online HAT-5R-Server-Infoworks-x64-3
wget --timeout=1200 http://192.168.10.69:9800/svr/local/common/server_time 2>&1 | grep 'time' || exit 1
fi
#$CLIP build I_D_AB_Reboot -s -p NODEIP=192.168.240.250 -p PORT=5557 -p USER=eisoo_ssh -p PASSWD=$BAK_TX_PASSWD || exit $?
$CLIP build I_D_AB_Reboot
$CLIP wait-node-online HAT-5R-Server-Infoworks-x64-2
wget --timeout=1200 http://192.168.240.250:9800/svr/local/common/server_time 2>&1 | grep 'time' || exit 1

if [[ "$MY_PKG_APPTYPE" = "TxCloud" ]]
then
MediaIP=192.168.10.69
else
MediaIP=192.168.240.250
fi

echo mediaIp=$MediaIP

$CLIP build I_D_AB_Client_Windows_PDT -p ServerIP=$MediaIP -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -p ABPREFIX=$ABPREFIX -s  || exit $?

$CLIP build I_D_AB_Client_Linux_PDT -p ServerIP=$MediaIP -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -p ABPREFIX=$ABPREFIX -s  || exit $?

$CLIP build AT_D_Client_Linux -p SERVERIP=$MediaIP -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -p RunOn=HAT-5R-PUB-Client-ORACLE-RHLE6-x64-2 -p ABPREFIX=$ABPREFIX -s  || exit $?

$CLIP build HAT_5R_SMOKE_RUN_PDT -p MY_PKG_APPTYPE=$MY_PKG_APPTYPE -p ABPREFIX=$ABPREFIX -s || exit $?

AppPackagePath_Server=server/Infoworks_All_x64/${MY_PKG_APPTYPE}Server_Infoworks_All_x64-${LANG}-LASTEST.tar.gz
AppPackagePath_Windows_UI=client/WIN_UI_CLIENT_SIGNED/${MY_PKG_APPTYPE}Client_x64_zh-CN.msi
#AppPackagePath_Windows_UUI=client/WIN_UI_CLIENT_UNSIGNED/${MY_PKG_APPTYPE}Client_x64_zh-CN.msi
AppPackagePath_Windows=client/Windows_All_x64/${MY_PKG_APPTYPE}Client_Windows_All_x64-${LANG}-LASTEST.zip
AppPackagePath_Linux=client/Redhat_5_x64/${MY_PKG_APPTYPE}Client_Redhat_5_x64-${LANG}-LASTEST.tar.gz


wget -nv $URL_F/$AppPackagePath_Server -P package/$MY_PKG_APPTYPE/${AppPackagePath_Server%/*}
wget -nv $URL_F/$AppPackagePath_Windows -P package/$MY_PKG_APPTYPE/${AppPackagePath_Windows%/*}
wget -nv $URL_F/$AppPackagePath_Windows_UI -P package/$MY_PKG_APPTYPE/${AppPackagePath_Windows_UI%/*}
#wget -nv $URL_F/$AppPackagePath_Windows_UUI -P package/$MY_PKG_APPTYPE/${AppPackagePath_Windows_UUI%/*}
wget -nv $URL_F/$AppPackagePath_Linux -P package/$MY_PKG_APPTYPE/${AppPackagePath_Linux%/*}

cd package/$MY_PKG_APPTYPE
echo $AppPackagePath_Windows_UI
echo $AppPackagePath_Windows
echo $AppPackagePath_Linux 
echo $AppPackagePath_Server 

mv $AppPackagePath_Server ${AppPackagePath_Server/-LASTEST./-SMOKEOKPDT.}
mv $AppPackagePath_Linux ${AppPackagePath_Linux/-LASTEST./-SMOKEOKPDT.}
mv $AppPackagePath_Windows_UI ${AppPackagePath_Windows_UI/./-SMOKEOKPDT.}
mv $AppPackagePath_Windows ${AppPackagePath_Windows/-LASTEST./-SMOKEOKPDT.}