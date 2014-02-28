//
//  MObjectFactory.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPageContext.h"
#import "MBlockContext.h"
#import "MCommandContext.h"

@interface MObjectFactory : NSObject

- (id) initWithPages: (NSDictionary *) pages andBlocks: (NSDictionary *) blocks andCommands: (NSDictionary *) commands andProps: (NSDictionary*) props;

- (MPageContext *) getPageContextWithId: (NSString *) pageId;
- (MBlockContext *) getBlockContextWithId: (NSString *) blockId;
- (MCommandContext *) getCommandContextWithId: (NSString *) commandId;

@end
