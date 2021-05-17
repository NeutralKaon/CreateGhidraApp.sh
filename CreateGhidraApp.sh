#!/bin/sh

create_iconset() {
	mkdir -p Ghidra.iconset
	cat << EOF > Ghidra.iconset/Contents.json
{
	"images":
	[
		{
			"filename": "icon_16x16.png",
			"idiom": "mac",
			"scale": "1x",
			"size": "16x16"
		},
		{
			"filename": "icon_32x32.png",
			"idiom": "mac",
			"scale": "2x",
			"size": "16x16"
		},
		{
			"filename": "icon_32x32.png",
			"idiom": "mac",
			"scale": "1x",
			"size": "32x32"
		},
		{
			"filename": "icon_64x64.png",
			"idiom": "mac",
			"scale": "2x",
			"size": "32x32"
		},
		{
			"filename": "icon_128x128.png",
			"idiom": "mac",
			"size": "128x128",
			"scale": "1x"
		},
		{
			"filename": "icon_256x256.png",
			"idiom": "mac",
			"scale": "2x",
			"size": "128x128"
		},
		{
			"filename": "icon_256x256.png",
			"idiom": "mac",
			"scale": "1x",
			"size": "256x256"
		},
		{
			"filename": "icon_512x512.png",
			"idiom": "mac",
			"scale": "2x",
			"size": "256x256"
		},
		{
			"filename": "icon_512x512.png",
			"idiom": "mac",
			"scale": "1x",
			"size": "512x512"
		},
		{
			"filename": "icon_1024x1024.png",
			"idiom": "mac",
			"scale": "2x",
			"size": "512x512"
		}
	],
	"info":
	{
		"version": 1,
		"author": "xcode"
	}
}
EOF
	for size in 16 32 64 128 256 512 1024; do
		convert "$1" -resize "${size}x${size}" "Ghidra.iconset/icon_${size}x${size}.png"
	done
}

set -eu

if [ $# -ne 1 ]; then
	echo "Usage: $0 [path to ghidra folder]" >&2
	exit 1
fi

mkdir -p Ghidra.app/Contents/MacOS
cat << EOF | clang -x objective-c -fmodules -framework Foundation -o Ghidra.app/Contents/MacOS/Ghidra -
@import Foundation;

int main() {
	execl([NSBundle.mainBundle.resourcePath stringByAppendingString:@"/ghidra/ghidraRun"].UTF8String, NULL);
}
EOF
mkdir -p Ghidra.app/Contents/Resources/
rm -rf Ghidra.app/Contents/Resources/ghidra
cp -R "$(echo "$1" | sed s,/*$,,)" Ghidra.app/Contents/Resources/ghidra
sed "s/bg Ghidra/fg Ghidra/" < "$1/ghidraRun" > Ghidra.app/Contents/Resources/ghidra/ghidraRun
sed "s/apple.laf.useScreenMenuBar=false/apple.laf.useScreenMenuBar=true/" < "$1/support/launch.properties" > Ghidra.app/Contents/Resources/ghidra/support/launch.properties
echo "APPL????" > Ghidra.app/Contents/PkgInfo
jar -x -f Ghidra.app/Contents/Resources/ghidra/Ghidra/Framework/Generic/lib/Generic.jar images/GhidraIcon256.png
if [ "$( (sw_vers -productVersion; echo "11.0") | sort -V | head -n 1)" = "11.0" ]; then
	convert \( -size 1024x1024 canvas:none -fill white -draw 'roundRectangle 100,100 924,924 180,180' \) \( +clone -background black -shadow 25x12+0+12 \) +swap -background none -layers flatten -crop 1024x1024+0+0 \( images/GhidraIcon256.png -resize 704x704 -gravity center \) -composite GhidraIcon.png
else
	mv images/GhidraIcon256.png GhidraIcon.png
fi
create_iconset GhidraIcon.png
for size in 16 24 32 40 48 64 128 256; do
	convert GhidraIcon.png -resize "${size}x${size}" "images/GhidraIcon${size}.png"
	jar -u -f Ghidra.app/Contents/Resources/ghidra/Ghidra/Framework/Generic/lib/Generic.jar "images/GhidraIcon${size}.png"
done

iconutil -c icns Ghidra.iconset
cp Ghidra.icns Ghidra.app/Contents/Resources
SetFile -a B Ghidra.app
cat << EOF > Ghidra.app/Contents/Info.plist
<?xml version="1.0" ?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
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
		<string>$(grep application.version < "$1/Ghidra/application.properties" | sed "s/application.version=//")</string>
		<key>CFBundleVersion</key>
		<string>$(grep application.version < "$1/Ghidra/application.properties" | sed "s/application.version=//" | sed "s/\.//g")</string>
		<key>CFBundleSignature</key>
		<string>????</string>
		<key>NSHumanReadableCopyright</key>
		<string></string>
		<key>NSHighResolutionCapable</key>
		<true/>
	</dict>
</plist>
EOF
