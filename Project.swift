import ProjectDescription

let project = Project(
  name: "github-tca",
  packages: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.22.1"),
  ],
  targets: [
    .target(
      name: "github-tca",
      destinations: .iOS,
      product: .app,
      bundleId: "com.sro.github-tca",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
          ],
        ]
      ),
      buildableFolders: [
        "github-tca/Sources",
        "github-tca/Resources",
      ],
      dependencies: [
        .package(product: "ComposableArchitecture")
      ]
    ),
    .target(
      name: "github-tcaTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "com.sro.github-tcaTests",
      infoPlist: .default,
      buildableFolders: [
        "github-tca/Tests"
      ],
      dependencies: [.target(name: "github-tca")]
    ),
  ]
)
