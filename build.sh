#!/bin/sh
echo SOURCECODEURL: "$SOURCECODEURL"
echo PKGNAME: "$PKGNAME"
echo BOARD: "$BOARD"
EMAIL=${EMAIL:-"aa@163.com"}
echo EMAIL: "$EMAIL"
echo PASSWORD: "$PASSWORD"

WORKDIR="$(pwd)"

sudo -E apt-get update
sudo -E apt-get install git  asciidoc bash bc binutils bzip2 fastjar flex gawk gcc genisoimage gettext git intltool jikespg libgtk2.0-dev libncurses5-dev libssl1.0-dev make mercurial patch perl-modules python2.7-dev rsync ruby sdcc subversion unzip util-linux wget xsltproc zlib1g-dev zlib1g-dev -y

git config --global user.email "${EMAIL}"
git config --global user.name "aa"
[ -n "${PASSWORD}" ] && git config --global user.password "${PASSWORD}"

mkdir -p  ${WORKDIR}/buildsource
cd  ${WORKDIR}/buildsource
git clone "$SOURCECODEURL"
cd  ${WORKDIR}


mips_siflower_sdk_get()
{
	 git clone https://github.com/gl-inet-builder/openwrt-sdk-siflower-1806.git openwrt-sdk
}

axt1800_sdk_get()
{
	wget -q -O openwrt-sdk.tar.xz https://fw.gl-inet.com/releases/v21.02-SNAPSHOT/sdk/openwrt-sdk-ipq807x-ipq60xx_gcc-5.5.0_musl_eabi.Linux-x86_64.tar.xz
	mkdir -p ${WORKDIR}/openwrt-sdk
	tar -Jxf openwrt-sdk.tar.xz -C ${WORKDIR}/openwrt-sdk --strip=1
}



case "$BOARD" in
	"SF1200" |\
	"SFT1200" )
		mips_siflower_sdk_get
	;;
	"AXT1800" )
		axt1800_sdk_get
	;;
	*)
esac

cd openwrt-sdk
sed -i "1i\src-link githubaction ${WORKDIR}/buildsource" feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a
echo CONFIG_ALL=y >.config
make defconfig
make V=s ./package/feeds/githubaction/${PKGNAME}/compile

find bin -type f -exec ls -lh {} \;
find bin -type f -name "*.ipk" -exec cp -f {} "${WORKDIR}" \; 
