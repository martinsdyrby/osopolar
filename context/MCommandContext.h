//
//  MCommandContext.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MContext.h"
#import "MCommandMaster.h"

@interface MCommandContext : NSObject <MContext>

@property (retain) id<MCommandMaster> master;

@end
