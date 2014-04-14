//
//  SKEShip.m
//  SKMobileEx
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEShip.h"

@implementation SKEShip

-(id)initDefault {
    if((self = [super initWithImageNamed:@"Spaceship"]))
    {
        //self.position = CGPointMake(self.size.width/2,self.size.height/2);
        
        CGSize size = self.size;
        size.height = size.height/8;
        size.width = size.width/8;
        [self setSize:size];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width/2];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        
        self.physicsBody.categoryBitMask = shipCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = asteroidCategory;
        
        self.shipDirection = [SKShapeNode node];
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        //self.shipDirection.position = self.position;
        CGPathMoveToPoint(pathToDraw, NULL, 0.0f, 0.0f);
        
        CGVector thrustDirection =  CGVectorMake(0.0f, 100.0f);
        
        CGPathAddLineToPoint(pathToDraw, NULL, thrustDirection.dx, thrustDirection.dy);
        self.shipDirection.path = pathToDraw;
        [self.shipDirection setStrokeColor:[SKColor redColor]];
        [self addChild:self.shipDirection];

    }
    return self;
}

@end
