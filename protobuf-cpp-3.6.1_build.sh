#! /bin/bash

WORKSPACE_PATH=$(readlink -f "$(dirname "$0")")
TOOLCHAINS_PATH=/work/toolchains

PTHREAD_NAME=protobuf-cpp-3.6.1

function unzip()
{
   local TAR_PATH=$1
   local SOURCE_PATH=$2

   # tar -vxf
   if [ ! -d ${SOURCE_PATH} ];then
      mkdir -p ${SOURCE_PATH}

      tar -vxf ${TAR_PATH}.tar.gz --strip-components 1 -C ${SOURCE_PATH}
   fi

  return 0
}

function x86_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=${TOOLCHAINS_PATH}/${PLATFORM_SYS}
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build/${PTHREAD_NAME}_build
   local TAP_PATH=${WORKSPACE_PATH}/pack_tar/${PTHREAD_NAME}

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   unzip ${TAP_PATH} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   ../configure                          \
   --host=aarch64-bst-linux              \
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
function aarch64_linux_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=${TOOLCHAINS_PATH}/${PLATFORM_SYS}
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build/${PTHREAD_NAME}_build
   local TAP_PATH=${WORKSPACE_PATH}/pack_tar/${PTHREAD_NAME}

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   unzip ${TAP_PATH} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   ../configure                          \
   --host=aarch64-bst-linux              \
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


function arm32_linux_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=/toolchains/armhf_none_9.2_2019.12
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build/${PTHREAD_NAME}_build
   local TAP_PATH=${WORKSPACE_PATH}/pack_tar/${PTHREAD_NAME}

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   unzip ${TAP_PATH} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   ../configure                          \
   --host=arm-none-linux                 \
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

function aarch64_qnx710_build()
{
   local PLATFORM_SYS=$1

   local TOOLCHAIN_PATH=${TOOLCHAINS_PATH}/${PLATFORM_SYS}
   local TAR_BUILD_PATH=${WORKSPACE_PATH}/build/${PTHREAD_NAME}_build
   local TAP_PATH=${WORKSPACE_PATH}/pack_tar/${PTHREAD_NAME}

   local PRJ_BUILD_PATH=${TAR_BUILD_PATH}/${PLATFORM_SYS}_build
   local PRJ_INSTALL_PATH=${TAR_BUILD_PATH}/install/${PLATFORM_SYS}

   # download and unzip
   unzip ${TAP_PATH} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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
   apt-get install protobuf-compiler -y
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
    echo -e "2. aarch64    linux  build"
    echo -e "3. aarch64    qnx710 build"
    echo -e "5. arm32      linux  build"
    echo -e "8. Install env"
    echo -e "9. DISTCLEAN  Build"
    echo -e "0. Exit"
    echo -e "----------------------------------------"
    echo -e "\033[0m"

    read KEY_VAL

    case ${KEY_VAL} in
    1)  x86_build               x86_64;;
    2)  aarch64_linux_build     a1000_linux;;
    3)  aarch64_qnx710_build    qnx710;;
    5)  arm32_linux_build       arm32;;
    8)  install_env;;
    9)  distclean_buid          ;;
                   
    0)  exit 0 ;;
    *)  echo -e "\033[31m[ERROR] Input key is error. \033[0m";;
    esac

    return 0
}


do_once_menu