//
//  SKEMyScene.m
//  SKMobileEx
//
//  Created by Tom Elliott on 07/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEMyScene.h"
#import "SKEAsteroid.h"
#import "SKEMissile.h"
#import "CGVectorAdditions.h"
#include <stdlib.h>

@implementation SKEMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Initializing scene");
        
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        self.scoreLabel.text = @"00000";
        self.scoreLabel.fontSize = 24;
        self.scoreLabel.position = CGPointMake(self.frame.size.width - 100,
                                          self.frame.size.height - 20);
        
        [self addChild:self.scoreLabel];
        
        [self createWorldBorder];
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        self.asteroids = [NSMutableArray array];
        self.asteroidCount = 1;
        
        [self addAsteroids:self.asteroidCount];
        
        [self createShip];
        
        [self createButtons:size];

    }
    return self;
}

/*
 * Add bodies on each edge of the scene to handle wraparound
 */
- (void) createWorldBorder {
    
    SKNode* topBorder = [SKNode node];
    topBorder.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0,self.size.height) toPoint:CGPointMake(self.size.width,self.size.height)];
    topBorder.physicsBody.usesPreciseCollisionDetection = YES;
    topBorder.physicsBody.categoryBitMask = borderTop;
    topBorder.physicsBody.collisionBitMask = 0;
    topBorder.physicsBody.contactTestBitMask = asteroidCategory | shipCategory;
    [self addChild:topBorder];

    SKNode* bottomBorder = [SKNode node];
    bottomBorder.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0.0f,0.0f) toPoint:CGPointMake(self.size.width,0.0f)];
    bottomBorder.physicsBody.usesPreciseCollisionDetection = YES;
    bottomBorder.physicsBody.categoryBitMask = borderBottom;
    bottomBorder.physicsBody.collisionBitMask = 0;
    bottomBorder.physicsBody.contactTestBitMask = asteroidCategory | shipCategory;
    [self addChild:bottomBorder];
    
    SKNode* leftBorder = [SKNode node];
    leftBorder.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0.0f,0.0f) toPoint:CGPointMake(0.0f,self.size.height)];
    leftBorder.physicsBody.usesPreciseCollisionDetection = YES;
    leftBorder.physicsBody.categoryBitMask = borderLeft;
    leftBorder.physicsBody.collisionBitMask = 0;
    leftBorder.physicsBody.contactTestBitMask = asteroidCategory | shipCategory;
    [self addChild:leftBorder];
    
    SKNode* rightBorder = [SKNode node];
    rightBorder.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(self.size.width,0.0f) toPoint:CGPointMake(self.size.width,self.size.height)];
    rightBorder.physicsBody.usesPreciseCollisionDetection = YES;
    rightBorder.physicsBody.categoryBitMask = borderRight;
    rightBorder.physicsBody.collisionBitMask = 0;
    rightBorder.physicsBody.contactTestBitMask = asteroidCategory | shipCategory;
    [self addChild:rightBorder];
    
    
}

/*
 * Add (count) asteroids to the scene
 */
- (void) addAsteroids: (int) count {
    
    for(int i = 0; i < count; i++){
        
        CGPoint pos = CGPointMake(arc4random_uniform(self.size.width), arc4random_uniform(self.size.height));
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
        // TODO: Show game over if no more lives
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(createShip) userInfo:nil repeats:NO];
    }
}

/*
 * Add a ship to the scene
 */
- (void) createShip {
    self.ship = [[SKEShip alloc] initDefault];
    [self.ship setPosition:CGPointMake(self.size.width/2,self.size.height/2)];
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
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
}

@end
