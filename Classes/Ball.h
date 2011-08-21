#import <Foundation/Foundation.h>

#import "ObjectiveChipmunk.h"

@interface Ball : NSObject <ChipmunkObject> 
{
	UIImageView *imageView;
	
	ChipmunkBody *body;
	NSSet *chipmunkObjects;
}

@property (readonly) UIImageView *imageView;
@property (readonly) NSSet *chipmunkObjects;
@property (readonly) ChipmunkBody *body;

- (id)initWithPosition:(cpVect)position Velocity:(cpVect)velocity;

- (void)updatePosition;

@end
