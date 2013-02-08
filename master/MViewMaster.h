//
//  MMaster.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MStateManager.h"
#import "MViewableContext.h"
#import "MContext.h"

@protocol MViewMaster <NSObject>

- (void) display;
- (void) clear;
- (void) destroy;
- (BOOL) isDisplayed;
- (BOOL) isCleared;

@property (retain) id<MViewableContext, MContext> context;
@property (retain) id target;

@end
