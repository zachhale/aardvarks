//
//  Wave.m
//  MCPong
//
//  Created by Jay Coskey on 2011-08-20.
//  Copyright 2011 Aardvarks. All rights reserved.
//

#import "Wave.h"

#define ELASTICITY 1.0f
#define FRICTION   0.0f
#define MASS       1.0f
#define THICKNESS  20.0f

@implementation Wave

@synthesize imageView;
@synthesize chipmunkObjects;

- (void)updatePosition 
{
	// Sync ball positon with chipmunk body
	imageView.transform = CGAffineTransformMakeTranslation(body.pos.x - THICKNESS, body.pos.y - THICKNESS);
}

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity
{
	if(self = [super init])
	{
		UIImage *image = [UIImage imageNamed:@"wave.png"];		
		imageView = [[UIImageView alloc] initWithImage:image];
		
		// Set up Chipmunk objects.
		cpFloat mass = MASS;
		
		// Center of mass is center of ball
		cpVect offset;
		offset.x = 0;
		offset.y = 0;
		
		cpFloat moment = cpMomentForCircle(mass, 0, THICKNESS, offset);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = position;
		body.vel = velocity;
		
		ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:THICKNESS offset:offset];
		
		// So it will bounce forever
		shape.elasticity = ELASTICITY;
		shape.friction = FRICTION;
		
		shape.collisionType = [Wave class];
		shape.data = self;
		
		chipmunkObjects = [ChipmunkObjectFlatten(body, shape, nil) retain];
	}
	
	return self;
}

- (void) dealloc
{
	[imageView release];
	[body release];
	[chipmunkObjects release];
	
	[super dealloc];
}

@end
