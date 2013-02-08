//
//  MViewableContext.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MStateManager.h"

@protocol MViewableContext <NSObject>

@property (retain) NSString* xib;
@property (retain) NSArray* depends;
@property (retain) NSString* containerName;
@property (retain) UIView* container;
@property (retain) id<MStateManager> manager;

@end
