//
//  MPageContext.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MViewMaster.h"
#import "MViewableContext.h"
#import "MContext.h"

@interface MPageContext : NSObject<MViewableContext, MContext>

@property (retain) id<MViewMaster> master;

@end
