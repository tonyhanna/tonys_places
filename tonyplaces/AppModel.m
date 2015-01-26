//
//  AppModel.m
//  tonyplaces
//
//  Created by Senja iMac on 6/1/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "AppModel.h"


@implementation AppModel

@synthesize role, ownLocation, ownHeading, config, searchTags, autoLogin, delegate;

static AppModel * _instance;
static NSArray * PREDEFINED_TAGS;
+ (void)initialize { 
    PREDEFINED_TAGS = [[@"food,restaurant,cafe,vegan,vegetarian,raw food" componentsSeparatedByString:@","] retain];
    _instance = [[AppModel alloc] init]; 
}
+ (AppModel*)instance { return _instance; }


- (void)registerDefaultsFromSettingsBundle {
    NSLog(@"register defaults");
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}

- (id)init
{
    self = [super init];
    if (self != nil){
        // Path to the plist (in the application bundle)
        NSString *path = [[NSBundle mainBundle] pathForResource: @"config" ofType:@"plist"];
        config = [[NSDictionary alloc] initWithContentsOfFile:path];
        searchTags = nil;
        
        //test if defaults registered
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"custom_tags"] == nil){
            [self registerDefaultsFromSettingsBundle];
        }
        [self loadPreferences];
    }
    return self;
}

- (void)dealloc
{
    [searchTags release];
    [super dealloc];
}

- (void)loadPreferences
{
    bool searchTagsChanged = false;
    // read user preferences
    NSMutableArray * tSearchTags = [[NSMutableArray alloc] init];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    for (NSString * predefinedTag in PREDEFINED_TAGS){
        if ([userDefaults boolForKey:[NSString stringWithFormat:@"tag_%@", predefinedTag]]){
            [tSearchTags addObject:predefinedTag];
        }
    }
    NSString * customTags = [[userDefaults stringForKey:@"custom_tags"] lowercaseString];
    if (![customTags isEqualToString:@""]){
        [tSearchTags addObjectsFromArray:[customTags componentsSeparatedByString:@","]];
    }
    searchTagsChanged = ![[searchTags componentsJoinedByString:@" "] isEqualToString:[tSearchTags componentsJoinedByString:@" "]];
    [searchTags release];
    searchTags = tSearchTags;
    NSLog(@"search: %@", searchTags);
    
    if ([delegate respondsToSelector:@selector(appModelSearchTagsChanged)]){
        [delegate performSelector:@selector(appModelSearchTagsChanged)];
    }
}

- (CLLocationDirection)getAvailableHeading
{
    if (ownHeading == nil) return 0.0;
    else return (ownHeading.trueHeading)?ownHeading.trueHeading:ownHeading.magneticHeading;
}

@end
