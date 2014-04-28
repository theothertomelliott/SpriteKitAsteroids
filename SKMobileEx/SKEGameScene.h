//
//  SKEMyScene.h
//  SKEAsteroids
//

//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JCButton.h"
#import "CollisionCategories.h"
#import "SKEShip.h"
#import "SKEWrappingScene.h"

@interface SKEGameScene : SKEWrappingScene

// Game state
@property (nonatomic) int score;
@property (nonatomic) int lives;
@property (nonatomic) int asteroidCount;

// Controls
@property (strong, nonatomic) JCButton *fireButton;
@property (strong, nonatomic) JCButton *thrustButton;
@property (strong, nonatomic) JCButton *leftButton;
@property (strong, nonatomic) JCButton *rightButton;

// Entities in play
@property (strong, nonatomic) SKEShip* ship;
@property (strong, nonatomic) NSMutableArray* asteroids;

// Labels and other indicators
@property (strong, nonatomic) SKLabelNode* scoreLabel;
@property (strong, nonatomic) SKLabelNode* livesLabel;

@end
