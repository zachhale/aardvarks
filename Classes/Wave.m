//
//  Wave.m
//  MCPong
//
//  Created by Jay Coskey on 2011-08-20.
//  Copyright 2011 Aardvarks. All rights reserved.
//

#import "Wave.h"
#import <QuartzCore/QuartzCore.h>

#define ELASTICITY 1.0f
#define FRICTION   0.0f
#define MASS       1.0f
#define THICKNESS  20.0f

@implementation Wave

@synthesize chipmunkObjects;

- (void)updatePosition 
{
	// Sync ball positon with chipmunk body
	self.transform=CGAffineTransformMakeTranslation(body.pos.x - THICKNESS, body.pos.y - THICKNESS);
}

- (void) drawRect: (CGRect)rect
{    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
        
    CGContextSetLineWidth(ctx, 3);
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {.1, .4, .9, .5};
    CGColorRef color = CGColorCreate(rgb, comps);
    CGColorSpaceRelease(rgb);
    
    CGContextSetStrokeColorWithColor(ctx,color);
    CGContextMoveToPoint(ctx, 0, 30);
    
    CGContextAddCurveToPoint(ctx, 10,45, 20,15, 30,30);
    CGContextAddCurveToPoint(ctx, 40,45, 50,15, 60,30);
    
    CGContextSetLineWidth(ctx, 2);
    CGContextStrokePath(ctx);
    
}


- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity
{
	if(self = [super init])
	{	
		// Set up Chipmunk objects.
		cpFloat mass = MASS;
		
		// Center of mass is center of ball
		cpVect offset;
		offset.x = 0;
		offset.y = 0;
        
        self.frame=CGRectMake(60,60,60,60);
        self.opaque=false;
		
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
	[body release];
	[chipmunkObjects release];
	
	[super dealloc];
}

@end
