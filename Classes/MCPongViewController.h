#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>

#import "Ball.h"
#import "ObjectiveChipmunk.h"
#import "Paddle.h"
#import "Wave.h"

@interface MCPongViewController : UIViewController 
{
	CADisplayLink *displayLink;
	
	IBOutlet UIImageView * scoreImageView;
	ChipmunkSpace *space;
	// Ball *ball;
    Wave *wave;
    NSMutableArray *balls;

	
	CGPoint touchStart;
	
	// To calculate and display FPS
	CFTimeInterval lastTimeStamp;
	unsigned int framesThisSecond;
	UILabel *fpsLabel;
	
	Paddle * paddle1;
	Paddle * paddle2;
}

- (void)addNewBall:(cpVect)position :(cpVect)velocity;
- (void)addNewWave:(cpVect)position :(cpVect)velocity;
- (void)createBounds;

- (IBAction)addBallForReal;

@end
