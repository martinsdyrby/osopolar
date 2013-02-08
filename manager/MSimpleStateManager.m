//
//  MSimpleStateManager.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 28/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MSimpleStateManager.h"

@implementation MSimpleStateManager

- (void) doOut {
    self.state = @"STATE_OFF";
}
- (void) doIn {
    self.state = @"STATE_ON";
}

@end
