//
//  Wave.h
//  MCPong
//
//  Created by Jay Coskey on 2011-08-20.
//  Copyright 2011 Aardvarks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectiveChipmunk.h"

@interface Wave : NSObject <ChipmunkObject>
{
	UIImageView *imageView;
	
	ChipmunkBody *body;
	NSSet *chipmunkObjects;
}

@property (readonly) UIImageView *imageView;
@property (readonly) NSSet *chipmunkObjects;
- (id)initWithPosition:(cpVect)position Dimensions:(cpVect)dimensions Velocity:(cpVect)velocity;
- (void)updatePosition;
@end