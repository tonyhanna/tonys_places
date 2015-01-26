//
//  placesAppDelegate.h
//  tonyplaces
//
//  Created by Dominikus Putranto on 5/27/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootController;

@interface tonyplacesAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet RootController *viewController;

@end
