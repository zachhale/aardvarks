//
//  Wave.m
//  MCPong
//
//  Created by Jay Coskey on 2011-08-20.
//  Copyright 2011 Aardvarks. All rights reserved.
//

#import "math.h"
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

- (id)initWithPosition:(cpVect)position Dimensions:(cpVect)paddleDimensions Velocity:(cpVect)velocity
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
        
        cpVect hDims = cpvmult(paddleDimensions, 0.5);
        
        float velocityNorm = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
        cpVect unitVel = cpvmult(velocity, 1 / velocityNorm);
                
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
	[imageView release];
	[body release];
	[chipmunkObjects release];
	
	[super dealloc];
}

@end
