# Adding Butterfly Access Token

Follow these steps to allow Xcode Swift Package Manager to access our package's binary target:

1. Quit the **Xcode** and **Keychain Access** apps completely **(⌘+Q)**.
1. Open the **Terminal** app and run the following command, replacing `USERNAME` and `ACCESS_TOKEN` with the Butterfly **username** and **access token** provided during onboarding (note: these are not your email and password credentials):
   ```sh
   security add-internet-password \
      -a USERNAME \
      -w ACCESS_TOKEN \
      -s sdk.butterflynetwork.com \
      -r htps \
      login.keychain-db
   ```
   **Ensure** that you did not accidentally paste more characters, which can be automatically appended by some note-taking apps. If the Keychain item is created with any mistakes, delete it via the **Keychain Access** app and re-create it.

You can now continue with [adding the package](../#installation).
