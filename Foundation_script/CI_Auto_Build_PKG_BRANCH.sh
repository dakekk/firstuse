if [ ! -e jenkins-cli.jar ];then
    wget http://192.168.123.45:8080/jnlpJars/jenkins-cli.jar
fi

if [ ! -e js.jar ];then
    wget ftp://192.168.123.46/cm-tools/js.jar
fi

CLIP="java -jar jenkins-cli.jar -i js.jar -s http://192.168.123.45:8080/"

SVN="branches/AnyBackup_6_0/dev/AnyBackup_6.0.20_2017_11_14_52294"
APP_PLATFORM="ALL"
LANG="zh-CN"
sign_or_not="YES"
NEED_CLIENT="YES"
ABPREFIX="AB6.0.20"
PKG_TYPE="AnyBackup"

function integrate_client
{
    $CLIP build I_P_CLIENT_ALL \
    -p SVN=$SVN \
    -p APP_PLATFORM=$APP_PLATFORM \
    -p LANG=$LANG \
    -p sign_or_not=$sign_or_not \
    -p PKG_TYPE=$PKG_TYPE \
    -s
}

function integrate_server
{
    $CLIP build I_P_SERVER_ALL \
    -p SVN=$SVN \
    -p APP_PLATFORM=$APP_PLATFORM \
    -p NEED_CLIENT=$NEED_CLIENT \
    -p LANG=$LANG \
    -p sign_or_not=$sign_or_not \
    -p PKG_TYPE=$PKG_TYPE \
    -s
}

function integrate_cinderclient
{
    $CLIP build I_P_CINDERCLIENT \
    -p SVN=$SVN \
    -p APP_PLATFORM=$APP_PLATFORM \
    -p LANG=$LANG \
    -s
}

function integrate_H3CloudOSclient
{
    $CLIP build I_P_H3CloudOSClient \
    -p SVN=$SVN \
    -p APP_PLATFORM=$APP_PLATFORM \
    -p LANG=$LANG \
    -s
}

integrate_client
sleep 3s
integrate_server
sleep 3s
integrate_cinderclient
sleep 3s
integrate_H3CloudOSclient
sleep 3s

#PKG_TYPE="EBackup"
#integrate_client
#sleep 3s
#integrate_server
#sleep 3s
#integrate_cinderclient
#sleep 3s
#integrate_H3CloudOSclient
#sleep 3s


$CLIP build I_P_D_AB_PDT \
-p MY_PKG_APPTYPE=AnyBackup \
-p LANG=zh-CN \
-p ABPREFIX=$ABPREFIX \
-s
