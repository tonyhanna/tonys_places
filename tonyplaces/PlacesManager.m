//
//  PlacesManager.m
//  tonyplaces
//
//  Created by Senja iMac on 5/31/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "PlacesManager.h"
#import "URLLoader.h"
#import "CJSONDeserializer.h"
#import "PlaceModel.h"

@implementation PlacesManager

@synthesize delegate, foursquareId, foursquareName;

#define FS_CLIENT_ID @"SA4GVOMIJ2J2WP0SZA3OP2RCT3CZ4ASCEIFKC10OKZ0V1E3C"
#define FS_CLIENT_SECRET @"WYI1N2GMEMTY4VCQ0CD2QWTTK0KITOCO4LGE3OHGP4DAOUYD"

static PlacesManager * _instance;

+ (void)initialize { _instance = [[PlacesManager alloc] init]; }
+ (PlacesManager*)instance { return _instance; }

- (id)init
{
    self = [super init];
    if (self != nil){
        [[Foursquare sharedInstance] setConsumerKey:FS_CLIENT_ID];
        [[Foursquare sharedInstance] setConsumerSecret:FS_CLIENT_SECRET];
        [Foursquare sharedInstance].delegate = self;
    }
    return self;
}

- (void)checkDeviceAccess
{
    NSString * deviceID = [[UIDevice currentDevice] uniqueIdentifier];
    NSString * url = [NSString stringWithFormat:@"http://apps.teedot.com/places/api.php?mode=checkDeviceAccess&deviceId=%@", deviceID];
    URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
    [loader addTarget:self onLoad:@selector(checkDeviceAccessLoaded:)];
    [loader load];
}

- (void)checkDeviceAccessLoaded:(URLLoader *)loader
{
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    NSString * access = [object valueForKey:@"access"];
    if ([access isEqualToString:@"admin"]){
        if ([delegate respondsToSelector:@selector(placesManagerCheckDeviceAccess:)]){
            [delegate performSelector:@selector(placesManagerCheckDeviceAccess:) withObject:[NSNumber numberWithInt:ROLE_ADMIN]];
        }
    } else if ([access isEqualToString:@"public"]){
        if ([delegate respondsToSelector:@selector(placesManagerCheckDeviceAccess:)]){
            [delegate performSelector:@selector(placesManagerCheckDeviceAccess:) withObject:[NSNumber numberWithInt:ROLE_PUBLIC]];
        }
    } 
    [loader release];
}

- (BOOL)isLoggedInFoursquare
{
    return [[Foursquare sharedInstance] isActive];
}

- (void)loginFoursquareFinish:(int)status
{
    if ([delegate respondsToSelector:@selector(placesManagerLoginFoursquare:)]){
        [delegate performSelector:@selector(placesManagerLoginFoursquare:) withObject:[NSNumber numberWithInt:status]];
    }
}

- (void)loginFoursquare:(NSString*)username password:(NSString*)password;
{
    [[Foursquare sharedInstance] loginWithUsername:username password:password];
}

#pragma mark - Foursquare delegate

- (void)foursquareLoginWithUsernamePasswordLoaded:(NSNumber *)success
{
    bool login = [success boolValue];
    if (login){
        //retrieve foursquare id
        [self loginFoursquareFinish:LOGIN_OK];
    } else {
        [self loginFoursquareFinish:LOGIN_WRONG];
    }
}

#pragma mark -

- (void)checkAccessFinish:(int)status
{
    if ([delegate respondsToSelector:@selector(placesManagerCheckAccess:)]){
        [delegate performSelector:@selector(placesManagerCheckAccess:) withObject:[NSNumber numberWithInt:status]];
    }
}


- (void)loadSelf
{
    NSString * url = [NSString stringWithFormat: @"https://api.foursquare.com/v2/users/self?oauth_token=%@", [Foursquare sharedInstance].oauthToken.secret];
    URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
    [loader addTarget:self onLoad:@selector(loadSelfLoaded:)];
    [loader load];
}

