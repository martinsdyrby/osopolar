//
//  MObjectFactory.m
//  FaktaPOC
//
//  Created by Martin Schiøth Dyrby on 18/12/12.
//  Copyright (c) 2012 Molamil. All rights reserved.
//

#import "MObjectFactory.h"
#import "MDefinition.h"
#import "MExecute.h"

@interface MObjectFactory ()

@property (retain) NSMutableDictionary* pageContexts;
@property (retain) NSMutableDictionary* blockContexts;
@property (retain) NSMutableDictionary* commandContexts;
@property (retain) NSDictionary* pagesList;
@property (retain) NSDictionary* blocksList;
@property (retain) NSDictionary* commandsList;

@end

@implementation MObjectFactory

@synthesize pageContexts;
@synthesize pagesList;
@synthesize blockContexts;
@synthesize blocksList;
@synthesize commandContexts;
@synthesize commandsList;

- (id) initWithPages: (NSDictionary *) pages andBlocks: (NSDictionary *) blocks andCommands: (NSDictionary *) commands {
    
    self.pagesList = pages;
    self.blocksList = blocks;
    self.commandsList = commands;
    
    self.pageContexts = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.blockContexts = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.commandContexts = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    return self;
}

- (MPageContext *) getPageContextWithId: (NSString *) pageId {
    
    MPageContext* context = [pageContexts objectForKey:pageId];
    if(context == nil) {
        
        context = [[MPageContext alloc] init];
        
        NSDictionary* page = [pagesList objectForKey:pageId];
        if(page == nil) {
            return nil;
        }
        
        if([page objectForKey:@"extends"] != nil) {
            NSDictionary* parentPage = [pagesList objectForKey:[page objectForKey:@"extends"]];
            
            [self setViewContextProperties: parentPage onContext: context];
            context.manager = [self setContextValue:
                               [self resolveManager:
                                [parentPage objectForKey:@"manager"]
                                    withDefault:nil]
                                        withDefault: context.manager];
            context.master = [self setContextValue: [self resolveMaster: [parentPage objectForKey:@"type"]] withDefault: context.master];
        }
        
        context.id = pageId;
        [self setViewContextProperties: page onContext: context];
        context.manager = [self setContextValue:
                           [self resolveManager:
                            [page objectForKey:@"manager"]
                                    withDefault:context.manager]
                                    withDefault: context.manager];
        context.master = [self setContextValue: [self resolveMaster: [page objectForKey:@"type"]] withDefault: context.master];
        context.master.context = context;
        
        [pageContexts setObject:context forKey:pageId];
    }
    
    return context;
}


- (MBlockContext *) getBlockContextWithId: (NSString *) blockId {
    
    MBlockContext* context = [blockContexts objectForKey:blockId];
    if(context == nil) {
        
        context = [[MBlockContext alloc] init];
        
        NSDictionary* block = [blocksList objectForKey:blockId];
        if(block == nil) {
            return nil;
        }
        NSString* defaultManager = nil;
        if([block objectForKey:@"extends"] != nil) {
            NSDictionary* parentBlock = [blocksList objectForKey:[block objectForKey:@"extends"]];
            defaultManager = [parentBlock objectForKey:@"manager"];
            [self setViewContextProperties: parentBlock onContext: context];
            context.manager = [self setContextValue:
                               [self resolveManager:
                                    defaultManager
                                        withDefault:nil]
                                        withDefault: nil];
            context.master = [self setContextValue: [self resolveMaster: [parentBlock objectForKey:@"type"]] withDefault: context.master];
        }
        
        context.id = blockId;
        [self setViewContextProperties:block onContext:context];

        context.manager = [self setContextValue:
                           [self resolveManager:
                            [block objectForKey:@"manager"]
                                    withDefault:context.manager]
                                    withDefault: nil];
        context.master = [self setContextValue: [self resolveMaster: [block objectForKey:@"type"]] withDefault: context.master];
        context.master.context = context;
                
        [blockContexts setObject:context forKey:blockId];
    }
    
    return context;
}

- (MCommandContext *) getCommandContextWithId: (NSString *) commandId {
    
    MCommandContext* context = [commandContexts objectForKey:commandId];
    if(context == nil) {
        context = [[MCommandContext alloc] init];
        
        NSDictionary* command = [commandsList objectForKey:commandId];
        if(command == nil) {
            return nil;
        }
        context.id = commandId;
        context.type = [command objectForKey:@"type"];
        context.props = [command objectForKey:@"props"];
        context.master = [self resolveCommandMaster: [command objectForKey:@"master"]];
        context.master.context = context;

        [commandContexts setObject:context forKey:commandId];
    }
    
    return context;
}

- (id<MStateManager>) resolveManager: (NSString *) managerName withDefault: (id) defaultManager {
    if(managerName == nil) {
        if(defaultManager == nil) {
            managerName = @"MSimpleStateManager";
        } else {
            return defaultManager;
        }
    }
    
    if([managerName isEqualToString:@"rightslide"]) {
        managerName = @"MSlideFromRightStateManager";
    } else if([managerName isEqualToString:@"leftslide"]) {
        managerName = @"MSlideFromLeftStateManager";
    }

    return [[NSClassFromString(managerName) alloc] init];
}

- (id<MViewMaster>) resolveMaster: (NSString *) masterName {
    if([masterName isEqualToString:@"Definition"]) {
        masterName = @"MDefinition";
    } else if([masterName isEqualToString:@"Nib"]) {
        masterName = @"MNibMaster";
    }
    return [[NSClassFromString(masterName) alloc] init];
}

- (id<MCommandMaster>) resolveCommandMaster: (NSString *) masterName {
    if(masterName == nil) {
        masterName = @"MExecute";
    }
    return [[NSClassFromString(masterName) alloc] init];
}


- (id) setContextValue: (id) value withDefault: (id) defaultValue {
    if (value == nil) return defaultValue;
    return value;
}

- (void) setViewContextProperties: (NSDictionary *) props onContext: (id<MViewableContext,MContext>) context {
    context.type = [self setContextValue: [props objectForKey:@"target"] withDefault: context.type];
    context.xib = [self setContextValue: [props objectForKey:@"xib"] withDefault: context.xib];
    context.depends = [self setContextValue: [props objectForKey:@"depends"] withDefault: context.depends];
    context.props = [self setContextValue: [props objectForKey:@"props"] withDefault: context.props];
    context.containerName = [self setContextValue: [props objectForKey:@"container"] withDefault: context.containerName];
}
@end
