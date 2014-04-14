//
//  SKEMyScene.h
//  SKMobileEx
//

//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JCButton.h"

static const uint32_t missileCategory = 0x1 << 0;
static const uint32_t shipCategory = 0x1 << 1;
static const uint32_t asteroidCategory = 0x1 << 2;
static const uint32_t worldCategory = 0x1 << 3;


@interface SKEMyScene : SKScene <SKPhysicsContactDelegate>

@property (strong, nonatomic) JCButton *fireButton;
@property (strong, nonatomic) JCButton *thrustButton;
@property (strong, nonatomic) JCButton *leftButton;
@property (strong, nonatomic) JCButton *rightButton;

@property (strong, nonatomic) SKSpriteNode* ship;
@property (strong, nonatomic) SKShapeNode* shipDirection;

@end
