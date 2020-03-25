#!/bin/bash

xcodebuild -project PianoGame.xcodeproj -scheme PianoGame -destination platform="iOS Simulator",name="iPhone XS Max" build test | xcpretty
