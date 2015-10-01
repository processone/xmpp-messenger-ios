//
//  GroupChatTableViewController.swift
//  OneChat
//
//  Created by Paul on 02/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework

class OpenChatsTableViewController: UITableViewController, OneRosterDelegate {
	
	var chatList = NSArray()
	
	// Mark: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		OneRoster.sharedInstance.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if OneChat.sharedInstance.connect() {
			//Set up online UI
		} else {
			performSegueWithIdentifier("One.HomeToSetting", sender: self)
		}
		
		tableView.rowHeight = 50
		tableView.reloadData()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		OneRoster.sharedInstance.delegate = nil
	}
	
	func oneRosterContentChanged(controller: NSFetchedResultsController) {
		tableView.reloadData()
	}
	
	// Mark: UITableViewCell helpers
	
	func configurePhotoForCell(cell: UITableViewCell, user: XMPPUserCoreDataStorageObject) {
		// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
		// We only need to ask the avatar module for a photo, if the roster doesn't have it.
		if user.photo != nil {
			cell.imageView!.image = user.photo!;
		} else {
			let photoData = OneChat.sharedInstance.xmppvCardAvatarModule?.photoDataForJID(user.jid)
			
			if let photoData = photoData {
				cell.imageView!.image = UIImage(data: photoData)
			} else {
				cell.imageView!.image = UIImage(named: "defaultPerson")
			}
		}
        
        OneLastActivity.sendLastActivityQueryToJID(user.jidStr, sender: OneChat.sharedInstance.xmppLastActivity) { (sender, error) -> Void in
            if let _ = error {
                
            }
            else if let timeInSeconds = sender?.lastActivitySeconds() {
                
                let seconds: NSNumber = NSNumber(unsignedLong: timeInSeconds)
                
                cell.detailTextLabel?.text = NSString(format: "Last seen %@", NSDate(timeIntervalSinceNow:seconds.doubleValue)) as String
                
            }
            
        }
        
	}
	
    
    
	// Mark: UITableView Datasources
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return OneChats.getChatsList().count
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		//let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
		return 1//sections
	}
	
	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		let user = OneChats.getChatsList().objectAtIndex(indexPath.row) as! XMPPUserCoreDataStorageObject
		
		cell!.textLabel!.text = user.displayName
		
		configurePhotoForCell(cell!, user: user)
		
		cell?.imageView?.layer.cornerRadius = 24// CGRectGetWidth(cell!.frame) / 2
		cell?.imageView?.clipsToBounds = true

		return cell!
	}
	
	// Mark: Segue support
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "chat.to.add" {
			if !OneChat.sharedInstance.connect() {
				let alert = UIAlertController(title: "Attention", message: "You have to be connected to start a chat", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
				
				self.presentViewController(alert, animated: true, completion: nil)
				
				return false
			}
		}
		return true
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
		if segue?.identifier == "chats.to.chat" {
			if let controller = segue?.destinationViewController as? ChatViewController {
				if let cell: UITableViewCell? = sender as? UITableViewCell {
					let user = OneChats.getChatsList().objectAtIndex(tableView.indexPathForCell(cell!)!.row) as! XMPPUserCoreDataStorageObject
					controller.recipient = user
				}
			}
		}
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}