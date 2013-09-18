//
//  MDefinition.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MDefinition.h"
#import "MObjectUtil.h"
#import "MAppDelegate.h"

@interface MDefinition ()

@property (retain) UIViewController* viewController;

@end

static NSMutableDictionary* instances = nil;

@implementation MDefinition

@synthesize viewController;


- (void) doDisplay {

    viewController = [MDefinition getContextInstanceFromId:self.context.id];
    if(viewController == nil) {
        viewController = [[NSClassFromString(self.context.type) alloc] initWithNibName: self.context.xib bundle:nil];
        [MDefinition addContextInstance:viewController forId:self.context.id];
    }
    self.target = viewController;
    
    MAppDelegate *appDelegate = (MAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.viewHeight > -1) {
        CGRect f = viewController.view.frame;
        f.size.height = appDelegate.viewHeight;
        viewController.view.frame = f;
    }
    
    [self.context.container addSubview:viewController.view];
}

- (void) clear {
    [viewController.view removeFromSuperview];
}

- (void) destroy {}

+ (UIViewController*) getContextInstanceFromId: (NSString*) id {
    if(instances == nil) {
        instances = [[NSMutableDictionary alloc] init];
        return nil;
    }
    
    return [instances objectForKey:id];
}

+ (void) addContextInstance: (UIViewController*) instance forId: (NSString*) id {
    if(instances == nil) {
        instances = [[NSMutableDictionary alloc] init];
    }
    [instances setValue:instance forKey:id];
}

@end
