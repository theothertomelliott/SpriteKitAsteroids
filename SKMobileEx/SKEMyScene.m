//
//  SKEMyScene.m
//  SKMobileEx
//
//  Created by Tom Elliott on 07/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEMyScene.h"

@implementation SKEMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        
        [self addChild:myLabel];
        
        [self createButtons:size];
         
        //scheduling the action to check buttons
        SKAction *wait = [SKAction waitForDuration:0.1];
        SKAction *checkButtons = [SKAction runBlock:^{
            [self checkButtons];
        }];
        
        SKAction *checkButtonsAction = [SKAction sequence:@[wait,checkButtons]];
        [self runAction:[SKAction repeatActionForever:checkButtonsAction]];
        
        self.ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        self.ship.position = CGPointMake(0.0f,0.0f);
        
        CGSize size = self.ship.size;
        size.height = size.height/4;
        size.width = size.width/4;
        [self.ship setSize:size];
        self.ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ship.frame.size.width/2];
        self.ship.physicsBody.restitution = 1.0f;
        self.ship.physicsBody.linearDamping = 0.0f;
        self.ship.physicsBody.allowsRotation = NO;
        self.ship.physicsBody.velocity = CGVectorMake(20.0f, 20.0f);
        
        [self addChild:self.ship];

        self.shipDirection = [SKShapeNode node];
        [self addChild:self.shipDirection];

    }
    return self;
}

- (void) updateLine {
    
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    self.shipDirection.position = self.ship.position;
    CGPathMoveToPoint(pathToDraw, NULL, 0.0f, 0.0f);
    
    CGVector thrustDirection = [self multiplyVector:[self convertAngleToVector:self.ship.zRotation] by:10.0f];
    
    CGPathAddLineToPoint(pathToDraw, NULL, thrustDirection.dx, thrustDirection.dy);
    self.shipDirection.path = pathToDraw;
    [self.shipDirection setStrokeColor:[SKColor redColor]];
    
}

- (void)didSimulatePhysics

{
    [self updateLine];
}

- (void) createButtons:(CGSize) size{

    self.thrustButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor greenColor] pressedColor:[SKColor blackColor] isTurbo:YES];
    [self.thrustButton setPosition:CGPointMake(size.width - 40,95)];
    [self addChild:self.thrustButton];

    
    self.leftButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:YES];
    [self.leftButton setPosition:CGPointMake(20,45)];
    [self addChild:self.leftButton];

    
    self.rightButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:YES];
    [self.rightButton setPosition:CGPointMake(75,45)];
    [self addChild:self.rightButton];
    
    self.fireButton = [[JCButton alloc] initWithButtonRadius:25 color:[SKColor redColor] pressedColor:[SKColor blackColor] isTurbo:NO];
    [self.fireButton setPosition:CGPointMake(size.width - 70,45)];
    [self addChild:self.fireButton];
    
}

// NEW, SWAPPED DX & DY
- (CGVector)convertAngleToVector:(CGFloat)radians {
    CGVector vector;
    vector.dx = cos(radians+1.57079633f) * 10;
    vector.dy = sin(radians+1.57079633f) * 10;
    NSLog(@"DX: %0.2f DY: %0.2f", vector.dx, vector.dy);
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
        
        [self addChild:missile];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