- (void)loadSelfLoaded:(URLLoader*)loader
{
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    [loader release];
    NSDictionary * user = [[object valueForKey:@"response"] valueForKey:@"user"];
    if (user == nil){
        [self checkAccessFinish:LOGIN_EXPIRED];
    } else {
        foursquareId = [[user valueForKey:@"id"] retain];
        foursquareName = [[NSString stringWithFormat:@"%@ %@", [user valueForKey:@"firstName"], [user valueForKey:@"lastName"]] retain];
        NSLog(@"welcome %@", foursquareName);
        
        // check access
        NSString * url = [NSString stringWithFormat:@"http://apps.teedot.com/places/api.php?mode=checkAccess&fsId=%@&name=%@", foursquareId, foursquareName];
        URLLoader * loader2 = [[URLLoader alloc] initWithURLString:url];
        [loader2 addTarget:self onLoad:@selector(checkAccessLoaded:)];
        [loader2 load];
    }
}

- (void)checkAccess
{
    [self loadSelf];
}

- (void)checkAccessLoaded:(URLLoader*)loader
{
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    NSString * access = [object valueForKey:@"access"];
    NSLog(@"access %@", access);
    if ([access isEqualToString:@"pending"]){
        [self checkAccessFinish:REQUEST_PENDING];
    } else if ([access isEqualToString:@"allow"]){
        [self checkAccessFinish:REQUEST_ACCEPTED];
    } else if ([access isEqualToString:@"deny"]){
        [self checkAccessFinish:REQUEST_REJECTED];
    }
    [loader release];
}

- (void)loadNavigate:(CLLocation*)ownLocation
{
    NSString * url = [NSString stringWithFormat:@"http://apps.teedot.com/places/api.php?mode=searchPoints&latitude=%g&longitude=%g",
                      ownLocation.coordinate.latitude, ownLocation.coordinate.longitude];
    URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
    [loader addTarget:self onLoad:@selector(loadNavigateLoaded:)];
    [loader load];
}

- (void)loadNavigateLoaded:(URLLoader*)loader
{
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    [loader release];
    //NSLog(@"loadNavigateLoaded %@", object);
    
    NSMutableArray * places = [[NSMutableArray alloc] init];
    NSArray * points = [object valueForKey:@"points"];
    for (NSDictionary * point in points){
        PlaceModel * place = [[PlaceModel alloc] init];
        place.venueId = [point valueForKey:@"id"];
        place.name = [point valueForKey:@"name"];
        [place setCategoriesWithString:[point valueForKey:@"category"]];
        place.address = [point valueForKey:@"address"];
        place.latitude = [[point valueForKey:@"latitude"] floatValue];
        place.longitude = [[point valueForKey:@"longitude"] floatValue];
        place.distance = [[point valueForKey:@"distance"] floatValue];
        
        [places addObject:place];
        [place release];
    }
    
    if ([delegate respondsToSelector:@selector(placesManagerLoadNavigate:)]){
        [delegate performSelector:@selector(placesManagerLoadNavigate:) withObject:places];
    }
    [places release];
}

- (void)loadVenues:(CLLocation*)ownLocation withSearchTags:(NSArray*)searchTags
{
    /* 
    NSString * query = [searchTags componentsJoinedByString:@" "];
    NSString * url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&query=%@&oauth_token=%@",
                        ownLocation.coordinate.latitude, ownLocation.coordinate.longitude, query, [Foursquare sharedInstance].oauthToken.secret];
    URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
    [loader addTarget:self onLoad:@selector(loadVenuesLoaded:)];
    [loader load];*/
    
    if (searchTags.count > 0){
        BatchURLLoader * batchLoader = [[BatchURLLoader alloc] init];
        batchLoader.delegate = self;
        for (NSString * tag in searchTags){
            NSString * url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&query=%@&oauth_token=%@",
                              ownLocation.coordinate.latitude, ownLocation.coordinate.longitude, tag, [Foursquare sharedInstance].oauthToken.secret];
            [batchLoader addURLString:url];
        }
        [batchLoader load];
    } else {
        BatchURLLoader * batchLoader = [[BatchURLLoader alloc] init];
        batchLoader.delegate = self;
        NSString * url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%g,%g&query=%@&oauth_token=%@",
                          ownLocation.coordinate.latitude, ownLocation.coordinate.longitude, @"", [Foursquare sharedInstance].oauthToken.secret];
        [batchLoader addURLString:url];
        [batchLoader load];
    }
}

