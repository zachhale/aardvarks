#import "Ball.h"

#define RADIUS 16.0f

@implementation Ball

@synthesize imageView;
@synthesize chipmunkObjects;
@synthesize body;

- (void)updatePosition 
{
	// Sync ball positon with chipmunk body
	imageView.transform = CGAffineTransformMakeTranslation(body.pos.x - RADIUS, body.pos.y - RADIUS);
}

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity
{
	if(self = [super init])
	{
		UIImage *image = [UIImage imageNamed:@"ball.png"];		
		imageView = [[UIImageView alloc] initWithImage:image];
		
		// Set up Chipmunk objects.
		cpFloat mass = 1.0f;
		
		// Center of mass is center of ball
		cpVect offset;
		offset.x = 0;
		offset.y = 0;
		
		cpFloat moment = cpMomentForCircle(mass, 0, RADIUS, offset);
		
		body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
		body.pos = position;
		body.vel = velocity;
		
		ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:RADIUS offset:offset];
		
		// So it will bounce forever
		shape.elasticity = 1.0f;
		shape.friction = 0.0f;
		
		shape.collisionType = [Ball class];
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
