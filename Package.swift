// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TTInAppPurchases",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TTInAppPurchases",
            targets: ["TTInAppPurchases"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "3.3.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", .upToNextMajor(from: "4.25.6")),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", .upToNextMajor(from: "4.8.0")),
        .package(url: "https://github.com/amplitude/Amplitude-iOS.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/malcommac/SwiftDate.git", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/mixpanel/mixpanel-swift.git", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/huri000/SwiftEntryKit.git", .upToNextMajor(from: "1.2.7")),
        .package(url: "https://github.com/marmelroy/PhoneNumberKit.git", .upToNextMajor(from: "3.6.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "TTInAppPurchases",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "RevenueCat", package: "purchases-ios"),
                "NVActivityIndicatorView",
                .product(name: "Amplitude", package: "Amplitude-iOS"),
                "SwiftDate",
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                "SwiftEntryKit",
                "PhoneNumberKit",
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]),
        .testTarget(
            name: "TTInAppPurchasesTests",
            dependencies: ["TTInAppPurchases"]),
    ]
)
