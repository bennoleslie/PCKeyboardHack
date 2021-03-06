#!/bin/sh

version=$(cat version)

packagemaker=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker
pkgName="PCKeyboardHack.pkg"
archiveName="PCKeyboardHack-${version}.pkg.zip"

make clean build || exit $?

# --------------------------------------------------
# http://developer.apple.com/documentation/Darwin/Conceptual/KEXTConcept/KEXTConceptPackaging/packaging_kext.html
echo "Copy Files"

rm -rf pkgroot
mkdir -p pkgroot

basedir="/Library/org.pqrs/PCKeyboardHack"
mkdir -p "pkgroot/$basedir"
for ostype in 10.6 10.7; do
    cp -R src/core/kext/${ostype}/build/Release/PCKeyboardHack.kext "pkgroot/$basedir/PCKeyboardHack.${ostype}.kext"
done
cp -R files/prefpane "pkgroot/$basedir"
cp -R files/scripts  "pkgroot/$basedir"

mkdir -p                               "pkgroot/$basedir/extra"
cp -R pkginfo/Resources/preflight      "pkgroot/$basedir/extra/uninstall.sh"
cp -R files/extra/launchUninstaller.sh "pkgroot/$basedir/extra/"
cp -R files/extra/setpermissions.sh    "pkgroot/$basedir/extra/"

mkdir -p                  "pkgroot/Library"
cp -R files/LaunchAgents  "pkgroot/Library"
cp -R files/LaunchDaemons "pkgroot/Library"

mkdir -p                                                   "pkgroot/$basedir/app"
cp -R "src/core/server/build/Release/PCKeyboardHack.app"   "pkgroot/$basedir/app"
cp -R "src/util/uninstaller/build/Release/uninstaller.app" "pkgroot/$basedir/app"

mkdir -p                                                        "pkgroot/Library/PreferencePanes"
cp -R "src/util/prefpane/build/Release/PCKeyboardHack.prefPane" "pkgroot/Library/PreferencePanes"

# Setting file permissions.
#
# Note:
#   If target files are already exists in system disk,
#   PackageMaker uses their permissions.
#
#   For example:
#     If /Library/org.pqrs permission is 0777 by accidental reasons,
#     the directory permission will be 0777 in Archive.bom
#     even if we set this directory permission to 0755 by setpermissions.sh.
#
#   Then, we need to repair file permissions in postflight script.
#   Please also see postflight.
#
sh "files/extra/setpermissions.sh" pkgroot

# --------------------------------------------------
echo "Exec PackageMaker"

rm -rf $pkgName

# Note: Don't add --no-recommend option.
# It breaks /Library permission.
# (It overwrites /Library permission with pkgroot/Library permission.)
# - Mac OS X 10.6: /Library is 1775
# - Mac OS X 10.7: /Library is 0755
$packagemaker \
    --root pkgroot \
    --info pkginfo/Info.plist \
    --resources pkginfo/Resources \
    --title "PCKeyboardHack $version" \
    --no-relocate \
    --out $pkgName

# --------------------------------------------------
echo "Make Archive"

zip -X -r $archiveName $pkgName
rm -rf $pkgName
chmod 644 $archiveName
unzip $archiveName

# --------------------------------------------------
echo "Cleanup"
rm -rf pkgroot
make -C src clean
