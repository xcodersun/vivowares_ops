#!/bin/bash
echo -n "Checking Go version..."
GO_VERSION=`go version|grep 1.7.3 -c`
if [ "$GO_VERSION" != "1" ]; then
    echo "[FAIL]: Go1.7.3 is not installed. Please check gvm setting."
    exit 1
fi
echo [GO1.7.3]

echo -n "Checking vivogolf repo..."
VIVOGOLF_SRC="$GOPATH/src/github.com/vivogolf_backend"
if [ ! -d "${VIVOGOLF_SRC}" ]; then
    echo "[FAIL]: vivogolf repo does not exist. Please clone the repo."
    exit 1
fi
echo [SUCCESS]

echo -n "Update vivogolf repo..."
pushd ${VIVOGOLF_SRC} > /dev/null 2>&1
git pull origin > /dev/null 2>&1
if [ "$?" != 0 ]; then
    echo "[FAIL]: vivogolf repo fails to update. Please check git setting."
    exit 1
fi
popd > /dev/null 2>&1
echo "[SUCCESS]"

echo -n "Installing vivogolf..."
go install github.com/vivogolf_backend
if [ "$?" != 0 ]; then
    echo "[FAIL]: installation fails. Please check git setting."
    exit 1
fi
echo "[SUCCESS]"

echo -n "Configure vivogolf environment..."
export VIVOGOLF_HOME="$GOPATH/bin/"
if [ ! -d "${VIVOGOLF_HOME}/configs" ]; then
    mkdir ${VIVOGOLF_HOME}/configs
fi
cp ${VIVOGOLF_SRC}/configs/vivogolf_development.yml ${VIVOGOLF_HOME}/configs/
echo "[SUCCESS]"

echo -n "Move page..."
if [ -f vivogolf_dist.tar ]; then
    tar -xvf vivogolf_dist.tar > /dev/null 2>&1
    rm -rf ${VIVOGOLF_HOME}/assets
    mv dist ${VIVOGOLF_HOME}/assets
    echo "[SUCCESS]"
else
    echo "[NOTHING]"
fi

echo -n "Database migrate..."
vivogolf_backend migrate > /dev/null 2>&1
if [ "$?" != 0 ]; then
    echo "[FAIL]: fail to migrate database. Please check configs."
    exit 1
fi
echo "[SUCCESS]"
