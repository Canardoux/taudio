#!/bin/bash
if [ -z "$1" ]; then
        echo "Correct usage is $0 <Version>"
        exit -1
fi



VERSION=$1
VERSION_CODE=${VERSION//./}
VERSION_CODE=${VERSION_CODE//+/}

#gsed -i "s/^FLUTTER_SOUND_VERSION=.*/FLUTTER_SOUND_VERSION='$VERSION'/"   flutter_sound/doc/FLUTTER_SOUND_VERSION

#gsed -i  "s/const VERSION = .*$/const VERSION = '$VERSION'/"                  flutter_sound_web/src/flutter_sound.js;
#gsed -i  "s/const PLAYER_VERSION = .*$/const PLAYER_VERSION = '$VERSION'/"    flutter_sound_web/src/flutter_sound_player.js;
#gsed -i  "s/const RECORDER_VERSION = .*$/const RECORDER_VERSION = '$VERSION'/"    flutter_sound_web/src/flutter_sound_recorder.js;



gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           pubspec.yaml
gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           example/pubspec.yaml
gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  CHANGELOG.md

#gsed -i  "s/^\( *taudio: *#* *\^*\).*$/\1$VERSION/"                                    example/pubspec.yaml
gsed -i  "s/^\( *taudio: *#* *\^*\).*$/\1$VERSION/"                                    ../etau/example/pubspec.yaml
gsed -i  "s/^title: Taudio - .*$/title: Taudio - $VERSION/"                             ../taudio-doc/index.md
gsed -i  "s/^title: Taudio - .*$/title: Taudio - $VERSION/"                              ../taudio-doc/bin/cp.sh

#gsed -i  "s/^\( *tau_web: *#* *\^*\).*$/\1$VERSION/"                                    ../etau/pubspec.yaml
#gsed -i  "s/^\( *tau_web: *#* *\^*\).*$/\1$VERSION/"                                    ../flutter_sound/example/pubspec.yaml
#gsed -i  "s/^\( *tau_web: *#* *\^*\).*$/\1$VERSION/"                                    ../flutter_sound/pubspec.yaml
#gsed -i  "s/^\( *tau_web: *#* *\^*\).*$/\1$VERSION/"                                    ../flutter_sound_web/pubspec.yaml
