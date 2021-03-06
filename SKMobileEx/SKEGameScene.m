//
//  SKEMyScene.m
//  SKEAsteroids
//
//  Created by Tom Elliott on 07/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEGameScene.h"
#import "SKEAsteroid.h"
#import "SKEMissile.h"
#import "SKEMenuScene.h"
#import "CGVectorAdditions.h"
#include <stdlib.h>
#import "SKEShipExplosion.h"
#import "SKEPersistent.h"

@implementation SKEGameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Initializing scene");
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        [self createLabels];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        self.asteroids = [NSMutableArray array];
        
        [self initGame];
        
        [self createShip];
        
        [self addAsteroids:self.asteroidCount];
        
        [self createButtons:size];

    }
    return self;
}

- (void) createLabels {

    /* Title Labels */
    SKLabelNode* scoreTitle = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width - 20,
                                                                             self.frame.size.height - 20) horizontalAlignment: SKLabelHorizontalAlignmentModeRight];
    scoreTitle.Text = @"Score";
    
    SKLabelNode* highScoreTitle = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width/2,
                                                                                 self.frame.size.height - 20)horizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
    highScoreTitle.Text = @"High Score";
    
    SKLabelNode* livesTitle = [self makeDefaultLabelWithPosition:CGPointMake(20,
                                                                             self.frame.size.height - 20) horizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
    livesTitle.Text = @"Lives";
    
    
    /* Active Labels */
    self.scoreLabel = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width - 20,
                                                                     self.frame.size.height - 40) horizontalAlignment:SKLabelHorizontalAlignmentModeRight];
    
    self.livesLabel = [self makeDefaultLabelWithPosition:CGPointMake(20,
                                                                     self.frame.size.height - 40) horizontalAlignment:SKLabelHorizontalAlignmentModeLeft];
    
    self.highScoreLabel = [self makeDefaultLabelWithPosition:CGPointMake(self.frame.size.width/2,
                                                                         self.frame.size.height - 40) horizontalAlignment:SKLabelHorizontalAlignmentModeCenter];
}

/**
 * Initialize the game with 3 lives and 1 asteroid
 */
- (void) initGame {
    self.asteroidCount = 1;
    self.lives = 3;
    self.score = 0;
}

/*
 * Add (count) asteroids to the scene
 */
- (void) addAsteroids: (int) count {
    
    // Establish a "safe zone" around the ship where asteroids cannot be added
    int shipbound_x1 = self.ship.position.x - self.ship.size.width;
    int shipbound_x2 = self.ship.position.x + self.ship.size.width;
    int shipbound_y1 = self.ship.position.y - self.ship.size.height;
    int shipbound_y2 = self.ship.position.y + self.ship.size.height;
    
    for(int i = 0; i < count; i++){
        
        // Generate 4 random coordinates for the asteroid, 2 x and 2 y
        int xpos1 = arc4random_uniform(shipbound_x1);
        int ypos1 = arc4random_uniform(shipbound_y1);
        int xpos2 = shipbound_x2 + arc4random_uniform(self.size.width - shipbound_x2);
        int ypos2 = shipbound_y2 + arc4random_uniform(self.size.height - shipbound_y2);
        
        // Select one each of the x and y coordinates and create position
        int xpos = arc4random_uniform(100) < 50 ? xpos1 : xpos2;
        int ypos = arc4random_uniform(100) < 50 ? ypos1 : ypos2;
        CGPoint pos = CGPointMake(xpos, ypos);
        
        // Apply a random impulse to get the asteroid moving
        CGVector impulse = CGVectorMake(arc4random_uniform(200)/100.0f, arc4random_uniform(200)/100.0f);
        
        NSLog(@"Asteroid Position: (%0.2f,%0.2f)",pos.x,pos.y);
        NSLog(@"Asteroid impulse: (%0.2f,%0.2f)",impulse.dx,impulse.dy);
        
        SKEAsteroid* asteroid = [[SKEAsteroid alloc] initWithType:ASTEROID_TYPE_LARGE position:pos];
        [self addChild:asteroid];
        [self.asteroids addObject:asteroid];
        [asteroid.physicsBody applyImpulse:impulse];
        
    }
    
}

- (void) incrementScore:(int) value {
    self.score += value;
    if([SKEPersistent updateHighScore:self.score]){
        NSLog(@"Achieved high score!");
    }
}

/*
 * Handle contact between two entities
 */