- (void)batchURLLoader:(BatchURLLoader *)batchLoader loaded:(NSArray *)loaderData
{
    NSMutableArray * places = [[NSMutableArray alloc] init];
    NSMutableDictionary * placesId = [[NSMutableDictionary alloc] init];
    for (NSData * data in loaderData){
        NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:data error:nil];
        NSArray * groups = [[object valueForKey:@"response"] valueForKey:@"groups"];
        for (NSDictionary * group in groups){
            NSArray * items = [group valueForKey:@"items"];
            for (NSDictionary * item in items){
                //skip redundant place
                if ([placesId valueForKey:[item valueForKey:@"id"]] != nil) continue;
                else [placesId setValue:[NSNumber numberWithBool:true] forKey:[item valueForKey:@"id"]];
                
                PlaceModel * place = [[PlaceModel alloc] init];
                place.venueId = [item valueForKey:@"id"];
                place.name = [item valueForKey:@"name"];
                place.verified = [[item valueForKey:@"verified"] boolValue];
                place.phone = [[item valueForKey:@"contact"] valueForKey:@"phone"];
                place.twitter = [[item valueForKey:@"twitter"] valueForKey:@"twitter"];
                place.latitude = [[[item valueForKey:@"location"] valueForKey:@"lat"] floatValue];
                place.longitude = [[[item valueForKey:@"location"] valueForKey:@"lng"] floatValue];
                place.address = [[item valueForKey:@"location"] valueForKey:@"address"];
                //capitalize first letter of address
                if ([place.address length] > 0){
                    place.address = [place.address stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[place.address substringToIndex:1] uppercaseString]];
                }
                place.crossStreet = [[item valueForKey:@"location"] valueForKey:@"crossStreet"];
                place.city = [[item valueForKey:@"location"] valueForKey:@"city"];
                place.state = [[item valueForKey:@"location"] valueForKey:@"state"];
                place.postalCode = [[item valueForKey:@"location"] valueForKey:@"postalCode"];
                place.country = [[item valueForKey:@"location"] valueForKey:@"country"];
                
                place.distance = [[[item valueForKey:@"location"] valueForKey:@"distance"] floatValue];
                
                NSArray * categories = [item valueForKey:@"categories"];
                if (categories != nil){
                    NSMutableArray * tCategories = [[NSMutableArray alloc] initWithCapacity:categories.count];
                    for (NSDictionary * citem in [item valueForKey:@"categories"]){
                        [tCategories addObject:[citem valueForKey:@"name"]];
                    }
                    place.categories = tCategories;
                    [tCategories release];
                }
                
                [places addObject:place];
                [place release];
            }
        }
        
        
    }
    [placesId release];
    [places sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
    //filter nearest 50
    if (places.count > 50){
        [places removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(50, places.count-50)]];
    }
    
    if ([delegate respondsToSelector:@selector(placesManagerLoadVenues:)]){
        [delegate performSelector:@selector(placesManagerLoadVenues:) withObject:places];
    }
    [places release];
    [batchLoader release];
}

