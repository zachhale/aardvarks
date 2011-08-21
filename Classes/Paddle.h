//
//  Paddle.h
//  BouncingBallTest
//
//  Created by Stephen Johnson on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectiveChipmunk.h"

@interface Paddle : NSObject <ChipmunkObject> {

	UIImageView *imageView;
	
	ChipmunkBody *body;
	NSSet *chipmunkObjects;
	
	CGPoint offset;
}

@property (readonly) UIImageView *imageView;
@property (readonly) NSSet *chipmunkObjects;
@property (assign) 	ChipmunkBody *body;

- (id)initWithPosition:(cpVect)position Dimensions:(cpVect)dimensions;

- (void)updatePosition;

@end
