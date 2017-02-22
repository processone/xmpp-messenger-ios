//
//  OneMUC.swift
//  OneChat
//
//  Created by Paul on 03/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

typealias OneRoomCreationCompletionHandler = (_ sender: XMPPRoom) -> Void

protocol OneRoomDelegate {
  //func onePresenceDidReceivePresence()
}

class OneRoom: NSObject {
  var delegate: OneRoomDelegate?
  
  var didCreateRoomCompletionBlock: OneRoomCreationCompletionHandler?
  
  // MARK: Singleton
  class var sharedInstance : OneRoom {
    struct OneRoomSingleton {
      static let instance = OneRoom()
    }
    return OneRoomSingleton.instance
  }
  
  //Handle nickname changes
  class func createRoom(_ roomName: String, delegate: AnyObject? = nil, completionHandler completion:@escaping OneRoomCreationCompletionHandler) {
    sharedInstance.didCreateRoomCompletionBlock = completion
    
    let roomMemoryStorage = XMPPRoomMemoryStorage()
    let domain = OneChat.sharedInstance.xmppStream!.myJID.domain
    let roomJID = XMPPJID(string: "\(roomName)@conference.\(domain)")
    let xmppRoom = XMPPRoom(roomStorage: roomMemoryStorage, jid: roomJID, dispatchQueue: DispatchQueue.main)!

    xmppRoom.activate(OneChat.sharedInstance.xmppStream)
    xmppRoom.addDelegate(delegate, delegateQueue: DispatchQueue.main)
    print(OneChat.sharedInstance.xmppStream!.myJID.bare() as String)
    xmppRoom.join(usingNickname: OneChat.sharedInstance.xmppStream!.myJID.bare(), history: nil, password: nil)
    xmppRoom.fetchConfigurationForm()
  }
}

extension OneRoom: XMPPRoomDelegate {
  /**
  * Invoked with the results of a request to fetch the configuration form.
  * The given config form will look something like:
  *
  * <x xmlns='jabber:x:data' type='form'>
  *   <title>Configuration for MUC Room</title>
  *   <field type='hidden'
  *           var='FORM_TYPE'>
  *     <value>http://jabber.org/protocol/muc#roomconfig</value>
  *   </field>
  *   <field label='Natural-Language Room Name'
  *           type='text-single'
  *            var='muc#roomconfig_roomname'/>
  *   <field label='Enable Public Logging?'
  *           type='boolean'
  *            var='muc#roomconfig_enablelogging'>
  *     <value>0</value>
  *   </field>
  *   ...
  * </x>
  *
  * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
  *
  * @see fetchConfigurationForm:
  * @see configureRoomUsingOptions:
  **/
  
  func xmppRoomDidCreate(_ sender: XMPPRoom!) {
    //[xmppRoom fetchConfigurationForm];
    print("room did create")
    didCreateRoomCompletionBlock!(sender)
  }
  
  func xmppRoomDidLeave(_ sender: XMPPRoom!) {
    //
  }
  
  func xmppRoomDidJoin(_ sender: XMPPRoom!) {
      print("room did join")
  }
  
  func xmppRoomDidDestroy(_ sender: XMPPRoom!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
    print("did fetch config \(configForm)")
  }
  
  func xmppRoom(_ sender: XMPPRoom!, willSendConfiguration roomConfigForm: XMPPIQ!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, didConfigure iqResult: XMPPIQ!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, didNotConfigure iqResult: XMPPIQ!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, with presence: XMPPPresence!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, with presence: XMPPPresence!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, with presence: XMPPPresence!) {
    //
  }
  
  /**
  * Invoked when a message is received.
  * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
  **/
  
  func xmppRoom(_ sender: XMPPRoom!, didReceive message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
    //
  }
    
    func xmppRoom(_ sender: XMPPRoom!, didFetchBanList items: [Any]!) {
        
    }
  
  func xmppRoom(_ sender: XMPPRoom!, didNotFetchBanList iqError: XMPPIQ!) {
    //
  }
  
    func xmppRoom(_ sender: XMPPRoom!, didFetchMembersList items: [Any]!) {
        
    }
  
  func xmppRoom(_ sender: XMPPRoom!, didNotFetchMembersList iqError: XMPPIQ!) {
    //
  }
  
    func xmppRoom(_ sender: XMPPRoom!, didFetchModeratorsList items: [Any]!) {
        
    }
    
  func xmppRoom(_ sender: XMPPRoom!, didNotFetchModeratorsList iqError: XMPPIQ!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, didEditPrivileges iqResult: XMPPIQ!) {
    //
  }
  
  func xmppRoom(_ sender: XMPPRoom!, didNotEditPrivileges iqError: XMPPIQ!) {
    //
  }
}
