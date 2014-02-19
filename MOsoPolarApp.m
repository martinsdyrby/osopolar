//
//  MOsoPolarApp.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MOsoPolarApp.h"
#import "MPageContext.h"
#import "MObjectFactory.h"
#import "MContainerViewController.h"
#import "MViewableContext.h"
#import "MObjectUtil.h"
#import "MState.h"
#import "MLogger.h"
#import "MOsoPolarParser.h"

@interface MOsoPolarApp ()

@property (retain) NSDictionary* plist;
@property (retain) NSDictionary* pages;
@property (retain) NSDictionary* blocks;
@property (retain) NSDictionary* commands;
@property (retain) NSMutableDictionary* handlers;
@property (retain) MObjectFactory* factory;
@property (retain) MPageContext* currentPageContext;
@property (retain) MPageContext* nextPageContext;
@property (retain) NSMutableDictionary* containers;
@property (retain) id currentPage;
@property (retain) id nextPage;
@property (retain) NSMutableArray* curBlockIds;

- (void) callId: (NSString *) callId andData: (NSDictionary *)data;

@end

@implementation MOsoPolarApp

@synthesize pages;
@synthesize blocks;
@synthesize commands;
@synthesize handlers;
@synthesize plist;
@synthesize factory;
@synthesize currentPageContext;
@synthesize nextPageContext;
@synthesize containers;
@synthesize delegate;
@synthesize props;
@synthesize curBlockIds;

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    containers = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    curBlockIds = [NSMutableArray array];
    
    return self;
}


- (id) initWithXmlName: (NSString *)name andNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    // LOAD CONFIGURATION
    MOsoPolarParser* parser = [[MOsoPolarParser alloc] initWithName:name];
    if([parser parse]) {
        self.pages = [parser.entries valueForKey:@"pages"];
        self.blocks = [parser.entries valueForKey:@"blocks"];
        self.commands = [parser.entries valueForKey:@"commands"];
    }

    [self postInit];
    
    return self;
}

- (id) initWithPlistName: (NSString *)name andNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    // LOAD CONFIGURATION
    [self loadPlistWithName:name];
    
    [self postInit];
    
    return self;
}

- (void) postInit {
    // EXTRACT EVENTS FROM PAGES
    [self extractHandlers];
    
    factory = [[MObjectFactory alloc] initWithPages: self.pages andBlocks: self.blocks andCommands: self.commands];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector: @selector(stateChange:)
     name:@"STATE_CHANGE"
     object: nil];

}

- (void) callId: (NSString *) callId andData: (NSDictionary *)data {

    [MLogger debugWithFormat:@"callID: %@", callId];

    MPageContext* vcontext = [factory getPageContextWithId:callId];
    
    if(vcontext != nil) {
        [self gotoPageWithId:callId andData:data];
        return;
    }
    
    MBlockContext* bcontext = [factory getBlockContextWithId:callId];
    
    if(bcontext != nil) {
        [self displayBlockWithId:callId andData:data];
        return;
    }
    
    MCommandContext* ccontext = [factory getCommandContextWithId:callId];
    
    if(ccontext != nil) {
        [self executeCommandWithId:callId andData:data];
        return;
    }
}

- (void) clearId: (NSString*) pageName {
    [MLogger debugWithFormat:@"clearId: %@", pageName];
    MPageContext* vcontext = [factory getPageContextWithId:pageName];
    
    if(vcontext != nil) {
        [self clearPageWithId:pageName];
        return;
    }
    
    MBlockContext* bcontext = [factory getBlockContextWithId:pageName];
    
    if(bcontext != nil) {
        [self clearBlockWithId:pageName];
        return;
    }
}

