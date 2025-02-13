#!/bin/bash
if [ -z "$1" ]; then
        echo "Correct usage is $0 <Version> "
        exit -1
fi



VERSION=$1
VERSION_CODE=${VERSION#./}
VERSION_CODE=${VERSION_CODE#+/}

echo '**********************  pub Taudio **********************'

bin/setver.sh $VERSION
bin/reldev.sh REL

cp -v ../tau_doc/pages/taudio/README.md .
gsed -i '1,6d' README.md
gsed -i "/^\"\%}$/d" README.md
gsed -i "/^{\% include/d" README.md

flutter analyze lib
if [ $? -ne 0 ]; then
    echo "Error: analyze ./lib"
    ###exit -1
fi

dart format lib
if [ $? -ne 0 ]; then
    echo "Error: format ./lib"
    exit -1
fi


cd example
flutter analyze lib
if [ $? -ne 0 ]; then
    echo "Error: analyze example/lib"
    ###exit -1
fi

#dart format lib
#if [ $? -ne 0 ]; then
#    echo "Error: format example/lib"
    #exit -1
#fi
cd ..


dart doc .

# Perhaps could be done in `setver.sh` instead of here
gsed -i  "s/^\( *version: \).*/\1$VERSION/"                                  ../tau_doc/_data/sidebars/td_sidebar.yml
gsed -i  "s/^ETAU_VERSION:.*/TAUDIO_VERSION: $VERSION/"                        ../tau_doc/_config.yml



echo 'git push'
git add .
git commit -m "Taudio : Version $VERSION"
git pull origin
git push origin
if [ ! -z "$VERSION" ]; then
    git tag -f $VERSION
    git push  -f origin $VERSION
fi


flutter pub publish
if [ $? -ne 0 ]; then
    echo "Error: flutter pub publish[Taudio]"
    exit -1
fi

cd example
flutter build web --release
if [ $? -ne 0 ]; then
    echo "Error"
    exit -1
fi
cd ..


cd ../tau_doc
bin/pub.sh
cd ../taudio



#read -p "Press enter to continue"

echo 'E.O.J for pub Taudio'
