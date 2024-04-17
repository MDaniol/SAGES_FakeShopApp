#!/bin/sh

#  CICD.sh
#  FakeAPIClient
#
#  Created by Mateusz Danioł on 17/04/2024.
#  

name: CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" , "prod" ]

jobs:
  build:

    runs-on: macos-14

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode.app


    - name: Run tests
      run: xcodebuild clean build test -project projekt/FakeApiClient -scheme "CI" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
