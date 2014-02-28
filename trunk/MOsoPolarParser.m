//
//  MOsoPolarParser.m
//  OsoPolarDev
//
//  Created by Martin Schiøth Dyrby on 11/11/13.
//  Copyright (c) 2013 Molamil. All rights reserved.
//

#import "MOsoPolarParser.h"

@interface MOsoPolarParser(){
    NSMutableDictionary *_entries, *_pages, *_blocks, *_commands, *_props, *_curObj;
    NSObject *_curSubObj;
    NSMutableString *_curContent;
    NSMutableArray *_curSubs;
    NSString *_lastElement;
}

@end

@implementation MOsoPolarParser


NSString *const PAGE = @"page";
NSString *const BLOCK = @"block";
NSString *const COMMAND = @"command";
NSString *const COMMANDS = @"commands";
NSString *const VIEWS = @"views";
NSString *const BLOCKS = @"blocks";
NSString *const PAGES = @"pages";
NSString *const PROP = @"prop";
NSString *const PROPS = @"props";
NSString *const ITEM = @"item";
NSString *const HANDLER = @"handler";
NSString *const NAME = @"name";
NSString *const TYPE = @"type";
NSString *const ACTION = @"action";
NSString *const ID = @"id";
NSString *const EXTENDS = @"extends";
NSString *const DEPENDS = @"depends";
NSString *const MANAGER = @"manager";
NSString *const HANDLERS = @"handlers";
NSString *const TARGET = @"target";
NSString *const CONTAINER = @"container";
NSString *const VALUE = @"value";

@synthesize entries;

