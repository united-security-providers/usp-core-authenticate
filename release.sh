#!/bin/bash

set -eE # same as: `set -o errexit -o errtrace`
trap 'catch $? $LINENO' ERR

catch() {
  echo "Error $1 occurred on line $2"
}

checkbin() {
  local cmd=$1
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd command could not be found"
    exit
  fi
}

prepareChangelog() {
  local sourceFile=$1
  local targetFile=$2

  rm -rf changelog-tmp
  mkdir changelog-tmp

  # Remove footer section with all link URLs from changelog
#######################  sed -n '/linksnurls/q;p' $1 > changelog-tmp/CHANGELOG2.md
  # Until a new operator release is made with the "linksnurls" footer marker, the
  # following line has to be used to cut off the footer instead:
  sed -n '/redmine/q;p' $sourceFile > changelog-tmp/CHANGELOG2.md

  # Remove all link brackets from operator changelog
  sed 's|[\[,]||g' changelog-tmp/CHANGELOG2.md > changelog-tmp/CHANGELOG3.md
  sed 's|[],]||g' changelog-tmp/CHANGELOG3.md > $targetFile

  rm -rf changelog-tmp
}

downloadFromNexus() {
  local version=$1
  local groupId=$2
  local artifactId=$3
  local type=$4
  local classifier=$5

  local repository='releases'
  if [[ $version =~ "SNAPSHOT" ]]; then
    repository='snapshots'
  fi

  local query="http://nexus-bob.u-s-p.local/service/rest/v1/search/assets?sort=version&maven.baseVersion=$version&maven.groupId=$groupId&maven.artifactId=$artifactId&maven.extension=$type&maven.classifier=$classifier"
  echo "Nexus query: $query"

  wget -O info.json $query
  downloadUrl=`cat info.json | grep -v '\-sources' | grep -a -m 1 -h "downloadUrl" | grep -Po 'downloadUrl" : "\K[^"]*'`
  rm info.json

  if [[ -z "$classifier" ]]; then
    filename=$artifactId-$version.$type
  else
    filename=$artifactId-$version-$classifier.$type
  fi

  wget -O $filename $downloadUrl
  if [[ "$type" == "zip" || "$type" == "jar" ]]; then
    jar xvf $filename
  fi
}

checkbin mkdocs
checkbin wget

if [ "$#" -lt 1 ]
then
  echo "Not enough arguments supplied. Usage:"
  echo ""
  echo "./release.sh <core-authentication-version, e.g. 5.19.0.4> [deploy]"
  echo ""
  echo "If the optional 'deploy' argument is set, the website will be deployed to Github and made public!"
  echo ""
  echo "Example for creating the website without deployment:"
  echo ""
  echo "./release.sh 5.19.0.4"
  exit 1
fi

# 1st input parameter = Core Authenticate container version (equals SLS version)
export SLS_VERSION=$1

DIR=`pwd`
rm -rf build
rm -rf docs
rm -rf generated
mkdir build
cd build

echo "-------------------------------------------------------------"
echo "Selected Core Authenticate release: $SLS_VERSION"
echo "-------------------------------------------------------------"

mkdir sls-docs
cd sls-docs

# Download SLS release notes
downloadFromNexus $SLS_VERSION com.usp.sls.framework sls-release-notes jar

# Download generated docs bundle (PDFs and HTML)
downloadFromNexus $SLS_VERSION com.usp.sls.framework sls-generated-docs zip docs

# Download "What's New" doc
downloadFromNexus $SLS_VERSION com.usp.sls.framework sls-docs jar whatsnew

rm *.zip
rm *.jar

# =====================================================================
# Begin site build
# =====================================================================

# Prepare site source directory
cd $DIR

# Copy base markdown files from sources
cp -R src/docs ./docs
cp build/sls-docs/releasenotes.md ./docs/

#########prepareChangelog build/waap-$CORE_Authenticate_VERSION-changelog.md ./docs/waap-CHANGELOG.md

mkdir -p ./docs/files/$SLS_VERSION
cp -r ./build/sls-docs/* ./docs/files/$SLS_VERSION/

# Replace version placeholders in all markdown files
for file in ./docs/*; do
    if [ -f "$file" ]; then
        sed -i -e 's/%SLS_VERSION%/'$SLS_VERSION'/g' $file
    fi
done

echo "Successfully generated site (Markdown) at ./docs."

if [ "$3" == "deploy" ]; then
    echo "Deploying to GitHub pages..."
    mkdocs gh-deploy
    echo "Successfully deployed to to GitHub pages"
fi

trap - ERR
