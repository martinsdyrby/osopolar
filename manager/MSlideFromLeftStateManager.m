//
//  MSlideFromLeftStateManager.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 29/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MSlideFromLeftStateManager.h"

@implementation MSlideFromLeftStateManager


- (void) doOut {

    UIView* view = [(UIViewController*) self.target view];
    
    view.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = view.frame;
        newFrame.origin.x = -view.frame.size.width;
        view.frame = newFrame;
    } completion:^ (BOOL finished) {
        if (finished) {
            self.state = @"STATE_OFF";
        }
    }];
}

- (void) doPreviousOut {

    UIView* view = [(UIViewController*) self.target view];
    
    view.frame = CGRectMake(-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = view.frame;
        newFrame.origin.x = 0;
        view.frame = newFrame;
    } completion:^ (BOOL finished) {
        if (finished) {
            
        }
    }];
    
}

@end
