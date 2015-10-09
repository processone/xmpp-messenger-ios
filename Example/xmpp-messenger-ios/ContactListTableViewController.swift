//
//  MainViewController.swift
//  OneChat
//
//  Created by Paul on 13/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios

protocol ContactPickerDelegate{
	func didSelectContact(recipient: XMPPUserCoreDataStorageObject)
}

class ContactListTableViewController: UITableViewController, OneRosterDelegate {
	
	var delegate:ContactPickerDelegate?
	
	// Mark : Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		OneRoster.sharedInstance.delegate = self
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if OneChat.sharedInstance.isConnected() {
			navigationItem.title = "Select a recipient"
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		OneRoster.sharedInstance.delegate = nil
	}
	
	func oneRosterContentChanged(controller: NSFetchedResultsController) {
		tableView.reloadData()
	}
	
	// Mark: UITableView Datasources
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sections: NSArray? =  OneRoster.buddyList.sections
		
		if section < sections!.count {
			let sectionInfo: AnyObject = sections![section]
			
			return sectionInfo.numberOfObjects
		}
		
		return 0;
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return OneRoster.buddyList.sections!.count
	}
	
	// Mark: UITableView Delegates
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
		
		if section < sections!.count {
			let sectionInfo: AnyObject = sections![section]
			let tmpSection: Int = Int(sectionInfo.name)!
			
			switch (tmpSection) {
			case 0 :
				return "Available"
				
			case 1 :
				return "Away"
				
			default :
				return "Offline"
				
			}
		}
		
		return ""
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		_ = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
		
		delegate?.didSelectContact(OneRoster.userFromRosterAtIndexPath(indexPath: indexPath))
		close(self)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		let user = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
		
		cell!.textLabel!.text = user.displayName;
		cell!.detailTextLabel?.hidden = true
		
		if user.unreadMessages.intValue > 0 {
			cell!.backgroundColor = .orangeColor()
		} else {
			cell!.backgroundColor = .whiteColor()
		}
		
		OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
		
		return cell!;
	}
	
	// Mark: Segue support
	
	override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
		if segue?.identifier != "One.HomeToSetting" {
			if let controller: ChatViewController? = segue?.destinationViewController as? ChatViewController {
				if let cell: UITableViewCell? = sender as? UITableViewCell {
					let user = OneRoster.userFromRosterAtIndexPath(indexPath: tableView.indexPathForCell(cell!)!)
					controller!.recipient = user
				}
			}
		}
	}
	
	// Mark: IBAction
	
	@IBAction func close(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}