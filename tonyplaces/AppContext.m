//
//  AppContext.m
//  tonyplaces
//
//  Created by Senja iMac on 6/8/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import "AppContext.h"
#import "tonyplacesAppDelegate.h"

@implementation AppContext


+ (RootController *)mainController
{
    return ((tonyplacesAppDelegate*)[UIApplication sharedApplication].delegate).viewController;
}

@end
