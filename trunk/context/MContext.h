//
//  MContext.h
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 19/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MContext <NSObject>

@property (retain) NSString* id;
@property (retain) NSString* type;
@property (retain) NSDictionary* props;

@end
