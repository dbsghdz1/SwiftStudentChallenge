// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Signify",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Signify",
            targets: ["AppModule"],
            bundleIdentifier: "com.Signify.SSC",
            teamIdentifier: "B6QMD2854G",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .twoPeople),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .landscapeRight
            ],
            capabilities: [
                .camera(purposeString: "Signify needs access to your camera to recognize sign language."),
                .microphone(purposeString: "Signify needs access to your microphone to convert speech into subtitles."),
                .speechRecognition(purposeString: "Signify needs access to speech recognition to transcribe spoken words into text.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .copy("Resource")
            ]
        )
    ]
)