#import <UIKit/UIKit.h>

@class MCPongViewController;

@interface BouncingBallTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MCPongViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MCPongViewController *viewController;

@end

