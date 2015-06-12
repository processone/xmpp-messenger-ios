//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef xmpp-messenger-ios_Bridging_Header_h
#define xmpp-messenger-ios_Bridging_Header_h

#import <CoreData/CoreData.h>
#import <sqlite3.h>

#import "JSQMessagesViewController/JSQMessages.h"
#import "JSQSystemSoundPlayer.h"
//#import "CDAsyncSocket.h"

#import "XMPPFramework/XMPP.h"
#import "XMPPFramework/XMPPReconnect.h"
#import "XMPPFramework/XMPPCoreDataStorage.h"
#import "XMPPFramework/XMPPMessageArchiving.h"
#import "XMPPFramework/XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPFramework/XMPPMessageDeliveryReceipts.h"
#import "XMPPFramework/XMPPRoster.h"
#import "XMPPFramework/XMPPRosterMemoryStorage.h"
#import "XMPPFramework/XMPPRosterCoreDataStorage.h"
#import "XMPPFramework/XMPPvCardTempModule.h"
#import "XMPPFramework/XMPPvCardCoreDataStorage.h"
#import "XMPPFramework/XMPPCapabilities.h"
#import "XMPPFramework/XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPFramework/XMPPvCardAvatarModule.h"
#import "XMPPFramework/XMPPRoom.h"
#import "XMPPFramework/XMPPRoomMemoryStorage.h"

//#import "DDXML.h"
//#import "DDLog.h"

//#import <FMDB/FMDB.h>
//#import <FMDB/FMDB.h>

#endif