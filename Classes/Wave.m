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
#define THICKNESSX  60.0f
#define THICKNESSY  25.0f


@implementation Wave

@synthesize chipmunkObjects;

- (void)updatePosition 
{
	// Sync ball positon with chipmunk body
	self.transform=CGAffineTransformMakeTranslation(body.pos.x - THICKNESSX, body.pos.y - THICKNESSY);
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
    CGContextMoveToPoint(ctx, 0, THICKNESSY*.5);
    
    CGContextAddCurveToPoint(ctx, THICKNESSX/6.0,THICKNESSY*.9, THICKNESSX*2.0/6.0,THICKNESSY*.1, THICKNESSX*.5,THICKNESSY*.5);
    CGContextAddCurveToPoint(ctx, THICKNESSX*4.0/6.0,THICKNESSY*.9, THICKNESSX*5.0/6.0,THICKNESSY*.7, THICKNESSX,THICKNESSY*.5);
    
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
		
		cpFloat moment = cpMomentForCircle(mass, 0, THICKNESSX, offset);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = position;
		body.vel = velocity;
		
		ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:THICKNESSX offset:offset];
		
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
