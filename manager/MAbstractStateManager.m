//
//  MAbstractStateManager.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 28/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MAbstractStateManager.h"
#import "MState.h"
#import "MLogger.h"

@implementation MAbstractStateManager

- (id) target {
    return self._target;
}
- (void) setTarget: (id) target {
    self._target = target;
}
- (NSString *) state {
    return self._state;
}
- (void) setState: (NSString *) state {

    state = [state uppercaseString];
    
    if (![state isEqualToString:@"STATE_IN"] &&
        ![state isEqualToString:@"STATE_ON"] &&
        ![state isEqualToString:@"STATE_OUT"] &&
        ![state isEqualToString:@"STATE_OFF"] &&
        ![state isEqualToString:@"PREV_STATE_OUT"] &&
        ![state isEqualToString:@"PREV_STATE_OFF"]
        ) {
        [MLogger errorWithFormat:@"Invalid state: %@", state];
        return;
    }
    
    if (![state isEqualToString:self._state]) {
        self._state = state;
        [self changeState];
    }
}

- (void) changeState {
    if (self._target == nil) return;
    
    MState* state = [[MState alloc] init];
    state.state = self._state;
    state.target = self._target;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STATE_CHANGE" object:state];
    
    if ([self._state isEqualToString:@"STATE_IN"]) {
        [self doIn];
    } else if ([self._state isEqualToString:@"STATE_ON"]) {
        [self doOn];
    } else if ([self._state isEqualToString:@"STATE_OUT"]) {
        [self doOut];
    } else if ([self._state isEqualToString:@"STATE_OFF"]) {
        [self doOff];
    } else if ([self._state isEqualToString:@"PREV_STATE_OUT"]) {
        [self doPreviousOut];
    }
}


- (void) doOn {}
- (void) doOff {}
- (void) doOut { self.state = @"STATE_OFF"; }
- (void) doIn { self.state = @"STATE_ON"; }
- (void) doPreviousOut {}
@end
