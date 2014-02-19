//
//  MOsoPolarParser.h
//  OsoPolarDev
//
//  Created by Martin Schiøth Dyrby on 11/11/13.
//  Copyright (c) 2013 Molamil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOsoPolarParser : NSXMLParser <NSXMLParserDelegate>

@property (retain) NSDictionary* entries;

- (id) initWithName: (NSString*) name;

@end
