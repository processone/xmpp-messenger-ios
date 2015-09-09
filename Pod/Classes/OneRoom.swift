//
//  OneMUC.swift
//  OneChat
//
//  Created by Paul on 03/03/2015.
//  Copyright (c) 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

typealias OneRoomCreationCompletionHandler = (sender: XMPPRoom) -> Void

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
  class func createRoom(roomName: String, delegate: AnyObject? = nil, completionHandler completion:OneRoomCreationCompletionHandler) {
    sharedInstance.didCreateRoomCompletionBlock = completion
    
    let roomMemoryStorage = XMPPRoomMemoryStorage()
    let domain = OneChat.sharedInstance.xmppStream!.myJID.domain
    let roomJID = XMPPJID.jidWithString("\(roomName)@conference.\(domain)")
    let xmppRoom = XMPPRoom(roomStorage: roomMemoryStorage, jid: roomJID, dispatchQueue: dispatch_get_main_queue())

    xmppRoom.activate(OneChat.sharedInstance.xmppStream)
    xmppRoom.addDelegate(delegate, delegateQueue: dispatch_get_main_queue())
    print(OneChat.sharedInstance.xmppStream!.myJID.bare())
    xmppRoom.joinRoomUsingNickname(OneChat.sharedInstance.xmppStream!.myJID.bare(), history: nil, password: nil)
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
  
  func xmppRoomDidCreate(sender: XMPPRoom!) {
    //[xmppRoom fetchConfigurationForm];
    print("room did create")
    didCreateRoomCompletionBlock!(sender: sender)
  }
  
  func xmppRoomDidLeave(sender: XMPPRoom!) {
    //
  }
  
  func xmppRoomDidJoin(sender: XMPPRoom!) {
      print("room did join")
  }
  
  func xmppRoomDidDestroy(sender: XMPPRoom!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didFetchConfigurationForm configForm: DDXMLElement!) {
    print("did fetch config \(configForm)")
  }
  
  func xmppRoom(sender: XMPPRoom!, willSendConfiguration roomConfigForm: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didConfigure iqResult: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didNotConfigure iqResult: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, occupantDidJoin occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, occupantDidLeave occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, occupantDidUpdate occupantJID: XMPPJID!, withPresence presence: XMPPPresence!) {
    //
  }
  
  /**
  * Invoked when a message is received.
  * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
  **/
  
  func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didFetchBanList items: [AnyObject]!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didNotFetchBanList iqError: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didFetchMembersList items: [AnyObject]!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didNotFetchMembersList iqError: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didFetchModeratorsList items: [AnyObject]!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didNotFetchModeratorsList iqError: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didEditPrivileges iqResult: XMPPIQ!) {
    //
  }
  
  func xmppRoom(sender: XMPPRoom!, didNotEditPrivileges iqError: XMPPIQ!) {
    //
  }
}