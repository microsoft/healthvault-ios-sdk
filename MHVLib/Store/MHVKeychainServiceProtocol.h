//
//  MHVKeychainServiceProtocol.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/10/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MHVKeychainServiceProtocol <NSObject>


/**
 Fetches a string value stored in the keychain.

 @param key The key the string is stored under.
 @return The string value or nil if the no string could be found for the given key.
 */
- (NSString *)stringForKey:(NSString *)key;

/**
 Saves a string value to the keychain.

 @param string The string to be saved. If nil is passed as the string parameter, the string for key will be deleted.
 @param key The key used to save the string valuen under.
 @return YES if the save is successful NO if the save fails.
 */
- (BOOL)setString:(NSString *_Nullable)string forKey:(NSString *)key;

/**
 Deletes a string value from the keychain for a given key

 @param key The key the string value to be deleted is saved under.
 @return YES if the delete is successful, or the key is not found, NO if the delete fails.
 */
- (BOOL)removeStringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