- (id) initWithName: (NSString*) name {
    
    NSString *xmlPath;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    xmlPath = [rootPath stringByAppendingPathComponent: [name stringByAppendingFormat:@".xml"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:xmlPath]) {
        xmlPath = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    }
    
    NSData *xmlData = [[NSFileManager defaultManager] contentsAtPath:xmlPath];

    self = [super initWithData:xmlData];
    
    return self;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    _curContent = [[NSMutableString alloc] init];
    _lastElement = elementName;
    if([elementName isEqualToString:COMMAND] || [elementName isEqualToString:PAGE] || [elementName isEqualToString:BLOCK]) {
        // START COMMAND, START PAGE, START BLOCK
        _curObj = [[NSMutableDictionary alloc] initWithDictionary:attributeDict];
        [_curObj setValue:[[NSMutableArray alloc] init] forKey:HANDLERS];
        [_curObj setValue:[[NSMutableDictionary alloc] init] forKey:PROPS];
    } else if([elementName isEqualToString:PROP]) {
        // ADD PROP
        NSMutableDictionary *prop = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
        [_curSubs addObject:prop];
        _curSubObj = prop;
    } else if([elementName isEqualToString:ITEM]) {
        // ADD ITEM
        NSMutableArray *item = [[NSMutableArray alloc] init];
        [_curSubs addObject:item];
        _curSubObj = item;
    } else if([elementName isEqualToString:HANDLER]) {
        // ADD HANDLER
        _curSubObj = [[NSMutableDictionary alloc] initWithDictionary:attributeDict];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if([elementName isEqualToString:COMMAND]) {
        // END COMMAND
        [_commands setValue:_curObj forKey:[_curObj valueForKey:ID]];
    } else if([elementName isEqualToString:PAGE]) {
        // END PAGE
        [_pages setValue:_curObj forKey:[_curObj valueForKey:ID]];
    } else if([elementName isEqualToString:BLOCK]) {
        // START BLOCK
        [_blocks setValue:_curObj forKey:[_curObj valueForKey:ID]];
    } else if([elementName isEqualToString:PROP]) {
        // ADD PROP
        NSMutableDictionary *_curProp = (NSMutableDictionary*)_curSubObj;
        // IF CUR SUB OBJ HAS NO VALUE
        if ([_curProp objectForKey:VALUE] == nil) {
            // THEN SET CUR CONTENT AS VALUE
            [_curProp setObject:_curContent forKey:VALUE];
        }

        // POP PROP FROM SUBS ARRAY
        [_curSubs removeObject:_curProp];
        
        // IF COUNT SUBS ARRAY IS = 0
        if([_curSubs count] == 0) {
            if(_curObj != nil) {
                // THEN ADD TO CUR OBJ
                NSMutableDictionary *props = [_curObj objectForKey:PROPS];
                [props setObject:[_curSubObj valueForKey:VALUE] forKey:[_curSubObj valueForKey:NAME]];
            } else {
                // ELSE ADD TO GLOBAL PROPS
                [_props setObject:[_curSubObj valueForKey:VALUE] forKey:[_curSubObj valueForKey:NAME]];
            }
        } else { // IF COUNT SUBS ARRAY IS > 0
            // GET LAST ELEMENT IN SUBS ARRAY
            NSObject *_lastElementObj = [_curSubs objectAtIndex:[_curSubs count] - 1];
            
            // IF LAST ELEMENT IS PROP
            if ([_lastElementObj isKindOfClass:[NSMutableDictionary class]]) {
                NSMutableDictionary* _lastElementDict = (NSMutableDictionary*)_lastElementObj;
                if ([_lastElementDict objectForKey:VALUE] == nil) {
                    [_lastElementDict setObject:[[NSMutableDictionary alloc] init] forKey:VALUE];
                }
                NSMutableDictionary* _lastElementValue = [_lastElementDict objectForKey:VALUE];
                // THEN ADD TO PROP
                [_lastElementValue setObject:_curProp forKey:[_curProp valueForKey:NAME]];
            } else if ([_lastElementObj isKindOfClass:[NSArray class]]) { // IF LAST ELEMENT IS ITEM
                // THEN ADD TO ARRAY
                [(NSMutableArray*)_lastElementObj addObject:_curProp];
            }
            _curSubObj = _lastElementObj;
        }
    } else if([elementName isEqualToString:ITEM]) {
        // ADD ITEM
        NSMutableArray *_curItem = (NSMutableArray*)_curSubObj;
        // IF ITEM HAS NO VALUE
        if ([_curItem count] == 0) {
            // THEN SET CUR CONTENT AS VALUE
            [_curItem addObject:_curContent];
        }
        
        // POP ITEM FROM SUBS ARRAY
        [_curSubs removeObject:_curItem];
        
        // GET LAST ELEMENT IN SUBS ARRAY
        NSObject *_lastElementObj = [_curSubs objectAtIndex:[_curSubs count] - 1];
        
        // IF LAST ELEMENT IS PROP
        if ([_lastElementObj isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary* _lastElementDict = (NSMutableDictionary*)_lastElementObj;
            if ([_lastElementDict objectForKey:VALUE] == nil) {
                [_lastElementDict setObject:[[NSMutableArray alloc] init] forKey:VALUE];
            }
            NSMutableArray* _lastElementValue = [_lastElementDict objectForKey:VALUE];
            // THEN ADD TO PROP
            for (int i = 0; i < _curItem.count; i++) {
                [_lastElementValue addObject:[_curItem objectAtIndex:i]];
            }
        } else if ([_lastElementObj isKindOfClass:[NSArray class]]) { // IF LAST ELEMENT IS ITEM
            // THEN ADD TO ARRAY
            [(NSMutableArray*)_lastElementObj addObject:[_curItem objectAtIndex:0]];
        }
        _curSubObj = _lastElementObj;
    } else if([elementName isEqualToString:HANDLER]) {
        // ADD HANDLER
        NSMutableArray* handlers = [_curObj valueForKey:HANDLERS];
        [handlers addObject:_curSubObj];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_curContent appendString:string];
}

- (BOOL)parse {

    self.delegate = self;
    
    _curSubs = [[NSMutableArray alloc] init];
    _entries = [[NSMutableDictionary alloc] init];
    _pages = [[NSMutableDictionary alloc] init];
    _blocks = [[NSMutableDictionary alloc] init];
    _commands = [[NSMutableDictionary alloc] init];
    _props = [[NSMutableDictionary alloc] init];

    [_entries setValue:_pages forKey:PAGES];
    [_entries setValue:_blocks forKey:BLOCKS];
    [_entries setValue:_commands forKey:COMMANDS];
    [_entries setValue:_props forKey:PROPS];
    
    BOOL success = [super parse];
    NSLog(@"Entries: %@", _entries);
    [self setEntries:_entries];
    
    return success;
}
@end
