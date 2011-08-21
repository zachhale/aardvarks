
#import "Paddle.h"

@implementation Paddle

@synthesize imageView;
@synthesize chipmunkObjects;
@synthesize body;

#define MASS 9999999.0f
- (void)updatePosition 
{
	// Sync ball positon with chipmunk body
	imageView.transform = CGAffineTransformMakeTranslation(body.pos.x - offset.x, body.pos.y - offset.y);
}

- (id)initWithPosition:(cpVect)position Dimensions:(cpVect)dimensions;
{
	if(self = [super init])
	{
		UIImage *image = [UIImage imageNamed:@"paddle.png"];		
		imageView = [[UIImageView alloc] initWithImage:image];
		
		offset = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
		
		// Set up Chipmunk objects.
		
		body = [[ChipmunkBody alloc] initStaticBody];
		body.mass = MASS;

		ChipmunkPolyShape * shape =  [ChipmunkPolyShape boxWithBody:body width:dimensions.x height:dimensions.y];
	
		// So it will bounce forever
		shape.elasticity = 1.0f;
		shape.friction = 0.0f;
		
		shape.collisionType = [Paddle class];
		shape.data = self;
		
		chipmunkObjects = [ChipmunkObjectFlatten(body, shape, nil) retain];
		body.pos = position;
		[self updatePosition];
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
