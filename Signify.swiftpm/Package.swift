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
            appIcon: .placeholder(icon: .weights),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "my app use camera")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .copy("MLModel")
            ]
        )
    ]
)