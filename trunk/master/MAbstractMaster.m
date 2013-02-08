//
//  MAbstractMaster.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 29/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MAbstractMaster.h"
#import "MObjectUtil.h"

@interface MAbstractMaster ()

@property (assign) BOOL _isDisplayed;
@property (assign) BOOL _isCleared;

@end

@implementation MAbstractMaster

@synthesize context;
@synthesize _isDisplayed;
@synthesize _isCleared;
@synthesize target;

- (void) display {
    [self doDisplay];
    [self doInit];
}

- (void) clear {
    [self doClear];
}

- (void) destroy {
    [self doDestroy];
}

- (void) doInit {
    self._isDisplayed = YES;
    
    // Merge context and request properties.
    [MObjectUtil mergeProps:context.props withObject:target];
    
    // Set state to in and merge properties.
    [[context manager] setTarget: target];
}

- (BOOL) isDisplayed { return _isDisplayed; }

- (BOOL) isCleared { return _isCleared; }

- (void) doDisplay {}

- (void) doClear {}

- (void) doDestroy {}
@end
