## CreateGhidraApp.sh – a loving pull from [Saagarjha's gist](https://gist.github.com/saagarjha/777909b257dbfa98649476b7f5af41bb)


## Purpose: 

Create a nice, standalone and compatible `.app` application for MacOS users of [Ghidra](https://github.com/NationalSecurityAgency/ghidra).
This makes it possible to (largely portably) distribute it, for example. Also, `.app` bundles are pretty. 

## Prerequistes:  

- Xcode and the MacOS SDK
- Imagemagick's `convert` 
- Ghidra's preferred version of a JDK (currently [OpenJDK v11](https://adoptium.net/releases.html?variant=openjdk11&jvmVariant=hotspot))

## Changes: 

Compared to the original gist, this script: 
– Directly links against the MacOS SDK, avoiding clang's errant `<stdin>:1:9: fatal error: module 'Foundation' not found` 
- Uses a slightly different (i.e. more comptaible) `jar` syntax 
- Passes shellcheck 

## Usage: 

```bash 
mkdir temp_dir && cd temp_dir; 
git clone https://github.com/NeutralKaon/CreateGhidraApp.sh.git . 
chmod +x ./CreateGhidraApp.sh
#Determine the latest_ghidra_release URL e.g. 
wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.0.2_build/ghidra_10.0.2_PUBLIC_20210804.zip -O Ghidra_10.0.2.zip 
unzip Ghidra_10.0.2.zip
./CreateGhidraApp.sh ./Ghidra_10.0.2
```

Enjoy!
