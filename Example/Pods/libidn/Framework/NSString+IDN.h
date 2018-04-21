#import <Foundation/Foundation.h>

// This file is originally from XMPPFramework XMPPStringPrep
// https://github.com/robbiehanson/XMPPFramework
//
// It is difficult/impossible to use libidn directly from Swift
// because the generated interface is missing a lot of crucial information.

NS_ASSUME_NONNULL_BEGIN
@interface NSString (IDN)

/**
 * Preps a node identifier for use in a JID.
 * If the given node is invalid, this method returns nil.
 *
 * See the XMPP RFC (6120) for details.
 *
 * Note: The prep properly converts the string to lowercase, as per the RFC.
 **/
+ (nullable NSString *)idn_prepNode:(NSString *)node;

/**
 * Preps a domain name for use in a JID.
 * If the given domain is invalid, this method returns nil.
 *
 * See the XMPP RFC (6120) for details.
 **/
+ (nullable NSString *)idn_prepDomain:(NSString *)domain;

/**
 * Preps a resource identifier for use in a JID.
 * If the given node is invalid, this method returns nil.
 *
 * See the XMPP RFC (6120) for details.
 **/
+ (nullable NSString *)idn_prepResource:(NSString *)resource;

/**
 * Preps a password with SASLprep profile.
 * If the given string is invalid, this method returns nil.
 *
 * See the SCRAM RFC (5802) for details.
 **/

+ (nullable NSString *)idn_prepPassword:(NSString *)password;

@end
NS_ASSUME_NONNULL_END
