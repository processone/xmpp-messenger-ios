//
//  ChatViewController.swift
//  OneChat
//
//  Created by Paul on 20/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import xmpp_messenger_ios
import JSQMessagesViewController
import XMPPFramework

class ChatViewController: JSQMessagesViewController, OneMessageDelegate, ContactPickerDelegate {
	
	let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
	var messages = NSMutableArray()
	var recipient: XMPPUserCoreDataStorageObject?
	var firstTime = true
	var lastSeenText: String?
    
    	let width = UIScreen.mainScreen().bounds.width
    	var userDetails = UIView?()
	
	// Mark: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		OneMessage.sharedInstance.delegate = self
  
		if OneChat.sharedInstance.isConnected() {
			self.senderId = OneChat.sharedInstance.xmppStream?.myJID.bare()
			self.senderDisplayName = OneChat.sharedInstance.xmppStream?.myJID.bare()
		}
		
		self.collectionView!.collectionViewLayout.springinessEnabled = true
		self.inputToolbar!.contentView!.leftBarButtonItem!.hidden = true
	}
	
	override func viewWillAppear(animated: Bool) {
		if let recipient = recipient {
			self.navigationItem.rightBarButtonItems = []

			self.lastActivity()
			
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
				self.finishReceivingMessageAnimated(true)
			})
		} else {
			self.inputToolbar!.contentView!.rightBarButtonItem!.enabled = false
			self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addRecipient"), animated: true)
			if firstTime {
				firstTime = false
				addRecipient()
			}
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.scrollToBottomAnimated(true)
	}
	
	override func viewWillDisappear(animated: Bool) {
        	userDetails?.removeFromSuperview()
    	}
	
	// Mark: Private methods
	
	func addRecipient() {
		let navController = self.storyboard?.instantiateViewControllerWithIdentifier("contactListNav") as? UINavigationController
		let contactController: ContactListTableViewController? = navController?.viewControllers[0] as? ContactListTableViewController
		contactController?.delegate = self
		
		self.presentViewController(navController!, animated: true, completion: nil)
	}
	
	func didSelectContact(recipient: XMPPUserCoreDataStorageObject) {
		self.recipient = recipient
		
		if !OneChats.knownUserForJid(jidStr: recipient.jidStr) {
			OneChats.addUserToChatList(jidStr: recipient.jidStr)
		} else {
			messages = OneMessage.sharedInstance.loadArchivedMessagesFrom(jid: recipient.jidStr)
			finishReceivingMessageAnimated(true)
		}
	}
	
	// Mark: JSQMessagesViewController method overrides
	
	override func textViewDidBeginEditing(textView: UITextView) {
		super.textViewDidBeginEditing(textView)
		
		if let recipient = recipient {
			OneMessage.sendIsComposingMessage(recipient.jidStr, completionHandler: { (stream, message) -> Void in
				//compose sent
			})
		}
	}
	
	override func textViewDidEndEditing(textView: UITextView) {
		super.textViewDidEndEditing(textView)
	
		if let recipient = recipient {
			OneMessage.sendIsNotComposingMessage(recipient.jidStr, completionHandler: { (stream, message) -> Void in
				//end compose sent
			})
		}
	}
	
	override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
		let fullMessage = JSQMessage(senderId: OneChat.sharedInstance.xmppStream?.myJID.bare(), senderDisplayName: OneChat.sharedInstance.xmppStream?.myJID.bare(), date: NSDate(), text: text)
		messages.addObject(fullMessage)
		
		if let recipient = recipient {
			OneMessage.sendMessage(text, to: recipient.jidStr, completionHandler: { (stream, message) -> Void in
				JSQSystemSoundPlayer.jsq_playMessageSentSound()
				self.finishSendingMessageAnimated(true)
			})
		}
	}
	
	// Mark: JSQMessages CollectionView DataSource
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		return message
	}
 
	override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		let bubbleFactory = JSQMessagesBubbleImageFactory()
		
		let outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
		let incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
		
		if message.senderId == self.senderId {
			return outgoingBubbleImageData
		}
		
		return incomingBubbleImageData
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		if message.senderId == self.senderId {
			if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoDataForJID(OneChat.sharedInstance.xmppStream?.myJID) {
				let senderAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: photoData), diameter: 30)
				return senderAvatar
			} else {
				let senderAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("SR", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0), diameter: 30)
				return senderAvatar
			}
		} else {
			if let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoDataForJID(recipient!.jid!) {
				let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: photoData), diameter: 30)
				return recipientAvatar
			} else {
				let recipientAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("SR", backgroundColor: UIColor(white: 0.85, alpha: 1.0), textColor: UIColor(white: 0.60, alpha: 1.0), font: UIFont(name: "Helvetica Neue", size: 14.0)!, diameter: 30)
				return recipientAvatar
			}
		}
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
		if indexPath.item % 3 == 0 {
			let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
			return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
		}
		
		return nil;
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
		let message: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		if message.senderId == self.senderId {
			return nil
		}
		
		if indexPath.item - 1 > 0 {
			let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
			if previousMessage.senderId == message.senderId {
				return nil
			}
		}
		
		return nil
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
		return nil
	}
	
	// Mark: UICollectionView DataSource
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.messages.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
		let msg: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		
		if !msg.isMediaMessage {
			if msg.senderId == self.senderId {
				cell.textView!.textColor = UIColor.blackColor()
				cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.blackColor(), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
			} else {
				cell.textView!.textColor = UIColor.whiteColor()
				cell.textView!.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
			}
		}
		
		return cell
	}
	
	// Mark: JSQMessages collection view flow layout delegate
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
		if indexPath.item % 3 == 0 {
			return kJSQMessagesCollectionViewCellLabelHeightDefault
		}
		
		return 0.0
	}
	
	override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
		let currentMessage: JSQMessage = self.messages[indexPath.item] as! JSQMessage
		if currentMessage.senderId == self.senderId {
			return 0.0
		}
		
		if indexPath.item - 1 > 0 {
			let previousMessage: JSQMessage = self.messages[indexPath.item - 1] as! JSQMessage
			if previousMessage.senderId == currentMessage.senderId {
				return 0.0
			}
		}
		
		return kJSQMessagesCollectionViewCellLabelHeightDefault
	}
 
	override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
		return 0.0
	}

	
	// Mark: Chat message Delegates
	
	func oneStream(sender: XMPPStream, didReceiveMessage message: XMPPMessage, from user: XMPPUserCoreDataStorageObject) {
		if message.isChatMessageWithBody() {
			//let displayName = user.displayName
			
			JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
			
			if let msg: String = message.elementForName("body")?.stringValue() {
				if let from: String = message.attributeForName("from")?.stringValue() {
					let message = JSQMessage(senderId: from, senderDisplayName: from, date: NSDate(), text: msg)
					messages.addObject(message)
					
					self.finishReceivingMessageAnimated(true)
				}
			}
		}
	}
	
	func oneStream(sender: XMPPStream, userIsComposing user: XMPPUserCoreDataStorageObject) {
		self.showTypingIndicator = !self.showTypingIndicator
		self.scrollToBottomAnimated(true)
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func lastActivity() {
        	OneLastActivity.sendLastActivityQueryToJID((recipient?.jidStr)!, sender: OneChat.sharedInstance.xmppLastActivity) { (response, forJID, error) -> Void in
            		if let timeInSeconds = response?.lastActivitySeconds() {
                		let time: NSNumber = NSNumber(unsignedLong: timeInSeconds)
                
                	if timeInSeconds == 0 {
                    		self.lastSeenText = "online"
                	}
                
                	if timeInSeconds > 0 && timeInSeconds < 60 {
                    		self.lastSeenText = "last seen \(timeInSeconds) seconds ago"
                	}
                
                	if timeInSeconds > 59 && timeInSeconds < 3600 {
                    		self.lastSeenText = "last seen \(timeInSeconds / 60) minutes ago"
                	}
                
                	if timeInSeconds > 3600 && timeInSeconds < 86400 {
                		self.lastSeenText = "last seen \(timeInSeconds / 3600) hours ago"
                	}
                
                	if timeInSeconds > 86400 {
                    		let date = NSDate(timeIntervalSinceNow:-time.doubleValue)
                    		let dateFormatter = NSDateFormatter()
                    
                    		dateFormatter.dateFormat = "dd.MM.yyyy"
                    		self.lastSeenText = "last seen on \(dateFormatter.stringFromDate(date))"
                	}
            	}
            	self.addValues(self.lastSeenText!)
        }
    }
    
    func addValues(text: String) {
        userDetails = UIView(frame: CGRect(x: (width - 140) / 2, y: 25, width: 140, height: 40))
        
        let displayName = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 17))
        displayName.text = self.recipient?.displayName
        displayName.textAlignment = .Center
        userDetails!.addSubview(displayName)
        
        let lastSeen = UILabel(frame: CGRect(x: 0, y: 20, width: 140, height: 12))
        lastSeen.text = text
        lastSeen.font = UIFont.systemFontOfSize(10)
        lastSeen.textAlignment = .Center
        userDetails!.addSubview(lastSeen)
        
        self.navigationController?.view.addSubview(userDetails!)
    }
}
