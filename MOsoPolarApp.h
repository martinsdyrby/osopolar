//
//  MOsoPolarApp.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPageContext.h"
#import "MBlockContext.h"
#import "MCommandContext.h"
#import "MOsoPolarAppDelegate.h"

@interface MOsoPolarApp : UIViewController

- (id) initWithPlistName: (NSString *)name andNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil;
- (MPageContext *) gotoPageWithId: (NSString *) pageId andData: (NSDictionary *) data;
- (MBlockContext *) displayBlockWithId: (NSString *) blockId andData: (NSDictionary *) data;
- (MCommandContext *) executeCommandWithId: (NSString *) commandId andData: (NSDictionary *) data;
- (void) clearBlockWithId: (NSString *) blockId;

- (UIView*) addContainer: (UIView*) view withName: (NSString *) name;

@property (retain) id<MOsoPolarAppDelegate> delegate;
@property (retain) NSDictionary* props;

@end
