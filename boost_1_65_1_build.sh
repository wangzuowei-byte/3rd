#! /bin/bash

WORKSPACE_PATH=$(readlink -f "$(dirname "$0")")
TOOLCHAINS_PATH=/work/toolchains

PTHREAD_NAME=boost_source
TAR_NAME=boost_1_65_1.tar.gz

function boost_unzip()
{
   local TAR_PATH=$1
   local SOURCE_PATH=$2

   # tar -vxf
   if [ ! -d ${SOURCE_PATH} ];then
      mkdir -p ${SOURCE_PATH}

      tar -vxf ${TAR_PATH} --strip-components 1 -C ${SOURCE_PATH}
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
   boost_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   rm -f project-config.jam*
   sed -i "4a #define BOOST_MPL_CFG_ASSERT_BROKEN_POINTER_TO_POINTER_TO_MEMBER" ./boost/mpl/assert.hpp

   ./bootstrap.sh --prefix=${PRJ_INSTALL_PATH}  --without-libraries=python
#   sed -i "12s#gcc#gcc\ :\ :\ aarch64-bst-linux-gcc\ --sysroot=${SYSROOT}#g" ${TAR_BUILD_PATH}/project-config.jam

   ./b2 -j16
   ./b2 -j16 install

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
   boost_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   rm -f project-config.jam*
   sed -i "4a #define BOOST_MPL_CFG_ASSERT_BROKEN_POINTER_TO_POINTER_TO_MEMBER" ./boost/mpl/assert.hpp

   ./bootstrap.sh --prefix=${PRJ_INSTALL_PATH}  --without-libraries=python
   sed -i "12s#gcc#gcc\ :\ :\ aarch64-bst-linux-gcc\ --sysroot=${SYSROOT}#g" ${PRJ_BUILD_PATH}/project-config.jam

   ./b2 -j16
   ./b2 -j16 install


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
   boost_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   rm -f project-config.jam*
   sed -i "4a #define BOOST_MPL_CFG_ASSERT_BROKEN_POINTER_TO_POINTER_TO_MEMBER" ./boost/mpl/assert.hpp

   ./bootstrap.sh --prefix=${PRJ_INSTALL_PATH}  --without-libraries=python
   sed -i "12s#gcc#gcc\ :\ :\ arm-none-linux-gnueabihf-gcc\ --sysroot=${SYSROOT}#g" ${PRJ_BUILD_PATH}/project-config.jam

   ./b2 -j16
   ./b2 -j16 install


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
   boost_unzip ${WORKSPACE_PATH}/${TAR_NAME} ${TAR_BUILD_PATH}/${PTHREAD_NAME}

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

   rm -f project-config.jam*
   sed -i "4a #define BOOST_MPL_CFG_ASSERT_BROKEN_POINTER_TO_POINTER_TO_MEMBER" ./boost/mpl/assert.hpp


   ./bootstrap.sh --prefix=${PRJ_INSTALL_PATH}  --without-libraries=python,locale,log,fiber

   sed -i "12s#gcc#gcc\ :\ :\ aarch64-unknown-nto-qnx7.1.0-gcc#g" ${PRJ_BUILD_PATH}/project-config.jam && \
   sed -i "14,16s/^/###&/g" ${PRJ_BUILD_PATH}/libs/chrono/build/Jamfile.v2 && \
   sed -i "103s/^/###&/g" ${PRJ_BUILD_PATH}/libs/stacktrace/build/Jamfile.v2 && \
   sed -i "/pthread/d" ${PRJ_BUILD_PATH}/tools/build/src/tools/gcc.jam


   ./b2 -j16
   ./b2 -j16 install


   return 0
}

distclean_buid()
{
   rm -rf ${WORKSPACE_PATH}/build

   return 0
}

install_env()
{

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
    echo -e "4. arm32      linux  build"
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
    4)  arm32_linux_build       arm32;;
    8)  install_env;;
    9)  distclean_buid          ;;
                   
    0)  exit 0 ;;
    *)  echo -e "\033[31m[ERROR] Input key is error. \033[0m";;
    esac

    return 0
}


do_once_menu