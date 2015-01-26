//
//  BatchURLLoader.h
//  tonyplaces
//
//  Created by Senja iMac on 6/21/11.
//  Copyright 2011 Senja Solutions Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BatchURLLoader : NSObject {
    NSMutableArray * urls;
    int loadedCount;
    NSMutableArray * loaderData;
    
    id delegate;
}

@property (nonatomic,retain) id delegate;

- (void)addURLString:(NSString *)string;
- (void)load;

@end


@protocol BatchURLLoaderDelegate <NSObject>

@optional
- (void)batchURLLoader:(BatchURLLoader*)batchLoader loaded:(NSArray*)loaderData;

@end
