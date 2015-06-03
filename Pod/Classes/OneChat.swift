//
//  OneChat.swift
//  OneChat
//
//  Created by Paul on 23/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation

typealias XMPPStreamCompletionHandler = (shouldTrustPeer: Bool?) -> Void
typealias OneChatAuthCompletionHandler = (stream: XMPPStream, error: DDXMLElement?) -> Void

protocol OneChatDelegate {
	func oneStream(sender: XMPPStream?, socketDidConnect socket: GCDAsyncSocket?)
	func oneStreamDidConnect(sender: XMPPStream)
	func oneStreamDidAuthenticate(sender: XMPPStream)
	func oneStream(sender: XMPPStream, didNotAuthenticate error: DDXMLElement)
	func oneStreamDidDisconnect(sender: XMPPStream, withError error: NSError)
}

class OneChat: NSObject {
	
	var delegate: OneChatDelegate?
	var window: UIWindow?
	
	var xmppStream: XMPPStream?
	var xmppReconnect: XMPPReconnect?
	var xmppRosterStorage: XMPPRosterCoreDataStorage?
	var xmppRoster: XMPPRoster?
	var xmppvCardStorage: XMPPvCardCoreDataStorage?
	var xmppvCardTempModule: XMPPvCardTempModule?
	var xmppvCardAvatarModule: XMPPvCardAvatarModule?
	var xmppCapabilitiesStorage: XMPPCapabilitiesCoreDataStorage?
	var xmppMessageDeliveryRecipts: XMPPMessageDeliveryReceipts?
	var xmppCapabilities: XMPPCapabilities?
	var user = XMPPUserCoreDataStorageObject()
	var chats: OneChats?
	let presenceTest = OnePresence()
	let messageTest = OneMessage()
	let rosterTest = OneRoster()
	
	var customCertEvaluation: Bool?
	var isXmppConnected: Bool?
	var password: String?
	
	var streamDidConnectCompletionBlock: OneChatAuthCompletionHandler?
	
	// MARK: Singleton
	
	class var sharedInstance : OneChat {
		struct OneChatSingleton {
			static let instance = OneChat()
		}
		return OneChatSingleton.instance
	}
	
	// MARK: Functions
	
	class func stop() {
		sharedInstance.teardownStream()
	}
	
	class func start(archiving: Bool? = false, delegate: OneChatDelegate? = nil, completionHandler completion:OneChatAuthCompletionHandler) {
		sharedInstance.setupStream()
		
		if archiving! {
			OneMessage.sharedInstance.setupArchiving()
		}
		if let delegate: OneChatDelegate = delegate {
			sharedInstance.delegate = delegate
			
		}
		sharedInstance.streamDidConnectCompletionBlock = completion
	}
	
