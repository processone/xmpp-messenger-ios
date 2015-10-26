//
//  GroupChatTableViewController.swift
//  OneChat
//
//  Created by Paul on 02/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import xmpp_messenger_ios
import XMPPFramework

class OpenChatsTableViewController: UITableViewController, OneRosterDelegate {
	
	var chatList = NSArray()
	
	// Mark: Life Cycle
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		OneRoster.sharedInstance.delegate = self
		OneChat.sharedInstance.connect(username: kXMPP.myJID, password: kXMPP.myPassword) { (stream, error) -> Void in
			if let _ = error {
				self.performSegueWithIdentifier("One.HomeToSetting", sender: self)
			} else {
				//set up online UI
			}
		}
		
		tableView.rowHeight = 50
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		OneRoster.sharedInstance.delegate = nil
	}
	
	// Mark: OneRoster Delegates
	
	func oneRosterContentChanged(controller: NSFetchedResultsController) {
		//Will reload the tableView to reflet roster's changes
		tableView.reloadData()
	}
	
	// Mark: UITableView Datasources
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return OneChats.getChatsList().count
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		//let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
		return 1//sections
	}
	
	// Mark: UITableView Delegates
	
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
		cell!.detailTextLabel?.hidden = true
		
		OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
		
		cell?.imageView?.layer.cornerRadius = 24
		cell?.imageView?.clipsToBounds = true
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			let refreshAlert = UIAlertController(title: "", message: "Are you sure you want to clear the entire message history? \n This cannot be undone.", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            		refreshAlert.addAction(UIAlertAction(title: "Clear message history", style: .Destructive, handler: { (action: UIAlertAction!) in
                		OneChats.removeUserAtIndexPath(indexPath)
                		tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            		}))
            
            		refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in

            		}))
            
            		presentViewController(refreshAlert, animated: true, completion: nil)
		}
	}
	
	// Mark: Segue support
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "chat.to.add" {
			if !OneChat.sharedInstance.isConnected() {
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
