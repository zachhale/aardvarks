//
//  Wave.h
//  MCPong
//
//  Created by Jay Coskey on 2011-08-20.
//  Copyright 2011 Aardvarks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "ObjectiveChipmunk.h"


@interface Wave : UIView <ChipmunkObject>
{
	
	ChipmunkBody *body;
	NSSet *chipmunkObjects;
    float waveIntervalOffset;
    cpVect unitVel;
}

@property (readonly) NSSet *chipmunkObjects;
- (id)initWithPosition:(cpVect)position Dimensions:(cpVect)dimensions Velocity:(cpVect)velocity;
@property float waveIntervalOffset;
@property cpVect unitVel;
- (void)updatePosition;
@end