# xmpp-messenger-ios

[![CI Status](http://img.shields.io/travis/ProcessOne/xmpp-messenger-ios.svg?style=flat)](https://travis-ci.org/ProcessOne/xmpp-messenger-ios)
[![Version](https://img.shields.io/cocoapods/v/xmpp-messenger-ios.svg?style=flat)](http://cocoapods.org/pods/xmpp-messenger-ios)
[![License](https://img.shields.io/cocoapods/l/xmpp-messenger-ios.svg?style=flat)](http://cocoapods.org/pods/xmpp-messenger-ios)
[![Platform](https://img.shields.io/cocoapods/p/xmpp-messenger-ios.svg?style=flat)](http://cocoapods.org/pods/xmpp-messenger-ios)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

xmpp-messenger-ios is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "xmpp-messenger-ios"
```

## Author

ProcessOne, pmglemaire@gmail.com

## License

xmpp-messenger-ios is available under the MIT license. See the LICENSE file for more info.

# OneChat
Swift XMPP client using P1 Swift XMPP framework

## Usage 
Download or clone the project

###AppDelegate

Add this in your AppDelegate's did finishLaunchingWithOptions to start the stream :

```swift
OneChat.start(archiving: true, delegate: nil) { (stream, error) -> Void in

}
```

Add in applicationWillTerminate to stop the stream :
```swift
OneChat.stop()
```

###BuddyList
To get the buddy list, just conform to OneRosterDelegate by implementing the delegate :
```swift
func oneRosterContentChanged(controller: NSFetchedResultsController) {
  tableView.reloadData() //Reload or other
}
```

###Messaging
####Receive a message 
To be able to send messages, you must conform to OneMessageDelegate :

First set yourself as listener in viewdidload
```swift
override func viewDidLoad() {
super.viewDidLoad()

OneMessage.sharedInstance.delegate = self
}
```
then implement the protocol :
```swift
func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject) {

if message.isChatMessageWithBody() {
let body = message.elementForName("body").stringValue()
let displayName = user.displayName

if let msg: String = message.elementForName("body")?.stringValue() {
if let from: String = message.attributeForName("from")?.stringValue() {
messagestTableView.reloadData() //Reload or other
}
}
}
}
```

####Send a message :
```swift
OneMessage.sendMessage(youMessage, to: chatJid, completionHandler: { (stream, message) -> Void in

})
```