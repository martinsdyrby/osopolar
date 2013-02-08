//
//  MOsoPolarAppDelegate.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 19/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MContext.h"
@protocol MOsoPolarAppDelegate <NSObject>

- (void) pageRequestedWithContext: (id<MContext>) context;

@end
