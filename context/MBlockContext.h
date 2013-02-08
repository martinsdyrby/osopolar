//
//  MBlockContext.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MViewableContext.h"
#import "MViewMaster.h"
#import "MContext.h"

@interface MBlockContext : NSObject<MViewableContext, MContext>

@property (retain) id<MViewMaster> master;

@end
