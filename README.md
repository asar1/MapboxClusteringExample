# MapboxClusteringExample
This sample application demonstrate Cluster maps  in Mapbox Maps SDK Which are an excellent tool for determining the number of data points in a specific location. This example app demonstrates how to display a large number of markers on a map using marker clusters.

# Requirements

1. Xcode 12 or above
2. Mapbox account

# Setup

Firstly,  Sign up to Mapbox account and go to the Account page. This Mapbox SDK requires two critical pieces of information from your Mapbox account.
1. A public access token: 
you can copy or create public access token from your accounts token page. Open your project's Info.plist file and add an MBXAccessToken key with the value of your public access token to configure it.
2. A secret access token containing the (Downloads:Read scope):
You have to create secret access token from your accounts token page. Give your token a name and tick the box next to the Downloads:Read scope on the token creation screen. You will only have one chance to copy it somewhere safe. To download the Mapbox SDK, save your secret token in a .netrc file in your home directory (not your project folder). 
# Terminal command lines for .netrc file
To create .netrc file
1. open Terminal
2. cd ~ (go to the home directory)
3. touch .netrc (create file)
4. open .netrc (open .netrc)
5. Set required data.
.netrc file should be like this
*   machine api.mapbox.com
*   login mapbox
*   password <secret_key_created_from_your_mapbox_account>
6. Save

By keeping your secret token out of your application's source code, you may avoid mistakenly disclosing it.
 
# Add Dependency
1. Swift Packages Manager
Navigate to File > Swift Packages > Add Package Dependency in your Xcode project or workspace.
Enter the URL https://github.com/mapbox/mapbox-maps-ios.git in top right corner and  hit Enter to pull in the package, and then select Add Package.
2. Cocoapods
Add the following to your Podfile: 
*   pod 'MapboxMaps', '10.8.1'
To install cocoapods
1. open Terminal
2. cd ~ (go to the project directory)
3. pod install

}
 Run application and Boom…! Map Clustering is on your screen.
You can also follow the instructions in the doc in link given below
https://docs.mapbox.com/ios/maps/guides/install/