	private func setupStream() {
		// Setup xmpp stream
		//
		// The XMPPStream is the base class for all activity.
		// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
		
		xmppStream = XMPPStream()
		
		#if !TARGET_IPHONE_SIMULATOR
			// Want xmpp to run in the background?
			//
			// P.S. - The simulator doesn't support backgrounding yet.
			//        When you try to set the associated property on the simulator, it simply fails.
			//        And when you background an app on the simulator,
			//        it just queues network traffic til the app is foregrounded again.
			//        We are patiently waiting for a fix from Apple.
			//        If you do enableBackgroundingOnSocket on the simulator,
			//        you will simply see an error message from the xmpp stack when it fails to set the property.
			xmppStream!.enableBackgroundingOnSocket = true
		#endif
		
		// Setup reconnect
		//
		// The XMPPReconnect module monitors for "accidental disconnections" and
		// automatically reconnects the stream for you.
		// There's a bunch more information in the XMPPReconnect header file.
		
		xmppReconnect = XMPPReconnect()
		
		// Setup roster
		//
		// The XMPPRoster handles the xmpp protocol stuff related to the roster.
		// The storage for the roster is abstracted.
		// So you can use any storage mechanism you want.
		// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
		// or setup your own using raw SQLite, or create your own storage mechanism.
		// You can do it however you like! It's your application.
		// But you do need to provide the roster with some storage facility.
		
		xmppRosterStorage = XMPPRosterCoreDataStorage()
		xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
		
		xmppRoster!.autoFetchRoster = true;
		xmppRoster!.autoAcceptKnownPresenceSubscriptionRequests = true;
		
		// Setup vCard support
		//
		// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
		// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
		
		xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
		xmppvCardTempModule = XMPPvCardTempModule(withvCardStorage: xmppvCardStorage)
		xmppvCardAvatarModule = XMPPvCardAvatarModule(withvCardTempModule: xmppvCardTempModule)
		
		// Setup capabilities
		//
		// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
		// Basically, when other clients broadcast their presence on the network
		// they include information about what capabilities their client supports (audio, video, file transfer, etc).
		// But as you can imagine, this list starts to get pretty big.
		// This is where the hashing stuff comes into play.
		// Most people running the same version of the same client are going to have the same list of capabilities.
		// So the protocol defines a standardized way to hash the list of capabilities.
		// Clients then broadcast the tiny hash instead of the big list.
		// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
		// and also persistently storing the hashes so lookups aren't needed in the future.
		//
		// Similarly to the roster, the storage of the module is abstracted.
		// You are strongly encouraged to persist caps information across sessions.
		//
		// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
		// It can also be shared amongst multiple streams to further reduce hash lookups.
		
		xmppCapabilitiesStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
		xmppCapabilities = XMPPCapabilities(capabilitiesStorage: xmppCapabilitiesStorage)
		
		xmppCapabilities!.autoFetchHashedCapabilities = true;
		xmppCapabilities!.autoFetchNonHashedCapabilities = false;
		
		xmppMessageDeliveryRecipts = XMPPMessageDeliveryReceipts(dispatchQueue: dispatch_get_main_queue())
		xmppMessageDeliveryRecipts!.autoSendMessageDeliveryReceipts = true
		xmppMessageDeliveryRecipts!.autoSendMessageDeliveryRequests = true
		
		// Activate xmpp modules
		xmppReconnect!.activate(xmppStream)
		xmppRoster!.activate(xmppStream)
		xmppvCardTempModule!.activate(xmppStream)
		xmppvCardAvatarModule!.activate(xmppStream)
		xmppCapabilities!.activate(xmppStream)
		xmppMessageDeliveryRecipts!.activate(xmppStream)
		
		// Add ourself as a delegate to anything we may be interested in
		xmppStream!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
		xmppRoster!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
		
		xmppStream!.addDelegate(messageTest, delegateQueue: dispatch_get_main_queue())
		xmppRoster!.addDelegate(messageTest, delegateQueue: dispatch_get_main_queue())
		
		xmppStream!.addDelegate(rosterTest, delegateQueue: dispatch_get_main_queue())
		xmppRoster!.addDelegate(rosterTest, delegateQueue: dispatch_get_main_queue())
		
		xmppStream!.addDelegate(presenceTest, delegateQueue: dispatch_get_main_queue())
		xmppRoster!.addDelegate(presenceTest, delegateQueue: dispatch_get_main_queue())
		
		// Optional:
		//
		// Replace me with the proper domain and port.
		// The example below is setup for a typical google talk account.
		//
		// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
		// For example, if you supply a JID like 'user@quack.com/rsrc'
		// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
		//
		// If you don't specify a hostPort, then the default (5222) will be used.
		
		//	[xmppStream setHostName:@"talk.google.com"];
		//	[xmppStream setHostPort:5222];
		
		
		// You may need to alter these settings depending on the server you're connecting to
		customCertEvaluation = true;
	}
	
	private func teardownStream() {
		xmppStream!.removeDelegate(self)
		xmppRoster!.removeDelegate(self)
		
		xmppReconnect!.deactivate()
		xmppRoster!.deactivate()
		xmppvCardTempModule!.deactivate()
		xmppvCardAvatarModule!.deactivate()
		xmppCapabilities!.deactivate()
		OneMessage.sharedInstance.xmppMessageArchiving!.deactivate()
		xmppStream!.disconnect()
		
		OneMessage.sharedInstance.xmppMessageStorage = nil;
		xmppStream = nil;
		xmppReconnect = nil;
		xmppRoster = nil;
		xmppRosterStorage = nil;
		xmppvCardStorage = nil;
		xmppvCardTempModule = nil;
		xmppvCardAvatarModule = nil;
		xmppCapabilities = nil;
		xmppCapabilitiesStorage = nil;
	}
	
