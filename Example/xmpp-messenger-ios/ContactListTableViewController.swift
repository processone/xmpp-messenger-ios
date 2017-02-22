//
//  MainViewController.swift
//  OneChat
//
//  Created by Paul on 13/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import UIKit
import XMPPFramework

protocol ContactPickerDelegate{
	func didSelectContact(_ recipient: XMPPUserCoreDataStorageObject)
}

class ContactListTableViewController: UITableViewController, OneRosterDelegate {
	
	var delegate:ContactPickerDelegate?
	
	// Mark : Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		OneRoster.sharedInstance.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if OneChat.sharedInstance.isConnected() {
			navigationItem.title = "Select a recipient"
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		OneRoster.sharedInstance.delegate = nil
	}
	
	func oneRosterContentChanged(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.reloadData()
	}
	
	// Mark: UITableView Datasources
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sections: NSArray? =  OneRoster.buddyList.sections as NSArray?
		
		if section < sections!.count {
			let sectionInfo: AnyObject = sections![section] as AnyObject
			
			return sectionInfo.numberOfObjects
		}
		
		return 0;
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return OneRoster.buddyList.sections!.count
	}
	
	// Mark: UITableView Delegates
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections as NSArray?
		
		if section < sections!.count {
			let sectionInfo: AnyObject = sections![section] as AnyObject
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		_ = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
		
		delegate?.didSelectContact(OneRoster.userFromRosterAtIndexPath(indexPath: indexPath))
		close(self)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let user = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
		
		cell!.textLabel!.text = user.displayName;
		cell!.detailTextLabel?.isHidden = true
		
		if user.unreadMessages.intValue > 0 {
			cell!.backgroundColor = .orange
		} else {
			cell!.backgroundColor = .white
		}
		
		OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
		
		return cell!;
	}
	
	// Mark: Segue support
	
	override func prepare(for segue: UIStoryboardSegue?, sender: Any?) {
		if segue?.identifier != "One.HomeToSetting" {
			if let controller = segue?.destination as? ChatViewController {
				if let cell = sender as? UITableViewCell {
					let user = OneRoster.userFromRosterAtIndexPath(indexPath: tableView.indexPath(for: cell)!)
					controller.recipient = user
				}
			}
		}
	}
	
	// Mark: IBAction
	
	@IBAction func close(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// Mark: Memory Management
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
