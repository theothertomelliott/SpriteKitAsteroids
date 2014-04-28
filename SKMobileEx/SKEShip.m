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
    if((self = [super init]))
    {
        
        self.size = CGSizeMake(20, 20);
        
        // Create a path for a triangle pointing upwards
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, -(self.size.width/2), 0-(self.size.height/2));
        CGPathAddLineToPoint(pathToDraw, NULL, 0.0f, (self.size.height/2));
        CGPathAddLineToPoint(pathToDraw, NULL, (self.size.width/2), -(self.size.height/2));
        
        // Apply the path
        self.path = pathToDraw;
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        
        self.physicsBody.categoryBitMask = shipCategory | wraparoundCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = asteroidCategory;
        
        self.shipDirection = [SKShapeNode node];
        
        if(SHOW_DIRECTION){
            CGMutablePathRef pathToDraw = CGPathCreateMutable();
            //self.shipDirection.position = self.position;
            CGPathMoveToPoint(pathToDraw, NULL, 0.0f, 0.0f);
            
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
