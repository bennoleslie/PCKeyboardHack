#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	xcodebuild -alltargets -configuration $(CONFIGURATION) build

clean:
	rm -rf build
	rm -f *.xcodeproj/*.mode1
	rm -f *.xcodeproj/*.mode1v3
	rm -f *.xcodeproj/*.pbxuser
	rm -rf *.xcodeproj/xcuserdata
	rm -rf *.xcodeproj/project.xcworkspace/xcuserdata

xcode:
	open *.xcodeproj

run:
	-launchctl unload /Library/LaunchAgents/org.pqrs.PCKeyboardHack.server.plist 2>/dev/null
	./build/Release/PCKeyboardHack.app/Contents/MacOS/PCKeyboardHack
