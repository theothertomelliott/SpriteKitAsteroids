//
//  SKEMyScene.m
//  SKMobileEx
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

@implementation SKEGameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Initializing scene");
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        self.scoreLabel.text = @"Score: 0";
        self.scoreLabel.fontSize = 16;
        self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        self.scoreLabel.position = CGPointMake(self.frame.size.width - 20,
                                          self.frame.size.height - 20);
        [self addChild:self.scoreLabel];
        
        self.livesLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        self.livesLabel.text = @"Lives: 0";
        self.livesLabel.fontSize = 16;
        self.livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.livesLabel.position = CGPointMake(20,
                                               self.frame.size.height - 20);
        
        [self addChild:self.livesLabel];
        
        [self createWorldBorder];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        self.asteroids = [NSMutableArray array];
        
        [self initGame];
        
        [self createShip];
        
        [self addAsteroids:self.asteroidCount];
        
        [self createButtons:size];

    }
    return self;
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
 * Create a border between the specified points to handle wraparound
 */
- (void) addBorderFromPoint:(CGPoint)from toPoint:(CGPoint) to withCategory:(int)category {
    
    SKNode* border = [SKNode node];
    border.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:from toPoint:to];
    border.physicsBody.usesPreciseCollisionDetection = YES;
    border.physicsBody.categoryBitMask = category;
    border.physicsBody.collisionBitMask = 0;
    border.physicsBody.contactTestBitMask = wraparoundCategory;
    [self addChild:border];
}

/*
 * Add bodies on each edge of the scene to handle wraparound
 */
- (void) createWorldBorder {
    [self addBorderFromPoint:CGPointMake(0,self.size.height) toPoint:CGPointMake(self.size.width,self.size.height) withCategory:borderTop];
    [self addBorderFromPoint:CGPointMake(0.0f,0.0f) toPoint:CGPointMake(self.size.width,0.0f) withCategory:borderBottom];
    [self addBorderFromPoint:CGPointMake(0.0f,0.0f) toPoint:CGPointMake(0.0f,self.size.height) withCategory:borderLeft];
    [self addBorderFromPoint:CGPointMake(self.size.width,0.0f) toPoint:CGPointMake(self.size.width,self.size.height) withCategory:borderRight];
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

/*
 * Handle contact between two entities
 */
- (void) didBeginContact:(SKPhysicsContact *)contact
{
    
    /*
     * Handle contact with an edge for wraparound behaviour
     */
    
    // Distance from the edge which a body should be re-introduced to the scene
    CGFloat distance = contact.bodyB.node.frame.size.width/2 + 5.0f;
    
    if(contact.bodyA.categoryBitMask == borderTop){
        NSLog(@"Collision with top");
        SKAction *moveBottom = [SKAction moveTo:CGPointMake(contact.bodyB.node.position.x, distance) duration:0.0f];
        [contact.bodyB.node runAction:moveBottom];
    }
    
    if(contact.bodyA.categoryBitMask == borderLeft){
        NSLog(@"Collision with left");
        SKAction *moveRight = [SKAction moveTo:CGPointMake(self.size.width-distance, contact.bodyB.node.position.y) duration:0.0f];
        [contact.bodyB.node runAction:moveRight];
    }
    
    if(contact.bodyA.categoryBitMask == borderRight){
        NSLog(@"Collision with right");
        SKAction *moveLeft = [SKAction moveTo:CGPointMake(distance, contact.bodyB.node.position.y) duration:0.0f];
        [contact.bodyB.node runAction:moveLeft];
    }
    
    if(contact.bodyA.categoryBitMask == borderBottom){
        NSLog(@"Collision with bottom");
        SKAction *moveTop = [SKAction moveTo:CGPointMake(contact.bodyB.node.position.x, self.size.height-distance) duration:0.0f];
        [contact.bodyB.node runAction:moveTop];
    }
    
    /*
     * Handle an asteroid being hit by a missile
     */
    
    if((contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == missileCategory)
    || (contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == missileCategory)){
        NSLog(@"Hit asteroid!");
        
        SKEAsteroid* shotAsteroid = (SKEAsteroid*)  (contact.bodyA.categoryBitMask == asteroidCategory ? contact.bodyA.node : contact.bodyB.node);
        
        self.score += shotAsteroid.score;
        
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
    
    if((contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == shipCategory)
       || (contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == shipCategory)){
        NSLog(@"Ship crashed!");
        [self removeChildrenInArray:[NSArray arrayWithObject:self.ship]];
        self.ship = nil;
        
        // Create a new ship after a brief period
        self.lives -= 1;
        if(self.lives > 0){
            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(createShip) userInfo:nil repeats:NO];
        } else {
            // Display game over
            SKScene * scene = [[SKEMenuScene alloc] initWithSize:self.view.bounds.size title:@"Game Over"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            // Present the scene.
            [self.view presentScene:scene];
        }
    }
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

    self.thrustButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor greenColor] pressedColor:[SKColor blackColor] isTurbo:NO isRapidFire:YES];
    [self.thrustButton setPosition:CGPointMake(size.width - 40,95)];
    [self addChild:self.thrustButton];

    
    self.leftButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO isRapidFire:YES];
    [self.leftButton setPosition:CGPointMake(20,45)];
    [self addChild:self.leftButton];

    
    self.rightButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO isRapidFire:YES];
    [self.rightButton setPosition:CGPointMake(75,45)];
    [self addChild:self.rightButton];
    
    self.fireButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO isRapidFire:YES];
    [self.fireButton setPosition:CGPointMake(size.width - 70,45)];
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
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.score];
    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d", self.lives];

}

@end