	// MARK: Connect / Disconnect
	
	func connect() -> Bool {
		if !xmppStream!.isDisconnected() {
			return true
		}
		
		let myJID = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID)
		let myPassword = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myPassword)
		
		if let jid = myJID {
			xmppStream?.myJID = XMPPJID.jidWithString(jid)
		} else {
			return false
		}
		
		if let password = myPassword {
			self.password = password
		} else {
			return false
		}
		
		if !xmppStream!.connectWithTimeout(XMPPStreamTimeoutNone, error: nil) {
			let alert = UIAlertController(title: "Error connecting", message: "See console for error details.", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
			UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
			
			return false
		}
		return true;
	}
	
	func disconnect() {
		OnePresence.goOffline()
		xmppStream?.disconnect()
	}
}

// MARK: XMPPStream Delegate

extension OneChat: XMPPStreamDelegate {
	
	func xmppStream(sender: XMPPStream?, socketDidConnect socket: GCDAsyncSocket?) {
		delegate?.oneStream(sender, socketDidConnect: socket)
	}
	
	func xmppStream(sender: XMPPStream?, willSecureWithSettings settings: NSMutableDictionary?) {
		let expectedCertName: String? = xmppStream?.myJID.domain
		
		if expectedCertName != nil {
			settings![kCFStreamSSLPeerName as! String] = expectedCertName
		}
		if customCertEvaluation! {
			settings![GCDAsyncSocketManuallyEvaluateTrust] = true
		}
	}
	
	/**
	* Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
	*
	* This is only called if the stream is secured with settings that include:
	* - GCDAsyncSocketManuallyEvaluateTrust == YES
	* That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
	*
	* Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
	*
	* Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
	*
	* Note from Apple's documentation:
	*   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
	*   [it] might block while attempting network access. You should never call it from your main thread;
	*   call it only from within a function running on a dispatch queue or on a separate thread.
	*
	* This is why this method uses a completionHandler block rather than a normal return value.
	* The idea is that you should be performing SecTrustEvaluate on a background thread.
	* The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
	* It is safe to invoke the completionHandler block even if the socket has been closed.
	*
	* Keep in mind that you can do all kinds of cool stuff here.
	* For example:
	*
	* If your development server is using a self-signed certificate,
	* then you could embed info about the self-signed cert within your app, and use this callback to ensure that
	* you're actually connecting to the expected dev server.
	*
	* Also, you could present certificates that don't pass SecTrustEvaluate to the client.
	* That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
	* and then ask the client if the cert can be trusted. This is similar to how most browsers act.
	*
	* Generally, only one delegate should implement this method.
	* However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
	* And subsequent invocations of the completionHandler are ignored.
	**/
	
	func xmppStream(sender: XMPPStream, didReceiveTrust trust: SecTrustRef, completionHandler:
		XMPPStreamCompletionHandler) {
			let bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
			
			dispatch_async(bgQueue, { () -> Void in
				var result: SecTrustResultType =  kSecTrustResultDeny as! SecTrustResultType
				let status = SecTrustEvaluate(trust, &result)
				
				if status == noErr {
					completionHandler(shouldTrustPeer: true)
				} else {
					completionHandler(shouldTrustPeer: false)
				}
			})
	}
	
	func xmppStreamDidSecure(sender: XMPPStream) {
		//did secure
	}
	
	func xmppStreamDidConnect(sender: XMPPStream) {
		isXmppConnected = true
		
		if !xmppStream!.authenticateWithPassword(password, error: nil) {
			//Handle error
		}
	}
	
	func xmppStreamDidAuthenticate(sender: XMPPStream) {
		streamDidConnectCompletionBlock!(stream: sender, error: nil)
		OnePresence.goOnline()
	}
	
	func xmppStream(sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
		streamDidConnectCompletionBlock!(stream: sender, error: error)
	}
	
	func xmppStreamDidDisconnect(sender: XMPPStream, withError error: NSError) {
		delegate?.oneStreamDidDisconnect(sender, withError: error)
	}
}