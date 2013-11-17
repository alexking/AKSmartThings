AKSmartThings
=============

Cocoa wrapper for communicating with [SmartThings](http://smartthings.com) REST APIs. 

* Simple REST calls with JSON responses 
* OAuth authentication
* Endpoint discovery 

## Use
You can add this to your [CocoaPods](http://cocoapods.org) `Podfile` –

    pod 'AKSmartThings', :git => 'https://github.com/alexking/AKSmartThings.git'
    
Then just run `pod install` and import using `#import <AKSmartThings/AKSmartThings.h>`. 

For an example of how to use it, you might check out StatusThing, the open source app I built this for. 

Please submit any bugs to the issue tracker, or feel free to submit a pull request. 

To learn more about making [SmartThings](http://smartthings.com) REST APIs, you may want to check out [this blog post from them](http://build.smartthings.com/blog/tutorial-creating-a-custom-rest-smartapp-endpoint/). 

##Changelog
### Version 0.0.3
* Closing the server when we no longer need it 
* Not checking for endpoints if we don't have an access token 

### Version 0.0.2
Bug fixes

### Version 0.0.1
Initial release of library, setup with podspec 

## License
MIT 

## Dependencies 

* [CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer) – [BSD License](https://github.com/robbiehanson/CocoaHTTPServer/blob/master/LICENSE.txt)