- (MPageContext *) gotoPageWithId: (NSString *) pageId andData: (NSDictionary *)data {
 
    // Look up the page context.
    MPageContext* context = [factory getPageContextWithId:pageId];
    
    if(context == nil) {
        [MLogger errorWithFormat:@"Page context for %@ is not found", pageId];
        return nil;
    }
        
    // Check whether we are already in that page.
    if(currentPageContext == context) {
        [MObjectUtil mergeProps:data withObject:[[currentPageContext master] target]];
        return context;
    }

    // And wether that page is already being requested.
    if(nextPageContext == context) {
        [MObjectUtil mergeProps:data withObject:[[nextPageContext master] target]];
        return context;
    }
    
    context.container = [self resolveContainerForContext: context];
    
    // display page
    [context.master display];
    [MObjectUtil mergeProps:data withObject:[context.master target]];
    
    // remove previous page
    if(currentPageContext != nil) {
        nextPageContext = context;
        [[context manager] setState: @"PREV_STATE_OUT"];
        [currentPageContext.manager setState:@"STATE_OUT"];
        // clear depends
        NSString* dependID;
        for(int i = 0; i < currentPageContext.depends.count; i++) {
            dependID = [currentPageContext.depends objectAtIndex:i];
            if(![nextPageContext.depends containsObject:dependID]) {
                [self clearBlockWithId:dependID];
            }
        }
    
        

    } else {
        [[context manager] setState: @"STATE_IN"];
        currentPageContext = context;
        // execute setup
        if([[[context master] target] respondsToSelector:@selector(setup)]) {
            [[[context master] target] performSelector:@selector(setup)];
        }
    }

    // display depends
    for(int i = 0; i < context.depends.count; i++) {
        [MLogger debugWithFormat:@"Depends %@", [context.depends objectAtIndex:i]];
        [self displayBlockWithId:[context.depends objectAtIndex:i] andData:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageRequest" object:context];
    [delegate performSelector:@selector(pageRequestedWithContext:) withObject:context];

    return context;
}

- (MBlockContext *) displayBlockWithId: (NSString *) blockId andData: (NSDictionary *)data {
    
    [MLogger debugWithFormat:@"displayBlockWithId: %@", blockId];
    
    // Look up the page context.
    
    MBlockContext* context = [factory getBlockContextWithId:blockId];
    

    if(context == nil) {
        [MLogger errorWithFormat:@"Block context for %@ is not found", blockId];
        return nil;
    }

    int index = [curBlockIds indexOfObject:blockId];
    
    if(index != NSNotFound) {
        [MObjectUtil mergeProps:data withObject:[context.master target]];
        return nil;
    }
    
    [curBlockIds addObject:blockId];
    
    context.container = [self resolveContainerForContext: context];
    
    // display page
    [context.master display];
    [MObjectUtil mergeProps:data withObject:[context.master target]];

    // execute setup
    if([[[context master] target] respondsToSelector:@selector(setup)]) {
        [[[context master] target] performSelector:@selector(setup)];
    }
    
    // set STATE_IN
    [[context manager] setState: @"STATE_IN"];
    
    return context;
}

- (void) clearBlockWithId: (NSString *) blockId {
    

    MBlockContext* context = [factory getBlockContextWithId:blockId];
    int index = [curBlockIds indexOfObject:blockId];
    if(index != NSNotFound) {
        [[context manager] setState: @"STATE_OUT"];
    } else {
        [MLogger debugWithFormat:@"Block with id %@ not found for clearing.", blockId];
    }
}

- (void) clearPageWithId: (NSString *) pageId {
    MPageContext* context = [factory getPageContextWithId:pageId];
    [context.master clear];
}

- (MCommandContext *) executeCommandWithId:(NSString *)commandId andData:(NSDictionary *)data {

    MCommandContext* context = [factory getCommandContextWithId:commandId];
    
    if(context == nil) {
        [MLogger errorWithFormat:@"Command context for %@ is not found", commandId];
        return nil;
    }
    
    id command = [context.master build];
    
    [MObjectUtil mergeProps:data withObject:command];
    
    [context.master execute];
    
    return context;
}


- (UIView*) addContainer: (UIView*) view withName: (NSString *) name {
    [containers setObject:view forKey:name];
    return view;
}


















- (void) stateChange: (NSNotification *)note {
    

    MState* state = note.object;
    if([currentPageContext.manager target] == state.target) {
        if([state.state isEqualToString:@"STATE_OFF"]) {
            if([[[currentPageContext master] target] respondsToSelector:@selector(destroy)]) {
                [[[currentPageContext master] target] performSelector:@selector(destroy)];
            }
            [currentPageContext.master clear];
            currentPageContext = nextPageContext;
            [currentPageContext.manager setState:@"STATE_IN"];
            // execute setup
            MPageContext* ctx = currentPageContext;
            id<MViewMaster> mster = [ctx master];
            
            if([[mster target] respondsToSelector:@selector(setup)]) {
                [[mster target] performSelector:@selector(setup)];
            }
        }
    } else if([state.state isEqualToString:@"STATE_OFF"]) {
        for(int i = 0; i < curBlockIds.count; i++) {
            NSString* blockId = [curBlockIds objectAtIndex:i];
            MBlockContext* context = [factory getBlockContextWithId:blockId];
            
            if([context.manager target] == state.target) {
                [curBlockIds removeObjectAtIndex:i];
				//Patriks contribution to the framework!
                if([[context.manager target] respondsToSelector:@selector(destroy)]) {
                    [[context.manager target] performSelector:@selector(destroy)];
                }
                [context.master clear];
                break;
            }
        }
    }
    
    [self hideUnusedContainers];    
}


- (void) eventReceived: (NSNotification *)note {
    NSString* type = note.name;
    NSDictionary* data = note.object;
    
    // resolve view based on action
    NSArray* registeredHandlers = [handlers objectForKey:type];

    
    [MLogger infoWithFormat:@"OsoPolar event received (%@) (Handlers: %i)", type, registeredHandlers.count];
    for( int i = 0; i < registeredHandlers.count; i++) {
        NSDictionary* eventData = [registeredHandlers objectAtIndex:i];
        NSString* key = [eventData valueForKey:@"pageName"];
        NSString* action = [eventData valueForKey:@"pageAction"];
        
        if([action isEqualToString:@"display"]) {
            [self callId: key andData: data];
        } else {
            [self clearId: key];
        }
    }
}

- (void) loadPlistWithName: (NSString*) name {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent: [name stringByAppendingFormat:@".plist"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    plist = (NSDictionary *)[NSPropertyListSerialization
                             propertyListFromData:plistXML
                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
                             format:&format
                             errorDescription:&errorDesc];
    if (!plist) {
        [MLogger errorWithFormat:@"Error reading plist: %@, format: %d", errorDesc, format];
    }
    pages = [plist objectForKey:@"pages"];
    blocks = [plist objectForKey:@"blocks"];
    commands = [plist objectForKey:@"commands"];
    props = [plist objectForKey:@"props"];
}

- (void) loadXMLWithName: (NSString*) name {
    
}

- (void) extractHandlers{
    handlers = [[NSMutableDictionary alloc] init];
    
    NSArray* parts = [[NSArray alloc] initWithObjects:pages, blocks, commands, nil];
    
    NSEnumerator *pEnum = [parts objectEnumerator];
    
    NSDictionary* part;
    while ((part = [pEnum nextObject])) {
        NSEnumerator *enumerator = [part keyEnumerator];
        id pageName;
        while ((pageName = [enumerator nextObject])) {
            
            NSDictionary *page = [part objectForKey:pageName];
            NSArray *tmpevents = [page objectForKey:@"handlers"];
            
            NSEnumerator *e = [tmpevents objectEnumerator];
            NSObject* eventType;
            NSString* eventTypeName;
            NSString* eventTypeAction;
            while (eventType = [e nextObject]) {
                if ([eventType isKindOfClass:[NSString class]]) {
                    eventTypeName = (NSString*) eventType;
                    eventTypeAction = @"display";
                } else {
                    eventTypeName = [eventType valueForKey:@"type"];
                    eventTypeAction = [eventType valueForKey:@"action"];
                    eventTypeAction = eventTypeAction != nil ? eventTypeAction : @"display";
                }
                NSMutableArray* pageevents = [handlers objectForKey:eventTypeName];
                if(pageevents == nil) {
                    pageevents = [[NSMutableArray alloc] init];
                    [handlers setObject:pageevents forKey:eventTypeName];
                    [[NSNotificationCenter defaultCenter]
                     addObserver:self
                     selector: @selector(eventReceived:)
                     name:eventTypeName
                     object: nil];

                }
                [pageevents addObject: [NSDictionary dictionaryWithObjectsAndKeys:pageName, @"pageName", eventTypeAction, @"pageAction", nil]];
            }
        }
    }
}

- (void) hideUnusedContainers {
    NSEnumerator *enumerator = [containers keyEnumerator];
    NSString* viewname;
    UIView* tmpcontainer;
    while ((viewname = [enumerator nextObject])) {
        tmpcontainer = [containers objectForKey:viewname];

        if(tmpcontainer.subviews.count == 0) {
            [tmpcontainer setHidden:YES];
        } else {
            [tmpcontainer setHidden:NO];
        }
    }
}

- (UIView*) resolveContainerForContext: (id<MViewableContext>) context {
    UIView* container;
    if(context.containerName != nil) {
        container = [containers objectForKey:context.containerName];
    } else {
        container = self.view;
    }
    
    [self hideUnusedContainers];
    
    return container;
}
@end
