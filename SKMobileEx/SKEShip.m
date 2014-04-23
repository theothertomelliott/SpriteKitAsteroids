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
        CGSize size = self.size;
        size.height = 20;
        size.width = 20;
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
        
        if(SHOW_DIRECTION){
            CGVector thrustDirection =  CGVectorMake(0.0f, 100.0f);
        
            CGPathAddLineToPoint(pathToDraw, NULL, thrustDirection.dx, thrustDirection.dy);
            self.shipDirection.path = pathToDraw;
            [self.shipDirection setStrokeColor:[SKColor redColor]];
            [self addChild:self.shipDirection];
        }

    }
    return self;
}

@end
