//
//  CallbackHandler.h
//  Smirnoff
//
//  Created by Dominikus D Putranto on 3/14/11.
//  Copyright 2011 ITB. All rights reserved.
//

@interface CallbackHandler : NSObject {
	id object;
	SEL selector;
}

@property (nonatomic, retain) id object;
@property (nonatomic) SEL selector;

@end
