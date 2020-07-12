#!/bin/bash
set -e

######## remove me later
mvn install
########################


NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
WHITE='\033[0;37m'

APP_NAME='bco'
APP_NAME=${BLUE}${APP_NAME}${NC}

DEPLOY_USER=${DEPLOY_USER:-divinethreepwood}
API_KEY=${API_KEY:-<todo: generate via https://bintray.com/profile/edit and insert>}
BINTRAY_REPO=https://api.bintray.com/content/openbase/deb/bco
PUBLISH=${PUBLISH:-1}
OVERRIDE=${OVERRIDE:-1}

VERSION=$(grep -A1 "<artifactId>bco<" pom.xml | grep -Po '(?<=    <version>).*(?=</version>)')
SOURCE_FILE_PATH=$(echo target/bco*.deb)
DEB_FILENAME=${SOURCE_FILE_PATH:7}
if [[ "${VERSION:(-8)}" == "SNAPSHOT" ]]; then
  VERSION=${VERSION:0:(-9)}
  DESCRIPTION="The experimental alpha prerelease of bco ${VERSION}"
  COMPONENT=unstable,testing
  FILE_TARGET_PATH=pool/unstable/b/bco/${DEB_FILENAME}
else
  DESCRIPTION="The release of bco ${VERSION}"
  COMPONENT=main,free,unstable,testing
  FILE_TARGET_PATH=pool/main/b/bco/${DEB_FILENAME}
fi
SCM=https://github.com/openbase/bco.git
DISTRIBUTION=wheezy,stretch,bionic,buster
ARCHITECTURE=all,mips,armhf,arm64,armel,i386,amd64

TARGET_URL="${BINTRAY_REPO}/$VERSION/${FILE_TARGET_PATH};deb_distribution=${DISTRIBUTION};deb_component=${COMPONENT};deb_architecture=${ARCHITECTURE};publish=${PUBLISH};override=${OVERRIDE}"
echo -e "=== ${APP_NAME} project ${WHITE}upload${NC}" &&
  RESULT=$(curl -s -T "${SOURCE_FILE_PATH}" -u${DEPLOY_USER}:${API_KEY} "${TARGET_URL}")
if [[ "$RESULT" == '{"message":"success"}' ]]; then
  echo -e "\n=== ${APP_NAME} ${VERSION} upload to ${WHITE}${TARGET_URL}${NC} ${GREEN}successful${NC}"
  exit 0
else
  echo -e "\n=== ${APP_NAME} upload to ${WHITE}${TARGET_URL}${NC} ${RED}failed!${NC}"
  echo -e "\n=== ${RED}ERROR:${NC} ${RESULT}"
  exit 1
fi
