//
//  BatchURLLoader.m
//  tonyplaces
//
//  Created by Senja iMac on 6/21/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "BatchURLLoader.h"
#import "URLLoader.h"

@implementation BatchURLLoader

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self){
        urls = [[NSMutableArray alloc] init];
        loaderData = [[NSMutableArray alloc] init];
        loadedCount = 0;
    }
    return self;
}

- (void)dealloc
{
    [loaderData release];
    [urls release];
    [super dealloc];
}

- (void)addURLString:(NSString*)string
{
    [urls addObject:string];
}

- (void)load
{
    for (NSString* url in urls){
        URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
        [loader addTarget:self onLoad:@selector(loaderLoaded:)];
        [loader load];
    }
}

- (void)loaderLoaded:(URLLoader*)loader
{
    loadedCount++;
    [loaderData addObject:[loader data]];
    [loader release];
    if (loadedCount == urls.count){
        if ([delegate respondsToSelector:@selector(batchURLLoader:loaded:)]){
            [delegate performSelector:@selector(batchURLLoader:loaded:) withObject:self withObject:loaderData];
        }
    }
}

@end
