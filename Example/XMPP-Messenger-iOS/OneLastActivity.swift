//
//  OneLastActivity.swift
//  XMPP-Messenger-iOS
//
//  Created by Sean Batson on 2015-09-18.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

typealias OneMakeLastCallCompletionHandler = (sender: XMPPIQ) -> Void

class OneLastActivity: NSObject {

    var didMakeLastCallCompletionBlock: OneMakeLastCallCompletionHandler?
    
    // MARK: Singleton
    
    class var sharedInstance : OneLastActivity {
        struct OneLastActivitySingleton {
            static let instance = OneLastActivity()
        }
        return OneLastActivitySingleton.instance
    }
    
    // MARK: Functions
    
    class func sendLastActivityQueryToJID(userName: String, sender: XMPPLastActivity? = nil, completionHandler completion:OneMakeLastCallCompletionHandler) {
        
        sharedInstance.didMakeLastCallCompletionBlock = completion
        let userJID = XMPPJID.jidWithString("\(userName)")
        
        sender?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        sender?.sendLastActivityQueryToJID(userJID)
        
    }
}

extension OneLastActivity: XMPPLastActivityDelegate {

    
    func xmppLastActivity(sender: XMPPLastActivity!, didNotReceiveResponse queryID: String!, dueToTimeout timeout: NSTimeInterval) {

    }
    
    func xmppLastActivity(sender: XMPPLastActivity!, didReceiveResponse response: XMPPIQ!) {

        didMakeLastCallCompletionBlock!(sender: response)
        
    }
    
    func numberOfIdleTimeSecondsForXMPPLastActivity(sender: XMPPLastActivity!, queryIQ iq: XMPPIQ!, currentIdleTimeSeconds idleSeconds: UInt) -> UInt {
        return 30;
    }
    
}