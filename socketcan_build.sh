#! /bin/bash

export HOSTCC=gcc

WORKSPACE_PATH=$(readlink -f "$(dirname "$0")")
TOOLCHAINS_PATH=/opt/toolchains

PTHREAD_NAME=socketcan_source
TAR_NAME=libsocketcan.tar.gz

PRJ_INSTALL_PATH=${WORKSPACE_PATH}/install/aarch64_linux

function libsocketcan_unzip()
{
   local TAR_PATH=$1
   local SOURCE_PATH=$2

   # tar -vxf
   if [ ! -d ${SOURCE_PATH} ];then
      mkdir -p ${SOURCE_PATH}

      tar -vxf ${TAR_PATH} --strip-components 1 -C ${SOURCE_PATH}
		
		cd ${SOURCE_PATH}/
      ./autogen.sh 
		cd -
   fi

  return 0
}

function x86_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=${TOOLCHAINS_PATH}/${PLATFORM_SYS}
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   libcap_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

   if [ ! -e ${TOOLCHAIN_PATH}/setup.sh ]; then 
      echo "\033[31m[ERROR] toolchain path ${PLATFORM_SYS} setup.sh LoSe!!! \033[0m"

      exit 1
   fi
      # source env
   source ${TOOLCHAIN_PATH}/setup.sh

   mkdir -p ${PRJ_BUILD_PATH}
   rm -rf ${PRJ_BUILD_PATH}/*
   cp -a ${TAR_BUILD_PATH}/${PTHREAD_NAME}/* ${PRJ_BUILD_PATH}/

   # mkdir build dir
   cd ${PRJ_BUILD_PATH}
   if [ ! -d build ];then
       mkdir build
   fi 
 
   make clean
   make \
   CC="${CC} --sysroot=${SYSROOT}"    \
   CXX="${CXX} --sysroot=${SYSROOT}"  \
   RAISE_SETFCAP=no \
   -j8

   # make install
   rm -rf ${PRJ_INSTALL_PATH}
   mkdir -p ${PRJ_INSTALL_PATH}/usr

   make  install \
         DESTDIR=${PRJ_INSTALL_PATH} \
         prefix=/usr \
         libdir=/usr/lib64 \
         sbindir=/sbin
   
   return 0
}
function aarch64_linux_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=${TOOLCHAINS_PATH}/${PLATFORM_SYS}
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   libcap_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

   if [ ! -e ${TOOLCHAIN_PATH}/setup.sh ]; then 
      echo "\033[31m[ERROR] toolchain path ${PLATFORM_SYS} setup.sh LoSe!!! \033[0m"

      exit 1
   fi

# source env
source ${TOOLCHAIN_PATH}/setup.sh

   mkdir -p ${PRJ_BUILD_PATH}
   rm -rf ${PRJ_BUILD_PATH}/*
   cp -a ${TAR_BUILD_PATH}/${PTHREAD_NAME}/* ${PRJ_BUILD_PATH}/

   # mkdir build dir
   cd ${PRJ_BUILD_PATH}
   if [ ! -d build ];then
       mkdir build
   fi 

   # 编译前清理
   make clean

   cd ./libcap

   grep -E '^#define\s+CAP_([^\s]+)\s+[0-9]+\s*$' include/uapi/linux/capability.h | \
   sed -e 's/^#define\s\+/{"/' \
      -e 's/\s*$/},/' \
      -e 's/\s\+/",/' \
      -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' > cap_names.list.h

   # 先用主机 GCC 编译 _makenames
   ${HOSTCC} _makenames.c -o _makenames
   #gcc -o _makenames _makenames.c
   cd -



   make \
   CC="${CC} --sysroot=${SYSROOT}" \
   AR="${AR}" \
   RANLIB="${RANLIB}" \
   HOSTCC="gcc" \
   CFLAGS="-fPIC  -I${SYSROOT}/usr/include" \
   LDFLAGS="-L${SYSROOT}/usr/lib" \
   RAISE_SETFCAP=no \
   -j8

#  --libexecdir=/usr/libexec \
   # make

   # make install
   rm -rf ${PRJ_INSTALL_PATH}
   mkdir -p ${PRJ_INSTALL_PATH}

   make  install \
         DESTDIR=${PRJ_INSTALL_PATH} \
         prefix=/usr \
         libdir=/usr/lib64 \
         sbindir=/sbin

   return 0
}


function arm32_linux_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=/toolchains/armhf_none_9.2_2019.12
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   libsocketcan_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

   if [ ! -e ${TOOLCHAIN_PATH}/setup.sh ]; then 
      echo "\033[31m[ERROR] toolchain path ${PLATFORM_SYS} setup.sh LoSe!!! \033[0m"

      exit 1
   fi

   # source env
   source ${TOOLCHAIN_PATH}/setup.sh

   mkdir -p ${PRJ_BUILD_PATH}/
   rm -rf ${PRJ_BUILD_PATH}/*
   cp -a ${TAR_BUILD_PATH}/${PTHREAD_NAME}/* ${PRJ_BUILD_PATH}/

   # mkdir build dir
   cd ${PRJ_BUILD_PATH}
   if [ ! -d build ];then
       mkdir build
   fi 
   cd build

   ../configure                       \
   --host=arm-none-linux              \
   CC="${CC} --sysroot=${SYSROOT}"    \
   CXX="${CXX} --sysroot=${SYSROOT}"  \
   --prefix=${PRJ_INSTALL_PATH}


   # make
   make -j16

   # make install
   rm -rf ${PRJ_INSTALL_PATH}
   mkdir -p ${PRJ_INSTALL_PATH}
   make install


   return 0
}

function aarch64_qnx710_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=${TOOLCHAINS_PATH}/${PLATFORM_SYS}
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   protobuf_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

   if [ ! -e ${TOOLCHAIN_PATH}/setup.sh ]; then 
      echo "\033[31m[ERROR] toolchain path ${PLATFORM_SYS} setup.sh LoSe!!! \033[0m"

      exit 1
   fi

   # source env
   source ${TOOLCHAIN_PATH}/setup.sh

   mkdir -p ${PRJ_BUILD_PATH}
   rm -rf ${PRJ_BUILD_PATH}/*
   cp -a ${TAR_BUILD_PATH}/${PTHREAD_NAME}/* ${PRJ_BUILD_PATH}/

   # mkdir build dir
   cd ${PRJ_BUILD_PATH}
   if [ ! -d build ];then
       mkdir build
   fi 
   cd build

   CXXFLAGS="-U__QNX__ -D__aarch64__"    \
   ../configure                          \
   --host=aarch64-unknown-nto-qnx7.1.0   \
   CC="${CC} --sysroot=${SYSROOT}"       \
   CXX="${CXX} --sysroot=${SYSROOT}"     \
   --prefix=${PRJ_INSTALL_PATH}          \
   --with-protoc=/usr/bin/protoc   


   # make
   make -j16

   # make install
   rm -rf ${PRJ_INSTALL_PATH}
   mkdir ${PRJ_INSTALL_PATH}
   make install
   return 0
}

distclean_buid()
{
   rm -rf ${WORKSPACE_PATH}/build

   return 0
}

install_env()
{
   apt-get install libmnl-dev -y
   apt-get install bison m4 -y
   return 0
}
function do_once_menu()
{

   if [ ! -d ${TOOLCHAINS_PATH} ]; then 
      echo -e "\033[31m[ERROR] toolchain path LoSe!!! \033[0m"
      echo -e "\033[33m[Warrning] Configure the tool link path correctly... \033[0m"

      exit 1
   fi

   echo -e "\033[34m"
   echo -e "----------------------------------------"
   echo -e "1. x86_64     linux  build"
   echo -e "2. aarch64    a1000  linux  build"
#    echo -e "3. aarch64    qnx710 build"
   echo -e "4. arm32      linux  build"
   echo -e "5. aarch64    c1200 linux build"
   echo -e "8. Install env"
   echo -e "9. DISTCLEAN  Build"
   echo -e "0. Exit"
   echo -e "----------------------------------------"
   echo -e "\033[0m"

   read KEY_VAL

   case ${KEY_VAL} in
   1)  x86_build               x86_64;;
   2)  aarch64_linux_build     a1000_linux;;
#    3)  aarch64_qnx710_build    qnx710;;
   4)  arm32_linux_build       arm32;;
   5)  aarch64_linux_build     c1200_linux;;
   8)  install_env;;
   9)  distclean_buid          ;;
                  
   0)  exit 0 ;;
   *)  echo -e "\033[31m[ERROR] Input key is error. \033[0m";;
   esac

    return 0
}


do_once_menu
