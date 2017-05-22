//
// MHVPersistedDataService.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

@protocol MHVPersistedDataService <NSObject>

NS_ASSUME_NONNULL_BEGIN

/*!
 * @brief Method to retrieve the root directory for all app file storage
 */
- (nullable NSString *)documentsDirectory;

/*!
 * @brief Method to retrieve a subfolder under the root directory
 */
- (nullable NSString *)documentsSubDirectoryWithName:(NSString *)name;

/*!
 * @brief Method to retrieve the path to a file in the root directory
 */
- (nullable NSString *)documentsFileWithName:(NSString *)name;

/*!
 * @brief Method to retrieve a folder that is safe to be persisted when the user signs out
 *        Primarily for common static data such as the web bridge package
 */
- (nullable NSString *)documentsDirectoryForDataThatCanBePersistedOnSignOut:(NSString *)name;

/*!
 * @brief Method to retrieve a file that is safe to be persisted when the user signs out
 */
- (nullable NSString *)documentsFileForDataThatCanBePersistedOnSignOut:(NSString *)name;

/*!
 * @brief Wrapers for NSObject - (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile; methods
 */
- (BOOL)writeData:(NSData *)data toFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeData:(NSData *)data toFile:(NSString *)path options:(NSDataWritingOptions)options error:(NSError **)error;
- (BOOL)writeString:(NSString *)string toFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc;
- (BOOL)writeString:(NSString *)string toFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;

/*!
 * @brief Wrapers for NSFileManager creation methods
 */
- (BOOL)createFileAtPath:(NSString *)path contents:(nullable NSData *)data attributes:(nullable NSDictionary<NSString *, id> *)attr;

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSString *, id> *)attributes error:(NSError **)error;

/*!
 * @brief Wrapers for Stream and File Handle methods
 */
- (nullable NSOutputStream *)outputStreamToFileAtPath:(NSString *)path append:(BOOL)shouldAppend;
- (nullable NSFileHandle *)fileHandleForWritingAtPath:(NSString *)path;

/*!
 * @brief Wrapers for NSFileManager methods
 */
- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;
- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)fileExistsAtPath:(NSString *)path;
- (nullable NSDictionary<NSString *, id> *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;
- (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

- (BOOL)deleteFilesAtPaths:(NSArray<NSString *> *)paths error:(NSError **)pError;

/*!
 * @brief Filtered folder contents
 */
- (nullable NSArray *)filteredContentsOfDirectoryAtPath:(NSString *)path
                                              predicate:(NSPredicate *)predicate
                                                  error:(NSError **)pError;

/*!
 * @brief Returns a filtered, sorted list of dictionaries where each dictionary has key/value for <filePath> and <fileAttribute>.
 * @return (NSArray<NSDictionary *> *)
 */
- (nullable NSArray<NSDictionary *> *)filteredContentsWithAttributeOfDirectoryAtPath:(NSString *)path
                                                                           predicate:(NSPredicate *)predicate
                                                                 sortByFileAttribute:(NSString *)fileAttribute
                                                                           decending:(BOOL)decending
                                                                               error:(NSError **)pError;

/*!
 * @brief Return a list of <filePaths> present in directory at <path> filtered by <predicate> and sorted by <fileAttribute>
 * @return (NSArray<NSString *> *) Array of string filePaths.
 */
- (nullable NSArray<NSString *> *)filteredContentsOfDirectoryAtPath:(NSString *)path
                                                          predicate:(NSPredicate *)predicate
                                                sortByFileAttribute:(NSString *)fileAttribute
                                                          decending:(BOOL)decending
                                                              error:(NSError **)pError;

/*!
 * @brief protect a file with iOS NSFileProtectionCompleteUntilFirstUserAuthentication. It also marks the file so it will not be backed up
 */
- (void)protectItemAtPath:(NSString *)path;

NS_ASSUME_NONNULL_END

@end
