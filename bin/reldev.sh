#!/bin/bash

if [ "_$1" = "_REL" ] ; then
  

        gsed -i  "s/^ *taudio: *#* *\(.*\)$/  taudio: \1/"                                                                       example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/ # taudio Dir$/#    path: \.\.\/ # taudio Dir/"                                               example/pubspec.yaml


        gsed -i  "s/^ *etau: *#* *\(.*\)$/  etau: \1/"                                                                             example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/\.\.\/etau # etau Dir$/#    path: \.\.\/\.\.\/etau # etau Dir/"                                 example/pubspec.yaml

        gsed -i  "s/^ *etau: *#* *\(.*\)$/  etau: \1/"                                                                             pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/etau # etau Dir$/#    path: \.\.\/etau # etau Dir/"                                             pubspec.yaml


        exit 0

#========================================================================================================================================================================================================


elif [ "_$1" = "_DEV" ]; then
 

        gsed -i  "s/^ *taudio: *#* *\(.*\)$/  taudio: # \1/"                                                                    example/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/ # taudio Dir$/    path: \.\.\/ # taudio Dir/"                                              example/pubspec.yaml


        gsed -i  "s/^ *etau: *#* *\(.*\)$/  etau: # \1/"                                                                          example/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/\.\.\/etau # etau Dir$/    path: \.\.\/\.\.\/etau # etau Dir/"                                example/pubspec.yaml

        gsed -i  "s/^ *etau: *#* *\(.*\)$/  etau: # \1/"                                                                          pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/etau # etau Dir$/    path: \.\.\/etau # etau Dir/"                                            pubspec.yaml

         exit 0

else
        echo "Correct syntax is $0 [REL | DEV]"
        exit -1
fi
echo "Done"
