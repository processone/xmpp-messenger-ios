//
//  OneMessage.swift
//  OneChat
//
//  Created by Paul on 27/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import XMPPFramework

public typealias OneChatMessageCompletionHandler = (stream: XMPPStream, message: XMPPMessage) -> Void

// MARK: Protocols

public protocol OneMessageDelegate : NSObjectProtocol {
	func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject)
	func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject)
}

public class OneMessage: NSObject {
	public weak var delegate: OneMessageDelegate?
	
	public var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
	var xmppMessageArchiving: XMPPMessageArchiving?
	var didSendMessageCompletionBlock: OneChatMessageCompletionHandler?
	
	// MARK: Singleton
	
	public class var sharedInstance : OneMessage {
		struct OneMessageSingleton {
			static let instance = OneMessage()
		}
		
		return OneMessageSingleton.instance
	}
	
	// MARK: private methods
	
	func setupArchiving() {
		xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
		xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
		
		xmppMessageArchiving?.clientSideMessageArchivingOnly = true
		xmppMessageArchiving?.activate(OneChat.sharedInstance.xmppStream)
		xmppMessageArchiving?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
	}
	
	// MARK: public methods
	
	public class func sendMessage(message: String, thread:String, to receiver: String, completionHandler completion:OneChatMessageCompletionHandler) {
		let body = DDXMLElement.elementWithName("body") as! DDXMLElement
		let messageID = OneChat.sharedInstance.xmppStream?.generateUUID()
		
		body.setStringValue(message)
        
        let threadElement = DDXMLElement.elementWithName("thread") as! DDXMLElement
        threadElement.setStringValue(thread)
        
        
		
		let completeMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
		
		completeMessage.addAttributeWithName("id", stringValue: messageID)
		completeMessage.addAttributeWithName("type", stringValue: "chat")
		completeMessage.addAttributeWithName("to", stringValue: receiver)
		completeMessage.addChild(body)
        completeMessage.addChild(threadElement)
		
		sharedInstance.didSendMessageCompletionBlock = completion
		OneChat.sharedInstance.xmppStream?.sendElement(completeMessage)
	}
	
	public class func sendIsComposingMessage(recipient: String, thread: String,completionHandler completion:OneChatMessageCompletionHandler) {
		if recipient.characters.count > 0 {
			let message = DDXMLElement.elementWithName("message") as! DDXMLElement
			message.addAttributeWithName("type", stringValue: "chat")
			message.addAttributeWithName("to", stringValue: recipient)
			
			let composing = DDXMLElement.elementWithName("composing", stringValue: "http://jabber.org/protocol/chatstates") as! DDXMLElement
            composing.setNamespaces([DDXMLElement.namespaceWithName(nil , stringValue: "http://jabber.org/protocol/chatstates")]);
			message.addChild(composing)
            
            
            let threadElement = DDXMLElement.elementWithName("thread") as! DDXMLElement
            threadElement.setStringValue(thread)
            message.addChild(threadElement)
            
            
            
            
            print(message)
			
			sharedInstance.didSendMessageCompletionBlock = completion
			OneChat.sharedInstance.xmppStream?.sendElement(message)
		}
	}
	
    public func loadArchivedMessagesFrom(jid jid: String, thread: String) -> NSMutableArray {
		let moc = xmppMessageStorage?.mainThreadManagedObjectContext
		let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc!)
		let request = NSFetchRequest()
		let predicateFormat = "bareJidStr like %@ ANd thread like %@"
		let predicate = NSPredicate(format: predicateFormat, jid, thread)
		let retrievedMessages = NSMutableArray()
        var sortedRetrievedMessages = NSArray()
		
		request.predicate = predicate
		request.entity = entityDescription
		
		do {
			let results = try moc?.executeFetchRequest(request)
			
			for message in results! {
				var element: DDXMLElement!
				do {
					element = try DDXMLElement(XMLString: message.messageStr)
				} catch _ {
					element = nil
				}
				
				let body: String
				let sender: String
				let date: NSDate
				
				date = message.timestamp
				
				if message.body() != nil {
					body = message.body()
				} else {
					body = ""
				}
				
				if element.attributeStringValueForName("to") == jid {
					let displayName = OneChat.sharedInstance.xmppStream?.myJID
					sender = displayName!.bare()
				} else {
					sender = jid
				}
				
				let fullMessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date, text: body)
				retrievedMessages.addObject(fullMessage)
                
                
                let descriptor:NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true);
                
                sortedRetrievedMessages = retrievedMessages.sortedArrayUsingDescriptors([descriptor]);
 
			}
		} catch _ {
			//catch fetch error here
		}
		return sortedRetrievedMessages.mutableCopy() as! NSMutableArray
	}
	
	public func deleteMessagesFrom(jid jid: String, messages: NSArray) {
		messages.enumerateObjectsUsingBlock { (message, idx, stop) -> Void in
			let moc = self.xmppMessageStorage?.mainThreadManagedObjectContext
			let entityDescription = NSEntityDescription.entityForName("XMPPMessageArchiving_Message_CoreDataObject", inManagedObjectContext: moc!)
			let request = NSFetchRequest()
			let predicateFormat = "messageStr like %@ "
			let predicate = NSPredicate(format: predicateFormat, message as! String)
			
			request.predicate = predicate
			request.entity = entityDescription
			
			do {
				let results = try moc?.executeFetchRequest(request)
				
				for message in results! {
					var element: DDXMLElement!
					do {
						element = try DDXMLElement(XMLString: message.messageStr)
					} catch _ {
						element = nil
					}
					
					if element.attributeStringValueForName("messageStr") == message as! String {
						moc?.deleteObject(message as! NSManagedObject)
					}
				}
			} catch _ {
				//catch fetch error here
			}
		}
	}
}

extension OneMessage: XMPPStreamDelegate {
	
	public func xmppStream(sender: XMPPStream, didSendMessage message: XMPPMessage) {
		if let completion = OneMessage.sharedInstance.didSendMessageCompletionBlock {
			completion(stream: sender, message: message)
		}
		//OneMessage.sharedInstance.didSendMessageCompletionBlock!(stream: sender, message: message)
	}
	
	public func xmppStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage) {
        
        print(message.from());
        
		let user = OneChat.sharedInstance.xmppRosterStorage.userForJID(message.from(), xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: OneRoster.sharedInstance.managedObjectContext_roster())
		
		if !OneChats.knownUserForJid(jidStr: user.jidStr) {
			OneChats.addUserToChatList(jidStr: user.jidStr)
		}
		
		if message.isChatMessageWithBody() {
			OneMessage.sharedInstance.delegate?.oneStream(sender, didReceiveMessage: message, from: user)
		} else {
            
            print(message)
			//was composing
			if let _ = message.elementForName("composing") {
				OneMessage.sharedInstance.delegate?.oneStream(sender, userIsComposing: user)
			}
		}
	}
}
