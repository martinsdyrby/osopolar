//
//  MStateManager.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MStateManager <NSObject>
    - (id) target;
    - (void) setTarget: (id) target;
    - (NSString *) state;
    - (void) setState: (NSString *) value;
@end
