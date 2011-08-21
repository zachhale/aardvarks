//
//  Wave.m
//  MCPong
//
//  Created by Jay Coskey on 2011-08-20.
//  Copyright 2011 Aardvarks. All rights reserved.
//

#import "math.h"
#import "Wave.h"
#import <QuartzCore/QuartzCore.h>

#define AMPLITUDE  0.75f
#define ELASTICITY 1.0f
#define FRICTION   0.0f
#define MASS       1.0f
#define THICKNESSX  60.0f
#define THICKNESSY  25.0f

// seconds
#define WAVEINTERVAL 2.0



@implementation Wave

@synthesize chipmunkObjects;
@synthesize waveIntervalOffset;
@synthesize unitVel;

- (void)updatePosition 
{
	// Sync ball positon with chipmunk body
	self.transform=CGAffineTransformMakeTranslation(body.pos.x - THICKNESSX, body.pos.y - THICKNESSY);
    
    [self setNeedsDisplay];
}

- (void) drawRect: (CGRect)rect
{    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
        
    CGContextSetLineWidth(ctx, 3);
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {.12, .14, .6, 1.0};
    CGColorRef color = CGColorCreate(rgb, comps);
    CGColorSpaceRelease(rgb);
    
    CGContextSetStrokeColorWithColor(ctx,color);
    CGContextMoveToPoint(ctx, 0, THICKNESSY*.5);
    
    // double waveMul=(fmodf(CACurrentMediaTime()+self.waveIntervalOffset,WAVEINTERVAL))/WAVEINTERVAL;
    double waveMul = AMPLITUDE * sin(CACurrentMediaTime()+self.waveIntervalOffset + (int) self);
    
    CGContextAddCurveToPoint(ctx, THICKNESSX/6.0,waveMul*THICKNESSY, THICKNESSX*2.0/6.0,(1.0-waveMul)*THICKNESSY, THICKNESSX*.5,THICKNESSY*.5);
    CGContextAddCurveToPoint(ctx, THICKNESSX*4.0/6.0,waveMul*THICKNESSY, THICKNESSX*5.0/6.0,(1.0-waveMul)*THICKNESSY, THICKNESSX,THICKNESSY*.5);
    
    CGContextSetLineWidth(ctx, 2);
    CGContextStrokePath(ctx);
    
}

- (id)initWithPosition:(cpVect)position Dimensions:(cpVect)waveDims Velocity:(cpVect)velocity
{
	if(self = [super init])
	{	
		// Set up Chipmunk objects.
		cpFloat mass = MASS;
		
		// Center of mass is center of ball
		cpVect offset;
		offset.x = 0;
		offset.y = 0;
        
        cpVect hDims = cpvmult(waveDims, 0.5);
        
        float velocityNorm = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
        unitVel = cpvmult(velocity, 1 / velocityNorm);
                
        cpVect verts[4];
        verts[0] = cpv(     hDims.x,      hDims.y);
        verts[1] = cpv(     hDims.x, -1 * hDims.y);
        verts[2] = cpv(-1 * hDims.x, -1 * hDims.y);
        verts[3] = cpv(-1 * hDims.x,      hDims.y);
        
        cpVect rotVerts[4];
        // TODO: Refactor this repetitive code to a matrix multiplication function.
        rotVerts[0] = cpv(   unitVel.y * verts[0].x + unitVel.x * verts[0].y,
                        -1 * unitVel.x * verts[0].x + unitVel.y * verts[0].y);
        rotVerts[1] = cpv(unitVel.y * verts[1].x + unitVel.x * verts[1].y,
                        -1 * unitVel.x * verts[1].x + unitVel.y * verts[1].y);
        rotVerts[2] = cpv(unitVel.y * verts[2].x + unitVel.x * verts[2].y,
                        -1 * unitVel.x * verts[2].x + unitVel.y * verts[2].y);
        rotVerts[3] = cpv(unitVel.y * verts[3].x + unitVel.x * verts[3].y,
                        -1 * unitVel.x * verts[3].x + unitVel.y * verts[3].y);

		cpFloat moment = cpMomentForPoly(mass, 3, rotVerts, position);
        
        self.frame=CGRectMake(60,60,60,60);
        self.opaque=false;
        arc4random_stir();
        
        self.waveIntervalOffset=fmod(arc4random(),WAVEINTERVAL);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = position;
		body.vel = velocity;
		ChipmunkPolyShape * shape = [ChipmunkPolyShape polyWithBody:body count:4 verts:rotVerts offset:position];

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
