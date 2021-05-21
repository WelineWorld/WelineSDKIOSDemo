#!/bin/bash
SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
basepath="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
#echo ${basepath}

#rm -rf CMAPIdemo/*.framework
#rm -rf build

if [[ ! -d ${basepath}/CMAPIdemo/CMAPISDK.framework || ! -d ${basepath}/CMAPIdemo/CMAPIAPPSDK.framework ]]; then
    if [[ ! -d ${basepath}/build ]];then
        mkdir -p ${basepath}/build
    fi
    cd ${basepath}/build
    sdk_name=sdk.tar
    curl -o ${sdk_name} "http://test.memenet.net:8188/cmapisdk/ios_cmapi_sdk_r1.0.tar"
    tar xf ${sdk_name} -C ${basepath}/CMAPIdemo/
fi

echo "init done"
