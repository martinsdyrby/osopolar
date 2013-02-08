//
//  MExecute.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 20/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCommandMaster.h"

@interface MExecute : NSObject <MCommandMaster>

@property (retain) id command;

@end
