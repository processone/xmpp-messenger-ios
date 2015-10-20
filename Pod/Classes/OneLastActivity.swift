//
//  OneLastActivity.swift
//  XMPP-Messenger-iOS
//
//  Created by Sean Batson on 2015-09-18.
//  Edited by Paul LEMAIRE on 2015-10-09.
//  Copyright © 2015 ProcessOne. All rights reserved.
//

import Foundation
import XMPPFramework

public typealias OneMakeLastCallCompletionHandler = (response: XMPPIQ?, forJID:XMPPJID?, error: DDXMLElement?) -> Void

public class OneLastActivity: NSObject {
	
	var didMakeLastCallCompletionBlock: OneMakeLastCallCompletionHandler?
	
	// MARK: Singleton
	
	public class var sharedInstance : OneLastActivity {
		struct OneLastActivitySingleton {
			static let instance = OneLastActivity()
		}
		return OneLastActivitySingleton.instance
	}
	
	// MARK: Public Functions
	
	public func getStringFormattedDateFrom(second: UInt) -> NSString {
		if second > 0 {
			let time = NSNumber(unsignedLong: second)
			let interval = time.doubleValue
			let elapsedTime = NSDate(timeIntervalSince1970: interval)
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "HH:mm:ss"
			
			return dateFormatter.stringFromDate(elapsedTime)
		} else {
			return ""
		}
	}
	
	public func getStringFormattedElapsedTimeFrom(date: NSDate!) -> String {
		var elapsedTime = "nc"
		let startDate = NSDate()
		let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: startDate, options: NSCalendarOptions.MatchStrictly)
		
		if nil == date {
			return elapsedTime
		}
		
		if 52 < components.weekOfYear {
			elapsedTime = "more than a year"
		} else if 1 <= components.weekOfYear {
			if 1 < components.weekOfYear {
				elapsedTime = "\(components.weekOfYear) weeks"
			} else {
				elapsedTime = "\(components.weekOfYear) week"
			}
		} else if 1 <= components.day {
			if 1 < components.day {
				elapsedTime = "\(components.day) days"
			} else {
				elapsedTime = "\(components.day) day"
			}
		} else if 1 <= components.hour {
			if 1 < components.hour {
				elapsedTime = "\(components.hour) hours"
			} else {
				elapsedTime = "\(components.hour) hour"
			}
		} else if 1 <= components.minute {
			if 1 < components.minute {
				elapsedTime = "\(components.minute) minutes"
			} else {
				elapsedTime = "\(components.minute) minute"
			}
		} else if 1 <= components.second {
			if 1 < components.second {
				elapsedTime = "\(components.second) seconds"
			} else {
				elapsedTime = "\(components.second) second"
			}
		} else {
			elapsedTime = "now"
		}
		
		return elapsedTime
	}
	
	// Mark: Simple last activity converter
	public func getLastActivityFrom(timeInSeconds: UInt) -> String {
        	let time: NSNumber = NSNumber(unsignedLong: timeInSeconds)
        	var lastSeenInfo = ""
        
        	switch timeInSeconds {
        		case 0:
            			lastSeenInfo = "online"
        		case _ where timeInSeconds > 0 && timeInSeconds < 60:
            			lastSeenInfo = "last seen \(timeInSeconds) seconds ago"
        		case _ where timeInSeconds > 59 && timeInSeconds < 3600:
            			lastSeenInfo = "last seen \(timeInSeconds / 60) minutes ago"
        		case _ where timeInSeconds > 3600 && timeInSeconds < 86400:
			            lastSeenInfo = "last seen \(timeInSeconds / 3600) hours ago"
        		case _ where timeInSeconds > 86400:
            			let date = NSDate(timeIntervalSinceNow:-time.doubleValue)
			        let dateFormatter = NSDateFormatter()
            
			        dateFormatter.dateFormat = "dd.MM.yyyy"
            	    lastSeenInfo = "last seen on \(dateFormatter.stringFromDate(date))"
		        default:
            		lastSeenInfo = "never been online"
        	}
        
        return lastSeenInfo
    }
    
    // Add Last Activity Details to NavigationBar
    public func addLastActivityLabelToNavigationBar(lastActivityText: String, displayName: String) -> UIView {
        var userDetails: UIView?
        let width = UIScreen.mainScreen().bounds.width
        
        userDetails = UIView(frame: CGRect(x: (width - 140) / 2, y: 25, width: 140, height: 40))
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 17))
        title.text = displayName
        title.textAlignment = .Center
        userDetails!.addSubview(title)
        
        let lastSeen = UILabel(frame: CGRect(x: 0, y: 20, width: 140, height: 12))
        lastSeen.text = lastActivityText
        lastSeen.font = UIFont.systemFontOfSize(10)
        lastSeen.textAlignment = .Center
        userDetails!.addSubview(lastSeen)
        
        return userDetails!
    }
	
	public class func sendLastActivityQueryToJID(userName: String, sender: XMPPLastActivity? = nil, completionHandler completion:OneMakeLastCallCompletionHandler) {
		sharedInstance.didMakeLastCallCompletionBlock = completion
		let userJID = XMPPJID.jidWithString(userName)
		
		sender?.sendLastActivityQueryToJID(userJID)
	}
}

extension OneLastActivity: XMPPLastActivityDelegate {
	
	public func xmppLastActivity(sender: XMPPLastActivity!, didNotReceiveResponse queryID: String!, dueToTimeout timeout: NSTimeInterval) {
		if let callback = OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
			callback(response: nil, forJID:nil ,error: DDXMLElement(name: "TimeOut"))
		}
	}
	
	public func xmppLastActivity(sender: XMPPLastActivity!, didReceiveResponse response: XMPPIQ!) {
		if let callback = OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
			if let resp = response {
				if resp.elementForName("error") != nil {
					if let from = resp.valueForKey("from") {
						callback(response: resp, forJID: XMPPJID.jidWithString("\(from)"), error: resp.elementForName("error"))
					} else {
						callback(response: resp, forJID: nil, error: resp.elementForName("error"))
					}
				} else {
					if let from = resp.attributeForName("from") {
						callback(response: resp, forJID: XMPPJID.jidWithString("\(from)"), error: nil)
					} else {
						callback(response: resp, forJID: nil, error: nil)
					}
				}
			}
		}
	}
	
	public func numberOfIdleTimeSecondsForXMPPLastActivity(sender: XMPPLastActivity!, queryIQ iq: XMPPIQ!, currentIdleTimeSeconds idleSeconds: UInt) -> UInt {
		return 30
	}
}