- (void) didBeginContact:(SKPhysicsContact *)contact
{
    // Perform inherited collision handling
    [super didBeginContact:contact];
    
    /*
     * Handle an asteroid being hit by a missile
     */
    
    if(((contact.bodyA.categoryBitMask & asteroidCategory) != 0 && (contact.bodyB.categoryBitMask & missileCategory) != 0)
    || ((contact.bodyB.categoryBitMask & asteroidCategory) != 0 && (contact.bodyA.categoryBitMask & missileCategory) != 0)){
        NSLog(@"Hit asteroid!");
        
        SKEAsteroid* shotAsteroid = (SKEAsteroid*)  ((contact.bodyA.categoryBitMask & asteroidCategory) != 0 ? contact.bodyA.node : contact.bodyB.node);
        
        [self incrementScore:shotAsteroid.score];
        
        if(shotAsteroid.type > 0){
            
            SKEMissile* missile = (SKEMissile*)  (contact.bodyA.categoryBitMask == missileCategory ? contact.bodyA.node : contact.bodyB.node);

            CGVector mDirection = missile.direction;
            CGVector mPerp = CGVectorMakePerpendicular(mDirection);
            
            CGFloat fragmentDist = shotAsteroid.radius - shotAsteroid.radius/2;
            
            CGPoint position1 = CGPointMake(shotAsteroid.position.x + mPerp.dx*fragmentDist, shotAsteroid.position.y + mPerp.dy*fragmentDist);
            CGPoint position2 = CGPointMake(shotAsteroid.position.x - mPerp.dx*fragmentDist, shotAsteroid.position.y - mPerp.dy*fragmentDist);
            
            CGVector mImpulse1 = CGVectorMultiplyByScalar(mPerp, 0.5f);
            CGVector mImpulse2 = CGVectorMultiplyByScalar(mPerp, -0.5f);
            
            NSLog(@"mImpulse1: (%0.2f,%0.2f)", mImpulse1.dx, mImpulse1.dy);
            NSLog(@"mImpulse2: (%0.2f,%0.2f)", mImpulse2.dx, mImpulse2.dy);
            
            SKEAsteroid* asteroid = [[SKEAsteroid alloc] initWithType:shotAsteroid.type-1 position:position1];
            [self.asteroids addObject:asteroid];
            [self addChild:asteroid];
            [asteroid.physicsBody applyImpulse:mImpulse1];
            
            asteroid = [[SKEAsteroid alloc] initWithType:shotAsteroid.type-1 position:position2];
            [self.asteroids addObject:asteroid];
            [self addChild:asteroid];
            [asteroid.physicsBody applyImpulse:mImpulse2];
        }
        
        [self.asteroids removeObject:shotAsteroid];
        
        // Remove the nodes in question
        [self removeChildrenInArray:[NSArray arrayWithObjects:contact.bodyA.node,contact.bodyB.node,nil]];
        
        // When there are no asteroids left, create some new big ones
        if([self.asteroids count] == 0){
            self.asteroidCount++;
            [self addAsteroids:self.asteroidCount];
        }
    }
    
    /*
     * Handle the ship colliding with an asteroid
     */
    
    if(((contact.bodyA.categoryBitMask & asteroidCategory) != 0 && (contact.bodyB.categoryBitMask & shipCategory) != 0)
       ||
       ((contact.bodyB.categoryBitMask & asteroidCategory) != 0 && (contact.bodyA.categoryBitMask & shipCategory) != 0)){
        NSLog(@"Ship crashed!");
        
        SKEShipExplosion* splody = [[SKEShipExplosion alloc] initDefault];
        splody.position = self.ship.position;
        [self addChild:splody];
        
        [self removeChildrenInArray:[NSArray arrayWithObject:self.ship]];
        self.ship = nil;
        
        
        // Create a new ship after a brief period
        self.lives -= 1;
        if(self.lives > 0){
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(createShip) userInfo:nil repeats:NO];
        } else {
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(displayGameOver) userInfo:nil repeats:NO];
        }
    }
}

/*
 * Show the Game Over scene
 */
- (void) displayGameOver {
    // Display game over
    SKScene * scene = [[SKEMenuScene alloc] initWithSize:self.view.bounds.size title:@"Game Over"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [self.view presentScene:scene];
}

/*
 * Add a ship to the scene
 */
- (void) createShip {
    
    self.ship = [[SKEShip alloc] initDefault];
    [self.ship setPosition:CGPointMake(self.size.width/2,self.size.height/2)];
    // Ensure the ship isn't going to be created where there are asteroids
    for(SKEAsteroid* a in self.asteroids){
        if([self.ship intersectsNode:a]){
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(createShip) userInfo:nil repeats:NO];
            self.ship = nil;
            return;
        }
    }
    [self addChild:self.ship];
}

