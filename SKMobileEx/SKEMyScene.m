//
//  SKEMyScene.m
//  SKMobileEx
//
//  Created by Tom Elliott on 07/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEMyScene.h"
#import "SKEAsteroid.h"

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
    
    SKEAsteroid* asteroid = [[SKEAsteroid alloc] initDefault];
    asteroid.position = CGPointMake(30.0f, 30.0f);
    [self addChild:asteroid];
    
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

- (CGPoint) addPoint:(CGPoint)a toVector:(CGVector)b {
    CGPoint ov;
    ov.x = a.x + b.dx;
    ov.y = a.y + b.dy;
    return ov;
}

- (CGVector) multiplyVector:(CGVector) v by:(CGFloat)multiplier{
    CGVector v2;
    v2.dx = v.dx * multiplier;
    v2.dy = v.dy * multiplier;
    return v2;
}

- (void) fireMissile {
    
    CGVector shipDirection = [self convertAngleToVector:self.ship.zRotation];
    
    SKShapeNode* missile = [SKShapeNode node];
    
    missile.position = self.ship.position;
    missile.position = CGPointMake(missile.position.x + shipDirection.dx,
                                   missile.position.y + shipDirection.dy);
    
    SKAction *moveMissile = [SKAction moveBy:[self multiplyVector:shipDirection by:20.0f] duration:1];
    [missile runAction:[SKAction repeatActionForever:moveMissile]];
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, 0.0f, 0.0f);
    CGVector thrustDirection = [self convertAngleToVector:self.ship.zRotation];
    CGPathAddLineToPoint(pathToDraw, NULL, thrustDirection.dx, thrustDirection.dy);
    
    missile.path = pathToDraw;
    
    missile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1.0f];
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.physicsBody.categoryBitMask = missileCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.contactTestBitMask = asteroidCategory;
    
    [self addChild:missile];

}

- (void)checkButtons
{
    
    if (self.thrustButton.wasPressed) {
        //self.ship.physicsBody.velocity = CGVectorMake(100.0f, 100.0f);
        [self.ship.physicsBody applyImpulse:
         [self multiplyVector:[self convertAngleToVector:self.ship.zRotation] by:1.0f]];
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