- (void)loadVenuesLoaded:(URLLoader*)loader
{
    //NSLog(@"venues loaded");
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    [loader release];
    
    NSMutableArray * places = [[NSMutableArray alloc] init];
    NSArray * groups = [[object valueForKey:@"response"] valueForKey:@"groups"];
    for (NSDictionary * group in groups){
        NSArray * items = [group valueForKey:@"items"];
        for (NSDictionary * item in items){
            PlaceModel * place = [[PlaceModel alloc] init];
            place.venueId = [item valueForKey:@"id"];
            place.name = [item valueForKey:@"name"];
            place.verified = [[item valueForKey:@"verified"] boolValue];
            place.phone = [[item valueForKey:@"contact"] valueForKey:@"phone"];
            place.twitter = [[item valueForKey:@"twitter"] valueForKey:@"twitter"];
            place.latitude = [[[item valueForKey:@"location"] valueForKey:@"lat"] floatValue];
            place.longitude = [[[item valueForKey:@"location"] valueForKey:@"lng"] floatValue];
            place.address = [[item valueForKey:@"location"] valueForKey:@"address"];
            //capitalize first letter of address
            if ([place.address length] > 0){
                place.address = [place.address stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[place.address substringToIndex:1] uppercaseString]];
            }
            place.crossStreet = [[item valueForKey:@"location"] valueForKey:@"crossStreet"];
            place.city = [[item valueForKey:@"location"] valueForKey:@"city"];
            place.state = [[item valueForKey:@"location"] valueForKey:@"state"];
            place.postalCode = [[item valueForKey:@"location"] valueForKey:@"postalCode"];
            place.country = [[item valueForKey:@"location"] valueForKey:@"country"];
            
            place.distance = [[[item valueForKey:@"location"] valueForKey:@"distance"] floatValue];
            
            NSArray * categories = [item valueForKey:@"categories"];
            if (categories != nil){
                NSMutableArray * tCategories = [[NSMutableArray alloc] initWithCapacity:categories.count];
                for (NSDictionary * citem in [item valueForKey:@"categories"]){
                    [tCategories addObject:[citem valueForKey:@"name"]];
                }
                place.categories = tCategories;
                [tCategories release];
            }
            
            [places addObject:place];
            [place release];
        }
    }
    [places sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
    
    if ([delegate respondsToSelector:@selector(placesManagerLoadVenues:)]){
        [delegate performSelector:@selector(placesManagerLoadVenues:) withObject:places];
    }
    [places release];
}

- (void)addVenue:(PlaceModel *)place
{
    NSString * url = [NSString stringWithFormat:@"http://apps.teedot.com/places/api.php?mode=addPoint&userId=%@&%@",
                      foursquareId, [place makeAddQuery]];
    NSLog(@"%@", url);
    URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
    [loader addTarget:self onLoad:@selector(addVenueLoaded:)];
    [loader load];
}

- (void)addVenueLoaded:(URLLoader*)loader
{
    NSLog(@"addvenueloaded %@", [loader dataAsString]);
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    [loader release];
    PlaceModel * place = nil;
    if ([object valueForKey:@"point"] != nil){
        NSDictionary * point = [object valueForKey:@"point"];
        place = [[PlaceModel alloc] init];
        place.venueId = [point valueForKey:@"id"];
        place.name = [point valueForKey:@"name"];
        [place setCategoriesWithString:[point valueForKey:@"category"]];
        place.address = [point valueForKey:@"address"];
        place.latitude = [[point valueForKey:@"latitude"] floatValue];
        place.longitude = [[point valueForKey:@"longitude"] floatValue];
        place.distance = [[point valueForKey:@"distance"] floatValue];
    }
    //NSString * status = [object valueForKey:@"status"];
    if ([delegate respondsToSelector:@selector(placesManagerAddVenue:)]){
        //[delegate performSelector:@selector(placesManagerAddVenue:) withObject:[NSNumber numberWithBool: [status isEqualToString:@"success"]]];
        [delegate performSelector:@selector(placesManagerAddVenue:) withObject:place];
    }
    [place release];
}

- (void)removeVenue:(PlaceModel *)place
{
    NSString * url = [NSString stringWithFormat:@"http://apps.teedot.com/places/api.php?mode=removePoint&userId=%@&venueId=%@", foursquareId, place.venueId];
    URLLoader * loader = [[URLLoader alloc] initWithURLString:url];
    [loader addTarget:self onLoad:@selector(removeVenueLoaded:)];
    [loader load];
}

- (void)removeVenueLoaded:(URLLoader*)loader
{
    NSLog(@"removevenueloaded %@", [loader dataAsString]);
    NSDictionary * object = [[CJSONDeserializer deserializer] deserialize:[loader data] error:nil];
    [loader release];
    bool success = [[object valueForKey:@"status"] isEqualToString:@"success"];
    if ([delegate respondsToSelector:@selector(placesManagerRemoveVenue:)]){
        [delegate performSelector:@selector(placesManagerRemoveVenue:) withObject:[NSNumber numberWithBool:(success)]];
    }
}

@end
