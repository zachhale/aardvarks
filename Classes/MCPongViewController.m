#import "MCPongViewController.h"
#import "SimpleSound.h"
#import "chipmunk.h"

#define DAMPENING 0.0005  // dampening per physics round
#define PADDLE_WIDTH 110.0
#define PADDLE_HEIGHT 32.0
#define PADDLE1_Y 68.0
#define PADDLE2_Y 940.0
#define TEST_BALL_COUNT 200

@implementation MCPongViewController

static NSString *borderType = @"borderType";
static cpFloat frand_unit(){return 2.0f*((cpFloat)rand()/(cpFloat)RAND_MAX) - 1.0f;}

- (void)viewDidLoad 
{
	[super viewDidLoad];
    waves =  [[NSMutableArray alloc] init];
	
	balls =  [[NSMutableArray alloc] init];
	
	space = [[ChipmunkSpace alloc] init];
    
    self.view.multipleTouchEnabled = YES;
	
	// Setup boundary at screen edges
    [self createBounds];
	
	// Collision handler for ball - border
	[space addCollisionHandler:self
						 typeA:[Ball class] typeB:borderType
						 begin:@selector(beginBallWallCollision:space:)
					  preSolve:nil
					 postSolve:@selector(postSolveCollision:space:)			
					  separate:nil
	 ];
    
    // Collision handler for Ball - Wave
	[space addCollisionHandler:self
						 typeA:[Ball class] typeB:[Wave class]
						 begin:nil // @selector(beginBallWaveCollision:space:)
					  preSolve:nil
					 postSolve:nil						
					  separate:@selector(separateBallWaveCollision:space:)
	 ];
	
	paddle1 = [[Paddle alloc] initWithPosition:cpv(368.0, PADDLE1_Y) Dimensions:cpv(PADDLE_WIDTH, PADDLE_HEIGHT)];
	[self.view addSubview:paddle1.imageView];
	[space add:paddle1];
	
	paddle2 = [[Paddle alloc] initWithPosition:cpv(368.0,PADDLE2_Y) Dimensions:cpv(PADDLE_WIDTH, PADDLE_HEIGHT)];
	[self.view addSubview:paddle2.imageView];
	[space add:paddle2];

    CGRect frame = self.view.frame;
    
    // add new ball
    [self addNewBall];
    
    // add new wave
    cpVect waveDims = cpv(2 * frame.size.height, 1);  // TODO: Wave should stretch across entire screen
	cpVect position = cpv(frame.size.width/2, frame.size.height/2);
	cpVect velocity = cpvmult(cpv(frand_unit(), frand_unit()), 400.0f);
    [self addNewWave:position :waveDims :velocity];
	
	// Setup FPS label
	framesThisSecond = 0;
	CGRect  labelRect = CGRectMake(10, 0, 100, 30);
	fpsLabel = [[UILabel alloc] initWithFrame:labelRect];
	fpsLabel.text = @"0 FPS";
	[self.view addSubview:fpsLabel];
	
    // setup intitial scores
    player1Score = 0;
    player2Score = 0;
    
	player1ScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 2 - 50, 30)];
    player1ScoreLabel.transform = CGAffineTransformConcat(
                                                          CGAffineTransformMakeRotation(M_PI/2),
                                                          CGAffineTransformMakeTranslation(-140, 0)
                                                          );
    player1ScoreLabel.backgroundColor = [UIColor clearColor];
    player1ScoreLabel.textAlignment = UITextAlignmentRight;
	player1ScoreLabel.text = @"Player 1: 0";
	[self.view addSubview:player1ScoreLabel];

	player2ScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2 + 50, 0, frame.size.width / 2 - 50, 30)];
    player2ScoreLabel.transform = CGAffineTransformConcat(
                                                          CGAffineTransformMakeRotation(-1.0 * M_PI/2),
                                                          CGAffineTransformMakeTranslation(140,725)
                                                          );
    player2ScoreLabel.backgroundColor = [UIColor clearColor];
	player2ScoreLabel.text = @"Player 2: 0";
	[self.view addSubview:player2ScoreLabel];
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

- (bool)beginBallWallCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, theBall, border);
	
    return TRUE;
}

