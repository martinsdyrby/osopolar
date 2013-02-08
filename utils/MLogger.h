//
//  MLogger.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 29/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLogger : NSObject
+ (void) verboseWithFormat: (NSString*) format, ...;
+ (void) debugWithFormat: (NSString*) format, ...;
+ (void) errorWithFormat: (NSString*) format, ...;
+ (void) infoWithFormat: (NSString*) format, ...;
+ (MLogger*) getInstance;
+ (void) setLevelToVerbose;
+ (void) setLevelToDebug;
+ (void) setLevelToError;
+ (void) setLevelToInfo;
+ (void) setLevelToOff;


@end
