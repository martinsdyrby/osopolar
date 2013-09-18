//
//  MObjectUtil.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 20/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MObjectUtil.h"
#import "MLogger.h"
@implementation MObjectUtil

+ (void) mergeProps: (NSDictionary *) props withObject: (id) object {
    if(props == nil) return;
    if([props isKindOfClass:[NSDictionary class]]) {
        NSEnumerator *e = [props keyEnumerator];
        NSString* propKey;
        while (propKey = [e nextObject]) {
            NSObject* propValue = [props objectForKey:propKey];
        
            [MLogger debugWithFormat:@"MObjectUtil (%@)",propKey];
            @try {
                [object setValue: propValue forKey: propKey];
            }
            @catch (NSException* e) {
                if ([[e name] isEqualToString:NSUndefinedKeyException]) {
                    [MLogger errorWithFormat:@"NSException for %@ on %@", propKey, object];
                } else {
                    [e raise];
                }
            }
        }
    } else {
        [MLogger errorWithFormat:@"MObjectUtil %@ is not a NSDictionary", props];
    }
}


@end