- (bool)separateBallWaveCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, theBall, theWave);
	
	//Paddle * p = paddle.data;
    float PERCENTAGE_VELOCITY_TRANSFER = 0.5f;
    cpVect waveVel = cpv(0.0, 0.0);  // theWave.velocity
    cpVect ballVel = cpv(0.0, 0.0);  // theBall.velocity
    theBall.body.vel = cpvadd(theBall.body.vel, cpvmult(cpvsub(waveVel, ballVel), PERCENTAGE_VELOCITY_TRANSFER));
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
    
    [self updatePositions];
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
    [player1ScoreLabel release];
    [player2ScoreLabel release];
    [waves release];
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
        // Note: Former boundary was middle of court: self.view.frame.size.height/2.0f
		if (point.y < PADDLE1_Y + PADDLE_HEIGHT) {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		else if (point.y > PADDLE2_Y - PADDLE_HEIGHT) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
        // Note: Former boundary was middle of court: self.view.frame.size.height/2.0f 
		if (point.y < PADDLE1_Y + PADDLE_HEIGHT) {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		else if (point.y > PADDLE2_Y - PADDLE_HEIGHT) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		}

	}

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point;
	for(UITouch * touch in [touches allObjects])
	{
		point = [touch locationInView:self.view];
        // Note: Former boundary was middle of court: self.view.frame.size.height/2.0f 
		if (point.y < PADDLE1_Y + PADDLE_HEIGHT) {
			paddle1.body.pos = cpv(point.x, paddle1.body.pos.y);
		}
		else if (point.y > PADDLE2_Y - PADDLE_HEIGHT) {
			paddle2.body.pos = cpv(point.x, paddle2.body.pos.y);
		} else {
            // TODO: Replace third argument below with sweep velocity
            cpVect prevPoint = [touch previousLocationInView:self.view];
            cpVect velocity = cpvsub(point, prevPoint);
            
            // Previously, velocity was random: 3rd arg was: cpv(0,fmod( arc4random(),300)-150.0)];
            [self addNewWave: cpv(point.x,point.y): cpv(100,2): cpvmult(velocity, 25.0)];
        }
	}
}

- (IBAction)addBallForReal;
{
    
    NSLog(@"New Ball");
    
    [self addNewBall:cpv(300.0,300.0): cpv(fmod(arc4random(),300)-150.0,fmod( arc4random(),300)-150.0)];
    
}

- (void)addNewBall {
    CGRect frame = self.view.frame;

    cpVect position = cpv(frame.size.width/2, frame.size.height/2);
	cpVect velocity = cpvmult(cpv(frand_unit(), frand_unit()), 1000.0f);
	[self addNewBall:position :velocity];
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

- (void)addNewWave:(cpVect)position :(cpVect)dimensions :(cpVect)velocity;
{
    Wave *wave = [[Wave alloc] initWithPosition:position Dimensions:dimensions Velocity:velocity];	
	
	// Add to view, physics space, our list
	[self.view addSubview:wave];
	[waves addObject:wave];
	[space add:wave];
    
    [wave release];
}
    
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

- (void)updatePositions {
	CGRect frame = self.view.frame;

    // Update Physics space
	cpFloat dt = displayLink.duration * displayLink.frameInterval;
	[space step:dt];
	
    bool displayLog = NO;
    
	for (Ball *b in balls){
        [b updatePosition];
        
        if (displayLog){
            //NSLog(@"ball %d  xy=%f %f",x, b.body.pos.x, b.body.pos.y);
        }

        // score based on ball position
        if (b.body.pos.y > frame.size.height) {
            [self incrementPlayer2Score];
            [b.imageView removeFromSuperview];
            [space remove:b];
            [balls removeObject:b];
            [self addNewBall];
        } else if (b.body.pos.y < 0) {
            [self incrementPlayer1Score];
            [b.imageView removeFromSuperview];
            [space remove:b];
            [balls removeObject:b];
            [self addNewBall];
        } else {
            b.body.vel=cpvmult(b.body.vel,1-DAMPENING);
        }
    }
    
	// Update ball positions to match the physics bodies
	[paddle1 updatePosition];
	[paddle2 updatePosition];
    
    for (Wave * wave in waves){
        [wave updatePosition];
    }
}

- (void)incrementPlayer1Score {
    player1Score = player1Score + 1;
    NSString *str = [NSString stringWithFormat:@"Player 1: %d", player1Score];
    player1ScoreLabel.text = str;
}

- (void)incrementPlayer2Score {
    player2Score = player2Score + 1;
    NSString *str = [NSString stringWithFormat:@"Player 2: %d", player2Score];
    player2ScoreLabel.text = str;
}

@end