//
//  SKEMyScene.h
//  SKMobileEx
//

//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JCButton.h"
#import "CollisionCategories.h"
#import "SKEShip.h"

@interface SKEMyScene : SKScene <SKPhysicsContactDelegate>

@property (strong, nonatomic) JCButton *fireButton;
@property (strong, nonatomic) JCButton *thrustButton;
@property (strong, nonatomic) JCButton *leftButton;
@property (strong, nonatomic) JCButton *rightButton;

@property (strong, nonatomic) SKEShip* ship;

@end
