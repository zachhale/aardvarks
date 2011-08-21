#import "MCPongViewController.h"
#import "SimpleSound.h"
#import "chipmunk.h"

#define TEST_BALL_COUNT 200

// dampening per physics round
#define DAMPENING 0.005  

@implementation MCPongViewController

static NSString *borderType = @"borderType";
static cpFloat frand_unit(){return 2.0f*((cpFloat)rand()/(cpFloat)RAND_MAX) - 1.0f;}

- (void)viewDidLoad 
{
	[super viewDidLoad];
<<<<<<< HEAD
	ball = nil;
    wave = nil;
=======
	balls =  [[NSMutableArray alloc] init];
>>>>>>> 9a3d6d138cfeac34edd144e00189111ccd37cd30
	
	space = [[ChipmunkSpace alloc] init];
    
    self.view.multipleTouchEnabled = YES;
	
	// Setup boundary at screen edges
    [self createBounds];
	
	// Collision handler for ball - border
	[space addCollisionHandler:self
						 typeA:[Ball class] typeB:borderType
						 begin:@selector(beginWallCollision:space:)
					  preSolve:nil
					 postSolve:nil						
					  separate:nil
	 ];
	
	paddle1 = [[Paddle alloc] initWithPosition:cpv(368.0,68.0) Dimensions:cpv(110.0, 32.0)];
	[self.view addSubview:paddle1.imageView];
	[space add:paddle1];
	
	paddle2 = [[Paddle alloc] initWithPosition:cpv(368.0,940.0) Dimensions:cpv(110.0, 32.0)];
	[self.view addSubview:paddle2.imageView];
	[space add:paddle2];
    
	CGRect frame = self.view.frame;
	
	cpVect position = cpv(frame.size.width/2, frame.size.height/2);
	cpVect velocity = cpvmult(cpv(frand_unit(), frand_unit()), 400.0f);
	[self addNewBall:position :velocity];
    [self addNewWave:position :velocity];
	
	
	// Setup FPS label
	framesThisSecond = 0;
	CGRect  labelRect = CGRectMake(10, 0, 100, 30);
	fpsLabel = [[UILabel alloc] initWithFrame:labelRect];
	fpsLabel.text = @"0 FPS";
	[self.view addSubview:fpsLabel];
}

- (void)postSolveCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space 
{
	// Only play sound on first frame of the collision
	if(cpArbiterIsFirstContact(arbiter)) 
	{	
		// Approximate sound volume with impulse vector length
		cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));
		float volume = MIN(impulse/500.0f, 1.0f);
		if(volume > 0.05f)
		{
			[SimpleSound playSoundWithVolume:volume];
		}
	}
}


- (bool)beginWallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, theBall, border);
	
	//Paddle * p = paddle.data;
	return TRUE;
}


- (void)viewDidAppear:(BOOL)animated
{
	// Set up the display link to control the timing of the animation.
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	displayLink.frameInterval = 1;
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)update
{
	// Update FPS
	if ( framesThisSecond == 0 ) 
	{
		lastTimeStamp = CFAbsoluteTimeGetCurrent();
		framesThisSecond++;
	}
	else 
	{
		CFTimeInterval elapsed = (CFAbsoluteTimeGetCurrent() - lastTimeStamp);
		if ( elapsed < 1 )
		{
			framesThisSecond++;
		}
		else
		{
			NSString *str = [NSString stringWithFormat:@"%d FPS", framesThisSecond];
			fpsLabel.text = str;
			framesThisSecond = 0;
		}
	}

	// Update Physics space
	cpFloat dt = displayLink.duration * displayLink.frameInterval;
	[space step:dt];
	
    bool displayLog=arc4random()%20<1;
    
	for (Ball *b in balls){
        [b updatePosition];
        if (displayLog){
        //NSLog(@"ball %d  xy=%f %f",x, b.body.pos.x, b.body.pos.y);
        }
        b.body.vel=cpvmult(b.body.vel,1-DAMPENING);
    }
    
	[paddle1 updatePosition];
	[paddle2 updatePosition];
    [wave updatePosition];
	// Update ball positions to match the physics bodies
	
}

- (void)viewDidDisappear:(BOOL)animated 
{
	[displayLink invalidate];
	[scoreImageView release];
	displayLink = nil;
}

- (void)dealloc 
{
	[balls release];
	[space release];
	[fpsLabel release];
	[paddle1 release];
	[paddle2 release];
    [wave release];
	[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	touchStart = [touch locationInView:self.view];
	
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
		if (point.y > self.view.frame.size.height/2.0f) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
		else {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
		if (point.y > self.view.frame.size.height/2.0f) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
		else {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}

	}

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
		if (point.y > self.view.frame.size.height/2.0f) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
		else {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		
	}
}

- (IBAction)addBallForReal;
{
    
    NSLog(@"New Ball");
    
    [self addNewBall:cpv(300.0,300.0): cpv(fmod(arc4random(),300)-150.0,fmod( arc4random(),300)-150.0)];
    
}

- (void)addNewBall:(cpVect)position :(cpVect)velocity;
{
	
    Ball *ball=[[Ball alloc] initWithPosition:position Velocity:velocity];
	
	// Add to view, physics space, our list
	[self.view addSubview:ball.imageView];
    [balls addObject: ball];    
	[space add:ball];
	[ball release];
	
}

- (void)addNewWave:(cpVect)position :(cpVect)velocity;
{
	if (!wave) {
		wave = [[Wave alloc] initWithPosition:position Velocity:velocity];	
	}
	
	// Add to view, physics space, our list
	[self.view addSubview:wave.imageView];
	//[waves addObject:wave];
	[space add:wave];
    
- (void)createBounds {
	CGRect frame = self.view.frame;
    cpFloat radius = 10.0;
    
    // left shape
    ChipmunkBody *leftBody = [[ChipmunkBody alloc] initStaticBody];
    leftBody.mass = 9999999.0;
    cpVect leftStart = cpv(0, 0);
    cpVect leftEnd = cpv(0,frame.size.height);	
    ChipmunkSegmentShape *leftSegment = [ChipmunkSegmentShape segmentWithBody:leftBody from:leftStart to:leftEnd radius:radius];
    leftSegment.elasticity = 1.0f;
    leftSegment.friction = 0.0f;
    [space addStaticShape:leftSegment];
    [leftBody release];

    // right shape
    ChipmunkBody *rightBody = [[ChipmunkBody alloc] initStaticBody];
    rightBody.mass = 9999999.0;
    cpVect rightStart = cpv(frame.size.width, 0);
    cpVect rightEnd = cpv(frame.size.width, frame.size.height);	
    ChipmunkSegmentShape *rightSegment = [ChipmunkSegmentShape segmentWithBody:rightBody from:rightStart to:rightEnd radius:radius];
    rightSegment.elasticity = 1.0f;
    rightSegment.friction = 0.0f;
    [space addStaticShape:rightSegment];
    [rightBody release];
}

@end