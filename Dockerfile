FROM ubuntu:bionic

LABEL version="1.6"
LABEL description="REMnux Build Base Docker based on Ubuntu 18.04 LTS"
LABEL maintainer="https://github.com/fetchered/remnux-build"

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

RUN rm /etc/dpkg/dpkg.cfg.d/excludes && \
apt-get -qq update && dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -y --reinstall && \
rm -r /var/lib/apt/lists/* && apt-get -qq upgrade -y > /dev/null && \
\
apt-get -qq update && apt-get -qq install -y nano less software-properties-common apt-utils man-db wget > /dev/null && \
add-apt-repository -y ppa:sift/stable && \
echo "deb http://www.inetsim.org/debian/ binary/" > /etc/apt/sources.list.d/inetsim.list && \
echo "deb-src http://www.inetsim.org/debian/ source/" >> /etc/apt/sources.list.d/inetsim.list && \
wget -O - https://www.inetsim.org/inetsim-archive-signing-key.asc | apt-key add - && \
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN apt-get -qq update && \
apt-get -qq install -y \
aeskeyfind autoconf binutils build-essential ca-certificates clamav-daemon curl docker.io epic5 feh firefox \
foremost git geany gnupg graphviz imagemagick inetsim inspircd jython libboost-all-dev libboost-python-dev libcanberra-gtk3-module \
libdistorm64-1 libemail-outlook-message-perl libemu2 libffi-dev libfuzzy-dev libgraphviz-dev \
libimage-exiftool-perl libjavassist-java libjpeg-dev libmozjs-52-0 libmozjs-52-dev libncurses5-dev libnetfilter-queue-dev *libolecf* \
libpcap0.8-dev libsqlite3-dev libssl-dev libtool libxml2-dev libxslt1-dev libyara3 libyara-dev linux-image-4.15.0-91-generic ltrace mercurial mono-devel \
netcat nginx ngrep openssh-server p7zip-full pdfresurrect pyew python3-capstone python3-dev python3-pip python3-venv python3-yara python-capstone \
python-dev python-hachoir-* python-httplib2 python-magic python-netifaces python-pip python-pyftpdlib python-urllib3 python-yapsy python-yara qpdf radare2 rhino rsakeyfind ruby-full scalpel \
scite ssdeep ssh strace stunnel sudo swftools swig sysdig tcpdump tcpflow tcpick tcpxtract tor torsocks \
unhide unicode upx-ucl vbindiff wireshark wxhexeditor xdg-utils xpdf yara zlib1g-dev && \
\
apt-get -qq install -y \
cmake gdb bulk-extractor python-pypdf2 python3-pypdf2 python-intervaltree python3-intervaltree python-tabulate python3-tabulate \
python3-future python-q python-pyqt5 python-pyqt5.qtwebkit qt5-default libwebkitgtk-3.0-dev libqt5webkit5-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5 libqt5svg5-dev \
libdouble-conversion-dev && mkdir /run/sshd && rm -rf /var/lib/apt/lists/*

#PIPS
RUN pip install wheel setuptools && pip3 install wheel setuptools && \
#FLARE-FAKENET requirements - Pybindgen must be installed first
pip install pybindgen && \
pip install jsbeautifier xortool cybox olefile distorm3 'pygraphviz==1.3.1' rekall balbuzard funcy plugnplay passivetotal \
enum34 msgpack cxxfilt pyasn1 'pyasn1-modules==0.2.4' && \
#FLARE-FLOSS requirements - needs pylibemu, added later.
pip3 install mitmproxy funcy pdfminer > /dev/null && \
gem install passivedns-client origami pedump > /dev/null && \
#Disass requirements
pip install 'ipython>=0.13.2' 'pefile>=1.2.10-123' 'pytest>=2.2.4' 'pyparsing>=1.5.6' > /dev/null && \
#Just-Metadata requirements
pip install ipwhois requests shodan netaddr && \
#DShell requirements - also libpcap0.8-dev
pip install geoip2 pycrypto dpkt IPy pypcap && \
#mastiff requirement
pip install pydeep && \
#pdfxray_lite requirement
pip install oletools && \
#pev requirement
pip install peepdf && \
#pyfuzzy requirements
pip install ocrd-pyexiftool && pip3 install ocrd-pyexiftool && pip install antlr3-python-runtime && \
#RATDecoders and MalwareConfig requirement
pip install --pre pype32 && \
#RATDecoders functionality required pycryptodome be removed (No XOR support)
pip3 uninstall pycryptodome -y

RUN echo "    X11Forwarding yes" >> /etc/ssh/ssh_config && \
echo "    X11DisplayOffset 10" >> /etc/ssh/ssh_config && \
echo "    PrintMotd no" >> /etc/ssh/ssh_config && \
echo "    PrintLastLog yes" >> /etc/ssh/ssh_config && \
echo "    TCPKeepAlive yes" >> /etc/ssh/ssh_config && \
echo "    ForwardX11 yes" >> /etc/ssh/ssh_config && \
echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

RUN groupadd -r remnux && \
useradd -r -g remnux -d /home/remnux -s /bin/bash -c "REMnux User" remnux && \
mkdir /home/remnux && \
chown -R remnux:remnux /home/remnux && \
usermod -a -G sudo remnux && \
echo 'remnux:remnux' | chpasswd

#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]
