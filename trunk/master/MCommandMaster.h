//
//  MCommandMaster.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 20/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCommandContext;

@protocol MCommandMaster <NSObject>

@property (retain) MCommandContext* context;

- (id) build;
- (void) execute;

@end
