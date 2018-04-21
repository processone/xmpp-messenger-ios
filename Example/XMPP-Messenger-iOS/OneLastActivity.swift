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

public typealias OneMakeLastCallCompletionHandler = (_ response: XMPPIQ?, _ forJID:XMPPJID?, _ error: DDXMLElement?) -> Void

open class OneLastActivity: NSObject {
	
	var didMakeLastCallCompletionBlock: OneMakeLastCallCompletionHandler?
	
	// MARK: Singleton
	
	open class var sharedInstance : OneLastActivity {
		struct OneLastActivitySingleton {
			static let instance = OneLastActivity()
		}
		return OneLastActivitySingleton.instance
	}
	
	// MARK: Public Functions
	
	open func getStringFormattedDateFrom(_ second: UInt) -> NSString {
		if second > 0 {
			let time = NSNumber(value: second as UInt)
			let interval = time.doubleValue
			let elapsedTime = Date(timeIntervalSince1970: interval)
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "HH:mm:ss"
			
			return dateFormatter.string(from: elapsedTime) as NSString
		} else {
			return ""
		}
	}
	
	open func getStringFormattedElapsedTimeFrom(_ date: Date!) -> String {
		var elapsedTime = "nc"
		let startDate = Date()
		let components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: date, to: startDate, options: NSCalendar.Options.matchStrictly)
		
		if nil == date {
			return elapsedTime
		}
		
		if 52 < components.weekOfYear! {
			elapsedTime = "more than a year"
		} else if 1 <= components.weekOfYear! {
			if 1 < components.weekOfYear! {
				elapsedTime = "\(components.weekOfYear) weeks"
			} else {
				elapsedTime = "\(components.weekOfYear) week"
			}
		} else if 1 <= components.day! {
			if 1 < components.day! {
				elapsedTime = "\(components.day) days"
			} else {
				elapsedTime = "\(components.day) day"
			}
		} else if 1 <= components.hour! {
			if 1 < components.hour! {
				elapsedTime = "\(components.hour) hours"
			} else {
				elapsedTime = "\(components.hour) hour"
			}
		} else if 1 <= components.minute! {
			if 1 < components.minute! {
				elapsedTime = "\(components.minute) minutes"
			} else {
				elapsedTime = "\(components.minute) minute"
			}
		} else if 1 <= components.second! {
			if 1 < components.second! {
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
	open func getLastActivityFrom(_ timeInSeconds: UInt) -> String {
        	let time: NSNumber = NSNumber(value: timeInSeconds as UInt)
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
            			let date = Date(timeIntervalSinceNow:-time.doubleValue)
			        let dateFormatter = DateFormatter()
            
			        dateFormatter.dateFormat = "dd.MM.yyyy"
            	    lastSeenInfo = "last seen on \(dateFormatter.string(from: date))"
		        default:
            		lastSeenInfo = "never been online"
        	}
        
        return lastSeenInfo
    }
    
    // Add Last Activity Details to NavigationBar
    open func addLastActivityLabelToNavigationBar(_ lastActivityText: String, displayName: String) -> UIView {
        var userDetails: UIView?
        let width = UIScreen.main.bounds.width
        
        userDetails = UIView(frame: CGRect(x: (width - 140) / 2, y: 25, width: 140, height: 40))
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 17))
        title.text = displayName
        title.textAlignment = .center
        userDetails!.addSubview(title)
        
        let lastSeen = UILabel(frame: CGRect(x: 0, y: 20, width: 140, height: 12))
        lastSeen.text = lastActivityText
        lastSeen.font = UIFont.systemFont(ofSize: 10)
        lastSeen.textAlignment = .center
        userDetails!.addSubview(lastSeen)
        
        return userDetails!
    }
	
	open class func sendLastActivityQueryToJID(_ userName: String, sender: XMPPLastActivity? = nil, completionHandler completion:@escaping OneMakeLastCallCompletionHandler) {
		sharedInstance.didMakeLastCallCompletionBlock = completion
		let userJID = XMPPJID(string: userName)
		
		_ = sender?.sendQuery(to: userJID)
	}
}

extension OneLastActivity: XMPPLastActivityDelegate {
	
	public func xmppLastActivity(_ sender: XMPPLastActivity!, didNotReceiveResponse queryID: String!, dueToTimeout timeout: TimeInterval) {
		if let callback = OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
			callback(nil, nil ,DDXMLElement(name: "TimeOut"))
		}
	}
	
	public func xmppLastActivity(_ sender: XMPPLastActivity!, didReceiveResponse response: XMPPIQ!) {
		if let callback = OneLastActivity.sharedInstance.didMakeLastCallCompletionBlock {
			if let resp = response {
				if resp.forName("error") != nil {
					if let from = resp.value(forKey: "from") {
                        callback(resp, XMPPJID(string: "\(from)"), resp.forName("error"))
					} else {
						callback(resp, nil, resp.forName("error"))
					}
				} else {
					if let from = resp.attribute(forName: "from") {
                        callback(resp, XMPPJID(string: "\(from)"), nil)
					} else {
						callback(resp, nil, nil)
					}
				}
			}
		}
	}
	
	public func numberOfIdleTimeSeconds(for sender: XMPPLastActivity!, queryIQ iq: XMPPIQ!, currentIdleTimeSeconds idleSeconds: UInt) -> UInt {
		return 30
	}
}
