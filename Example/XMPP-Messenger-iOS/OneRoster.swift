//
//  OneRoster.swift
//  OneChat
//
//  Created by Paul on 26/02/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

protocol OneRosterDelegate {
  func oneRosterContentChanged(controller: NSFetchedResultsController)
}

class OneRoster: NSObject, NSFetchedResultsControllerDelegate {
  var delegate: OneRosterDelegate?
  var fetchedResultsControllerVar: NSFetchedResultsController?
  
  // MARK: Singleton
	
  class var sharedInstance : OneRoster {
    struct OneRosterSingleton {
      static let instance = OneRoster()
    }
    return OneRosterSingleton.instance
  }
  
  class var buddyList: NSFetchedResultsController {
    get {
      if sharedInstance.fetchedResultsControllerVar != nil {
        return sharedInstance.fetchedResultsControllerVar!
      }
      return sharedInstance.fetchedResultsController()!
    }
  }
  
  // MARK: Core Data
	
  func managedObjectContext_roster() -> NSManagedObjectContext {
    return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
  }
  
  private func managedObjectContext_capabilities() -> NSManagedObjectContext {
    return OneChat.sharedInstance.xmppRosterStorage.mainThreadManagedObjectContext
  }
  
  func fetchedResultsController() -> NSFetchedResultsController? {
    if fetchedResultsControllerVar == nil {
      let moc = OneRoster.sharedInstance.managedObjectContext_roster() as NSManagedObjectContext?
      let entity = NSEntityDescription.entityForName("XMPPUserCoreDataStorageObject", inManagedObjectContext: moc!)
      let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
      let sd2 = NSSortDescriptor(key: "displayName", ascending: true)

      let sortDescriptors = [sd1, sd2]
      let fetchRequest = NSFetchRequest()
      
      fetchRequest.entity = entity
      fetchRequest.sortDescriptors = sortDescriptors
      fetchRequest.fetchBatchSize = 10
      
      fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
      fetchedResultsControllerVar?.delegate = self
		
		do {
			try fetchedResultsControllerVar!.performFetch()
		} catch let error as NSError {
			print("Error: \(error.localizedDescription)")
			abort()
		}
    //  if fetchedResultsControllerVar?.performFetch() == nil {
        //Handle fetch error
      //}
    }
    
    return fetchedResultsControllerVar!
  }
  
  class func userFromRosterAtIndexPath(indexPath indexPath: NSIndexPath) -> XMPPUserCoreDataStorageObject {
    return sharedInstance.fetchedResultsController()!.objectAtIndexPath(indexPath) as! XMPPUserCoreDataStorageObject
  }
  
  class func userFromRosterForJID(jid jid: String) -> XMPPUserCoreDataStorageObject? {
    let userJID = XMPPJID.jidWithString(jid)
    
    if let user = OneChat.sharedInstance.xmppRosterStorage.userForJID(userJID, xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: sharedInstance.managedObjectContext_roster()) {
      return user
    } else {
      return nil
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    delegate?.oneRosterContentChanged(controller)
  }
}

extension OneRoster: XMPPRosterDelegate {
  
  func xmppRoster(sender: XMPPRoster, didReceiveBuddyRequest presence:XMPPPresence) {
	//was let user
		_ = OneChat.sharedInstance.xmppRosterStorage.userForJID(presence.from(), xmppStream: OneChat.sharedInstance.xmppStream, managedObjectContext: managedObjectContext_roster())
  }
	
	func xmppRosterDidEndPopulating(sender: XMPPRoster?) {
		let jidList = OneChat.sharedInstance.xmppRosterStorage.jidsForXMPPStream(OneChat.sharedInstance.xmppStream)
		print("List=\(jidList)")
		
	}
}

extension OneRoster: XMPPStreamDelegate {
  
  func xmppStream(sender: XMPPStream, didReceiveIQ ip: XMPPIQ) -> Bool {
    if let msg = ip.attributeForName("from") {
      if msg.stringValue() == "conference.process-one.net"  {
        
      }
    }
    return false
  }
}