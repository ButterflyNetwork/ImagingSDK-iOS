# Troubleshooting

## Installation

In case any issues were encountered during installation of the SDK, please follow these steps to gather more details and examine if it matches one of the known issues below.

1. If package resolution failed while trying to add the SDK package, tap **Add Anyway**.
1. Open menu: **File** > **Packages** > **Resolve Package Versions**.
1. Open the **Report navigator** (⌘+9) on the left pane. Go through the reports listed, and locate the relevant error in the report details on the right. [^1]
1. If the error is not listed in the section below and no information is available online regarding the error, tap **Export** to save the report file and forward it to us. [^2]

[^1]: The “Report navigator” helps you view detailed reports of your project’s build processes. Errors related to package resolution will appear in the “Resolve Packages” report, while compilation errors will show up in the “Build” report.

[^2]: Exporting the error report helps our support team diagnose the issue more effectively.

## Operation

To help better understand how the SDK works, or to aid debugging, a host app can register a hook to receive logs from the SDK.

```swift
imaging.clientLoggingCallback = { string, level in
    print("Butterfly SDK (level='\(level)'): \(string)")
}
imaging.isClientLoggingEnabled = true
```

## Known issues

### Invalid archive
```
invalid archive returned from 'https://sdk.butterflynetwork.com/.../ButterflyImagingKit.xcframework.zip' which is required by binary target 'ButterflyImagingKit'
```

This seems to be an issue with Xcode, and it could occur when adding the SDK package before the access token steps were successfully completed.

**Fix:**

1. Remove the SDK dependency.
1. Run these commands in the Terminal:
   ```
   rm -rf $HOME/Library/Caches/org.swift.swiftpm/
   rm -rf $HOME/Library/org.swift.swiftpm
   ```
1. Re-add the SDK dependency.

[Stackoverflow](https://stackoverflow.com/a/77834373)

### badResponseStatusCode(404) / (403)
```
failed downloading 'https://sdk.butterflynetwork.com/.../ButterflyImagingKit.xcframework.zip' which is required by binary target 'ButterflyImagingKit':
badResponseStatusCode(404)
```
**Fix:** Ensure you have successfully completed the steps to add your [Butterfly Access Token](AccessToken.md) to your Mac. [^3]

[^3]: Adding the access token is necessary to authenticate your requests to the SDK’s server.

### File already exists
```
failed downloading 'https://sdk.butterflynetwork.com/.../ButterflyImagingKit.xcframework.zip' which is required by binary target 'ButterflyImagingKit': /Users/.../Library/Caches/org.swift.swiftpm/artifacts/...ButterflyImagingKit_xcframework_zip
already exists in file system
```
**Fix:** Follow the same steps as in: [Invalid archive](#invalid-archive).
