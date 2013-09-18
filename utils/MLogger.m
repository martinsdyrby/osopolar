//
//  MLogger.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 29/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MLogger.h"

@implementation MLogger

static MLogger* instance= nil;
static int level = 3;

+ (MLogger*) getInstance {
    @synchronized(self) {
        if(instance == nil) {
            instance = [MLogger new];
        }
    }
    
    return instance;
}

+ (void) verboseWithFormat: (NSString*) format, ... {
    if(level == 0) {
        va_list args;
        va_start(args, format);
        NSLog(@"[MLogger] [VERBOSE] %@", [[NSString alloc] initWithFormat:format arguments:args]);
        va_end(args);
    }
}

+ (void) debugWithFormat: (NSString*) format, ... {
    if(level <= 1) {
        va_list args;
        va_start(args, format);
        NSLog(@"[MLogger] [DEBUG] %@", [[NSString alloc] initWithFormat:format arguments:args]);
        va_end(args);
    }
}
+ (void) errorWithFormat: (NSString*) format, ... {
    if(level <= 2) {
        va_list args;
        va_start(args, format);
        NSLog(@"[MLogger] [ERROR] %@", [[NSString alloc] initWithFormat:format arguments:args]);
        va_end(args);
    }
}
+ (void) infoWithFormat: (NSString*) format, ... {
    if(level <= 3) {
        va_list args;
        va_start(args, format);
        NSLog(@"[MLogger] [INFO] %@", [[NSString alloc] initWithFormat:format arguments:args]);
        va_end(args);
    }
}
+ (void) setLevelToVerbose {
    level = 0;
}
+ (void) setLevelToDebug {
    level = 1;
}
+ (void) setLevelToError {
    level = 2;
}
+ (void) setLevelToInfo {
    level = 3;
}
+ (void) setLevelToOff {
    level = 4;
}


@end
