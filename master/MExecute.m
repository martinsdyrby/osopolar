//
//  MExecute.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 20/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MExecute.h"
#import "MCommandContext.h"
#import "MObjectUtil.h"

@implementation MExecute

@synthesize context;
@synthesize command;

- (id) build {

    command = [[NSClassFromString(context.type) alloc] init];
    
    [MObjectUtil mergeProps:context.props withObject:command];
    
    return command;
}

- (void) execute {

    [command performSelector:@selector(execute)];
    
}
@end
