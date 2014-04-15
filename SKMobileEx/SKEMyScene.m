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
        
        self.score = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        self.score.text = @"00000";
        self.score.fontSize = 24;
        self.score.position = CGPointMake(self.frame.size.width - 100,
                                          self.frame.size.height - 20);
        
        [self addChild:self.score];
         
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = worldCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = asteroidCategory | shipCategory;
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
 
        [self addAsteroids];
        
        [self createShip];
        
        [self createButtons:size];
         
        //scheduling the action to check buttons
        SKAction *wait = [SKAction waitForDuration:0.3f];
        SKAction *checkButtons = [SKAction runBlock:^{
            [self checkButtons];
        }];
        
        SKAction *checkButtonsAction = [SKAction sequence:@[wait,checkButtons]];
        [self runAction:[SKAction repeatActionForever:checkButtonsAction]];
       
    }
    return self;
}

- (void) addAsteroids {
    
    for(int i = 0; i < 3; i++){
        
        CGPoint pos = CGPointMake(arc4random_uniform(self.size.width), arc4random_uniform(self.size.height));
        CGVector impulse = CGVectorMake(arc4random_uniform(200)/100.0f, arc4random_uniform(200)/100.0f);
        
        NSLog(@"Asteroid Position: (%0.2f,%0.2f)",pos.x,pos.y);
        NSLog(@"Asteroid impulse: (%0.2f,%0.2f)",impulse.dx,impulse.dy);
        
        SKEAsteroid* asteroid = [[SKEAsteroid alloc] initWithRadius:40.0f andPosition:pos];
        [self addChild:asteroid];
        [asteroid.physicsBody applyImpulse:impulse];
        
    }
    
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    NSLog(@"Collision");
    
    if ((contact.bodyA.categoryBitMask == worldCategory)
        && (contact.bodyB.categoryBitMask == shipCategory))
    {
        CGPoint contactPoint = contact.contactPoint;
        NSLog(@"Contact at %0.2f,%0.2f",contactPoint.x, contactPoint.y);
        
        SKPhysicsBody *tempPhysicsBody = self.ship.physicsBody;
        self.ship.physicsBody = nil;
        // Position and re-add physics body
        [self.ship setPosition:CGPointMake(60.0f, 60.0f)];
        self.ship.physicsBody = tempPhysicsBody;
        
        NSLog(@"Moved ship");
    }
    
    if((contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == missileCategory)
    || (contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == missileCategory)){
        NSLog(@"Hit asteroid!");
        
        SKEAsteroid* shotAsteroid = (SKEAsteroid*)  (contact.bodyA.categoryBitMask == asteroidCategory ? contact.bodyA.node : contact.bodyB.node);
        
        if(shotAsteroid.radius > 10){
            
            SKEMissile* missile = (SKEMissile*)  (contact.bodyA.categoryBitMask == missileCategory ? contact.bodyA.node : contact.bodyB.node);

            CGVector mDirection = missile.direction;
            CGVector mPerp = CGVectorMakePerpendicular(mDirection);
            
            CGFloat fragmentDist = shotAsteroid.radius - shotAsteroid.radius/2;
            
            CGPoint position1 = CGPointMake(shotAsteroid.position.x + mPerp.dx*fragmentDist, shotAsteroid.position.y + mPerp.dy*fragmentDist);
            CGPoint position2 = CGPointMake(shotAsteroid.position.x - mPerp.dx*fragmentDist, shotAsteroid.position.y - mPerp.dy*fragmentDist);
            
            CGVector mImpulse1 = CGVectorMultiplyByScalar(mPerp, 2.0f);
            CGVector mImpulse2 = CGVectorMultiplyByScalar(mPerp, -2.0f);
            
            NSLog(@"mImpulse1: (%0.2f,%0.2f)", mImpulse1.dx, mImpulse1.dy);
            NSLog(@"mImpulse2: (%0.2f,%0.2f)", mImpulse2.dx, mImpulse2.dy);
            
            SKEAsteroid* asteroid = [[SKEAsteroid alloc] initWithRadius:shotAsteroid.radius/2 andPosition:position1];
            [self addChild:asteroid];
            [asteroid.physicsBody applyImpulse:mImpulse1];
            
            asteroid = [[SKEAsteroid alloc] initWithRadius:shotAsteroid.radius/2 andPosition:position2];
            [self addChild:asteroid];
            [asteroid.physicsBody applyImpulse:mImpulse2];
        }
        
        // Remove the nodes in question
        [self removeChildrenInArray:[NSArray arrayWithObjects:contact.bodyA.node,contact.bodyB.node,nil]];
        
        // TODO: When there are no asteroids left, create some new big ones
    }
    
    if((contact.bodyA.categoryBitMask == asteroidCategory && contact.bodyB.categoryBitMask == shipCategory)
       || (contact.bodyB.categoryBitMask == asteroidCategory && contact.bodyA.categoryBitMask == shipCategory)){
        NSLog(@"Ship crashed!");
        [self removeChildrenInArray:[NSArray arrayWithObject:self.ship]];
        
        // TODO: Create a new ship after a brief period, or show game over if no more lives
    }
}

- (void) createShip {
    self.ship = [[SKEShip alloc] initDefault];
    [self.ship setPosition:CGPointMake(self.size.width/2,self.size.height/2)];
    [self addChild:self.ship];
}

- (void)didSimulatePhysics
{
}


- (void) createButtons:(CGSize) size{

    self.thrustButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor greenColor] pressedColor:[SKColor blackColor] isTurbo:NO];
    [self.thrustButton setPosition:CGPointMake(size.width - 40,95)];
    [self addChild:self.thrustButton];

    
    self.leftButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO];
    [self.leftButton setPosition:CGPointMake(20,45)];
    [self addChild:self.leftButton];

    
    self.rightButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO];
    [self.rightButton setPosition:CGPointMake(75,45)];
    [self addChild:self.rightButton];
    
    self.fireButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO];
    [self.fireButton setPosition:CGPointMake(size.width - 70,45)];
    [self addChild:self.fireButton];
    
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

- (void)checkButtons
{
    
    if (self.thrustButton.wasPressed) {
        [self.ship.physicsBody applyImpulse:
         CGVectorMultiplyByScalar([self convertAngleToVector:self.ship.zRotation],0.5f)];
    }
    
    if (self.leftButton.wasPressed) {
        SKAction *action = [SKAction rotateByAngle:0.5 duration:0.3];
        [self.ship runAction:[SKAction repeatAction:action count:1]];
    }
    
    if (self.rightButton.wasPressed) {
        SKAction *action = [SKAction rotateByAngle:-0.5 duration:0.3];
        [self.ship runAction:[SKAction repeatAction:action count:1]];
    }
    
    if(self.fireButton.wasPressed){
        [self fireMissile];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
