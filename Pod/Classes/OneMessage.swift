//
//  OneMessage.swift
//  OneChat
//
//  Created by Paul on 27/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
//import XMPPFramework

typealias OneChatMessageCompletionHandler = (stream: XMPPStream, message: XMPPMessage) -> Void

// MARK: Protocols

protocol OneMessageDelegate {
	func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
	func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

class OneMessage: NSObject {
	var delegate: OneMessageDelegate?
	
	var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
	var xmppMessageArchiving: XMPPMessageArchiving?
	var didSendMessageCompletionBlock: OneChatMessageCompletionHandler?
	
	// MARK: Singleton
	
	class var sharedInstance : OneMessage {
		struct OneMessageSingleton {
			static let instance = OneMessage()
		}
		
		return OneMessageSingleton.instance
	}
	
	// MARK: methods
	
	func setupArchiving() {
		xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
		xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
		
		xmppMessageArchiving?.clientSideMessageArchivingOnly = true
		xmppMessageArchiving?.activate(OneChat.sharedInstance.xmppStream)
		xmppMessageArchiving?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
	}
	
	class func sendMessage(message: String, to receiver: String, completionHandler completion:OneChatMessageCompletionHandler) {
		let body = DDXMLElement.elementWithName("body") as! DDXMLElement
		let messageID = OneChat.sharedInstance.xmppStream?.generateUUID()
		
		body.setStringValue(message)
		
		let completeMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
		
		completeMessage.addAttributeWithName("id", stringValue: messageID)
		completeMessage.addAttributeWithName("type", stringValue: "chat")
		completeMessage.addAttributeWithName("to", stringValue: receiver)
		completeMessage.addChild(body)
		
		sharedInstance.didSendMessageCompletionBlock = completion
		OneChat.sharedInstance.xmppStream?.sendElement(completeMessage)
	}
}

extension OneMessage: XMPPStreamDelegate {
	
	func xmppStream(sender: XMPPStream, didSendMessage message: XMPPMessage) {
		OneMessage.sharedInstance.didSendMessageCompletionBlock!(stream: sender, message: message)
	}
	
	func xmppStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage) {
		let user = OneChat.sharedInstance.xmppRosterStorage.userForJID(message.from(), xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: OneRoster.sharedInstance.managedObjectContext_roster())
		
		if !OneChats.knownUserForJid(jidStr: user.jidStr) {
			OneChats.addUserToChatList(jidStr: user.jidStr)
		}
		
		if message.isChatMessageWithBody() {
			OneMessage.sharedInstance.delegate?.oneStream(sender, didReceiveMessage: message, from: user)
		} else {
			//was composing
			if let _ = message.elementForName("composing") {
				OneMessage.sharedInstance.delegate?.oneStream(sender, userIsComposing: user)
			}
		}
	}
}