/*
 * Add buttons to the scene and add actions for checking touches
 */
- (void) createButtons:(CGSize) size{

    SKColor* whiteTranslucent = [SKColor colorWithHue:0.0f saturation:0.0f brightness:1.0f alpha:0.5f];
    SKColor* grayTranslucent = [SKColor colorWithHue:0.0f saturation:0.0f brightness:0.5f alpha:0.5f];
    
    self.thrustButton = [[JCButton alloc] initWithButtonRadius:25 color:whiteTranslucent pressedColor:grayTranslucent isTurbo:NO isRapidFire:YES];
    [self.thrustButton setPosition:CGPointMake(size.width - 40,95)];
    self.thrustButton.zPosition = 100;
    [self addChild:self.thrustButton];

    
    self.leftButton = [[JCButton alloc] initWithButtonRadius:25 color:whiteTranslucent pressedColor:grayTranslucent isTurbo:NO isRapidFire:YES];
    [self.leftButton setPosition:CGPointMake(30,45)];
    self.leftButton.zPosition = 100;
    [self addChild:self.leftButton];

    
    self.rightButton = [[JCButton alloc] initWithButtonRadius:25 color:whiteTranslucent pressedColor:grayTranslucent isTurbo:NO isRapidFire:YES];
    [self.rightButton setPosition:CGPointMake(85,45)];
    self.rightButton.zPosition = 100;
    [self addChild:self.rightButton];
    
    self.fireButton = [[JCButton alloc] initWithButtonRadius:25 color:whiteTranslucent pressedColor:grayTranslucent isTurbo:NO isRapidFire:YES];
    [self.fireButton setPosition:CGPointMake(size.width - 70,45)];
    self.fireButton.zPosition = 100;
    [self addChild:self.fireButton];
    
    //scheduling the action to check movement buttons
    SKAction *movementWait = [SKAction waitForDuration:0.1f];
    SKAction *checkMovementButtons = [SKAction runBlock:^{
        [self handleMovement];
    }];
    
    SKAction *checkMovementButtonsAction = [SKAction sequence:@[movementWait,checkMovementButtons]];
    [self runAction:[SKAction repeatActionForever:checkMovementButtonsAction]];
    
    //scheduling the action to check firing buttons
    SKAction *firingWait = [SKAction waitForDuration:0.3f];
    SKAction *checkFiringButtons = [SKAction runBlock:^{
        [self handleFiring];
    }];
    
    SKAction *checkFiringButtonsAction = [SKAction sequence:@[firingWait,checkFiringButtons]];
    [self runAction:[SKAction repeatActionForever:checkFiringButtonsAction]];
}

- (CGVector)convertAngleToVector:(CGFloat)radians {
    CGVector vector;
    vector.dx = cos(radians+1.57079633f) * 10;
    vector.dy = sin(radians+1.57079633f) * 10;
    return vector;
}

- (void) fireMissile {
    
    CGVector shipDirection = [self convertAngleToVector:self.ship.zRotation];
    
    CGPoint mPos = CGPointMake(self.ship.position.x + shipDirection.dx,
                self.ship.position.y + shipDirection.dy);

    SKEMissile* missile = [[SKEMissile alloc] initWithPosition:mPos andDirection:shipDirection];

    [self addChild:missile];

}

/*
 * Process movement related button presses
 */
- (void) handleMovement {
    if(self.ship != nil){
        if (self.thrustButton.wasPressed) {
            [self.ship.physicsBody applyImpulse:
             CGVectorMultiplyByScalar([self convertAngleToVector:self.ship.zRotation],0.1f)];
        }
        
        if (self.leftButton.wasPressed) {
            SKAction *action = [SKAction rotateByAngle:0.2 duration:0.1];
            [self.ship runAction:[SKAction repeatAction:action count:1]];
        }
        
        if (self.rightButton.wasPressed) {
            SKAction *action = [SKAction rotateByAngle:-0.2 duration:0.1];
            [self.ship runAction:[SKAction repeatAction:action count:1]];
        }
    }

}

/*
 * Process firing-related button presses
 */
- (void)handleFiring
{
    if(self.ship != nil){
        if(self.fireButton.wasPressed){
            [self fireMissile];
        }
    }
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // Update the score on screen
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
    self.livesLabel.text = [NSString stringWithFormat:@"%d", self.lives];
    self.highScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[SKEPersistent getHighScore]];

}

@end
