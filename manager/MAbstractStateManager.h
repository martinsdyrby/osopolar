//
//  MAbstractStateManager.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 28/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MStateManager.h"

@interface MAbstractStateManager : NSObject<MStateManager>

@property (retain) id _target;
@property (retain) NSString* _state;

- (void) doOn;
- (void) doOff;
- (void) doOut;
- (void) doIn;
- (void) doPreviousOut;

@end
