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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		OneRoster.sharedInstance.delegate = self
		OneChat.sharedInstance.connect(username: kXMPP.myJID, password: kXMPP.myPassword) { (stream, error) -> Void in
			if let _ = error {
				self.performSegue(withIdentifier: "One.HomeToSetting", sender: self)
			} else {
				//set up online UI
			}
		}
		
		tableView.rowHeight = 50
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		OneRoster.sharedInstance.delegate = nil
	}
	
	// Mark: OneRoster Delegates
	
	func oneRosterContentChanged(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		//Will reload the tableView to reflet roster's changes
		tableView.reloadData()
	}
	
	// Mark: UITableView Datasources
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return OneChats.getChatsList().count
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		//let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
		return 1//sections
	}
	
	// Mark: UITableView Delegates
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0.01
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let user = OneChats.getChatsList().object(at: indexPath.row) as! XMPPUserCoreDataStorageObject
		
		cell!.textLabel!.text = user.displayName
		cell!.detailTextLabel?.isHidden = true
		
		OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
		
		cell?.imageView?.layer.cornerRadius = 24
		cell?.imageView?.clipsToBounds = true
		
		return cell!
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == UITableViewCellEditingStyle.delete {
			let refreshAlert = UIAlertController(title: "", message: "Are you sure you want to clear the entire message history? \n This cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            		refreshAlert.addAction(UIAlertAction(title: "Clear message history", style: .destructive, handler: { (action: UIAlertAction!) in
                		OneChats.removeUserAtIndexPath(indexPath)
                		tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            		}))
            
            		refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

            		}))
            
            		present(refreshAlert, animated: true, completion: nil)
		}
	}
	
	// Mark: Segue support
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if identifier == "chat.to.add" {
			if !OneChat.sharedInstance.isConnected() {
				let alert = UIAlertController(title: "Attention", message: "You have to be connected to start a chat", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
				
				self.present(alert, animated: true, completion: nil)
				
				return false
			}
		}
		return true
	}
	
	override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
		if segue?.identifier == "chats.to.chat" {
			if let controller = segue?.destination as? ChatViewController {
				if let cell: UITableViewCell? = sender as? UITableViewCell {
					let user = OneChats.getChatsList().object(at: tableView.indexPath(for: cell!)!.row) as! XMPPUserCoreDataStorageObject
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
