#import "BouncingBallTestAppDelegate.h"
#import "MCPongViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <OpenAL/alc.h>

@implementation BouncingBallTestAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    srand(time(NULL));
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
	
	// Setup sound
	ALCdevice *device = alcOpenDevice(NULL);
	ALCcontext *context = alcCreateContext(device, NULL);
	alcMakeContextCurrent(context);
	
	AudioSessionInitialize(NULL, NULL, NULL, NULL);
	UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	AudioSessionSetActive(TRUE);

	return YES;
}

- (void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

@end
