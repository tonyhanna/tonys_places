//
//  PlaceModel.m
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/30/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "PlaceModel.h"
#import "NSString+URLEncoding.h"

@implementation PlaceModel

@synthesize venueId, name, verified, phone, twitter, categories, description, address, crossStreet, city, state, postalCode, country, latitude, longitude, distance, bearing, addedNavigate;

- (id)init
{
    self = [super init];
    if (self != nil){
        name = @""; categories = nil; verified = false; phone = @""; twitter = @""; description = @""; address = @""; crossStreet = @""; city = @""; state = @""; postalCode = @"";
        addedNavigate = false;
    }
    return self;
}

- (void)dealloc
{
    [categories release];
    [super dealloc];
}

- (NSString *)makeAddQuery
{
    return [NSString stringWithFormat:@"id=%@&name=%@&verified=%d&phone=%@&twitter=%@&category=%@&description=%@&address=%@&crossStreet=%@&city=%@&state=%@&postalCode=%@&country=%@&lat=%g&lng=%g",
            [venueId urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [name urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            verified, 
            [phone?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [twitter?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [self categoriesAsString], 
            [description?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [address?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [crossStreet?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [city?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [state?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [postalCode?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            [country?:@"" urlEncodeUsingEncoding:NSUTF8StringEncoding], 
            latitude, 
            longitude
    ];
}

- (NSString*)categoriesAsString
{
    return [categories componentsJoinedByString:@", "];
}

- (void)setCategoriesWithString:(NSString*)aString
{
    categories = [[aString componentsSeparatedByString:@", "] retain];
}

@end
