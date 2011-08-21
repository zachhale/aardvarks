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
}

@property (readonly) NSSet *chipmunkObjects;
@property float waveIntervalOffset;

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity;

- (void)updatePosition;
@end