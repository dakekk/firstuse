yum install -y tk zlib-devel openssl-devel perl cpio expat-devel gettext-devel asciidoc xmlto
yum install perl-ExtUtils-MakeMaker package
yum remove git
wget https://github.com/git/git/archive/v2.10.0.tar.gz
tar zxvf v2.10.0.tar.gz
cd git-2.10.0
make configure
./configure --prefix=/usr/local/git --with-iconv=/usr/local/libiconv
make all doc
make install install-doc install-html
echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
source /etc/bashrc
git --version