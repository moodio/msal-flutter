# 1.0.0+2
* Updates to readme in regards to kotlin static field issues.
## 1.0.0+1
* Added some more information to readme for clarity
## 1.0.0
* New API, including requirement to initialize
* New static async factory method
* Removal of old constructor
* Updated iOS MSAL package to version ~>1.0.3
* Updated Android MSAL package to version 1.0.+
* Added ability to use b2clogin.com, the new preferred authority
* Migrated to Android-X
* logout now returns a value
* Now compatiable with iOS 13
## 0.1.2
* Added initial logout functionality
## 0.1.1
* Added nullcheck on interactive callback to avoid crashes when other plugins callback before msal is initialized
## 0.1.0
* Released of first beta version.
* Small bits of formatting cleanup
## 0.0.5
* Added new custom exception for returning and handling login errors.
## 0.0.4
* added swift version to podspec
* added change log for 0.0.3
* testing changes to ensure easier compatiability with new flutter projects
* fixes to the readme documentation
## 0.0.3
* Removed errors from displaying in returned error message in anticipation to change error handling to throw exceptions
## 0.0.2
* Removed unused pub dependency
* Removed unused resources
* removed intent filter from plugin which was pointing to example app client id
## 0.0.1
* Initial release includes the basic functionality and api for a PublicClientApplication capable of getting tokens interactivity and silently for a single user account at a time
