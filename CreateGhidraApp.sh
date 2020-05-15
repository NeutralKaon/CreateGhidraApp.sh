#!/bin/sh

set -eu

mkdir -p Ghidra.app/Contents/MacOS
echo "
@import Foundation;

int main() {
	execl([NSBundle.mainBundle.resourcePath stringByAppendingString:@\"/ghidra/ghidraRun\"].UTF8String, NULL);
}
" | clang -x objective-c -fmodules -framework Foundation -o Ghidra.app/Contents/MacOS/Ghidra -
mkdir -p Ghidra.app/Contents/Resources/
cp -R ghidra Ghidra.app/Contents/Resources
sed "s/bg Ghidra/fg Ghidra/" < ghidra/ghidraRun > Ghidra.app/Contents/Resources/ghidra/ghidraRun
sed "s/apple.laf.useScreenMenuBar=false/apple.laf.useScreenMenuBar=true/" < ghidra/support/launch.properties > Ghidra.app/Contents/Resources/ghidra/support/launch.properties
echo "APPL????" > Ghidra.app/Contents/PkgInfo
unzip -p ghidra/Ghidra/Framework/Generic/lib/Generic.jar images/GhidraIcon256.png > GhidraIcon.png
generate-app-icons GhidraIcon.png -m -f Ghidra.iconset
iconutil -c icns Ghidra.iconset
cp Ghidra.icns Ghidra.app/Contents/Resources
SetFile -a B Ghidra.app
echo "
<?xml version=\"1.0\" ?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
  <dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleExecutable</key>
    <string>Ghidra</string>
    <key>CFBundleIconFile</key>
    <string>Ghidra.icns</string>
    <key>CFBundleIdentifier</key>
    <string>org.ghidra-sre.Ghidra</string>
    <key>CFBundleDisplayName</key>
    <string>Ghidra</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Ghidra</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(grep application.version < ghidra/Ghidra/application.properties | sed "s/application.version=//")</string>
    <key>CFBundleVersion</key>
    <string>$(grep application.version < ghidra/Ghidra/application.properties | sed "s/application.version=//" | sed "s/\.//g")</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>NSHumanReadableCopyright</key>
    <string></string>
    <key>NSHighResolutionCapable</key>
    <true/>
  </dict>
</plist>
" > Ghidra.app/Contents/Info.plist