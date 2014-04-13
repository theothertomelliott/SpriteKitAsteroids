//
//  SKEMyScene.h
//  SKMobileEx
//

//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JCButton.h"

@interface SKEMyScene : SKScene

@property (strong, nonatomic) JCButton *thrustButton;
@property (strong, nonatomic) JCButton *leftButton;
@property (strong, nonatomic) JCButton *rightButton;
@property (strong, nonatomic) SKSpriteNode* ship;
@property (strong, nonatomic) SKShapeNode* shipDirection;

@end
