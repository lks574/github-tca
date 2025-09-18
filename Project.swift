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
          "CFBundleURLTypes": [
            [
              "CFBundleURLName": "GitHub OAuth",
              "CFBundleURLSchemes": ["github-tca"]
            ]
          ],
        ]
      ),
      buildableFolders: [
        "github-tca/Sources",
        "github-tca/Resources",
      ],
      dependencies: [
        .package(product: "ComposableArchitecture")
      ],
      environmentVariables: [
        "GITHUB_CLIENT_ID" : "Ov23li3PdoDXMFSa3RHk",
        "GITHUB_CLIENT_SECRET": "f6da80ca88adb5cc6f2ea44ba7b1818257482cc3",
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
      dependencies: [.target(name: "github-tca")],
      environmentVariables: [
        "GITHUB_CLIENT_ID" : "Ov23li3PdoDXMFSa3RHk",
        "GITHUB_CLIENT_SECRET": "f6da80ca88adb5cc6f2ea44ba7b1818257482cc3",
      ]
    ),
  ]
)
