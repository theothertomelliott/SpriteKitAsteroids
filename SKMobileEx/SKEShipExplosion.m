//
//  SKEShipExplosion.m
//  SKEAsteroids
//
//  Created by Tom Elliott on 29/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEShipExplosion.h"

@implementation SKEShipExplosion

-(id)initDefault {
    if((self = [super init]))
    {
        
        self.size = CGSizeMake(20, 20);
        
        CGMutablePathRef circlePath = CGPathCreateMutable();
        CGPathAddEllipseInRect(circlePath , NULL , CGRectMake(-self.size.width/2, -self.size.height/2, self.size.width, self.size.height) );
        self.path = circlePath;
        
        [self setFillColor:[SKColor redColor]];
        
        //scheduling the action to check firing buttons
        SKAction *firingWait = [SKAction waitForDuration:0.01f];
        SKAction *checkFiringButtons = [SKAction runBlock:^{
            [self reDraw];
        }];
        
        SKAction *checkFiringButtonsAction = [SKAction sequence:@[firingWait,checkFiringButtons]];
        [self runAction:[SKAction repeatActionForever:checkFiringButtonsAction]];
        
    }
    return self;
}

-(void)reDraw {
    self.size = CGSizeMake(self.size.width+1, self.size.height+1);
    
    if(self.size.width < 50){
    
        CGMutablePathRef circlePath = CGPathCreateMutable();
        CGPathAddEllipseInRect(circlePath , NULL , CGRectMake(-self.size.width/2, -self.size.height/2, self.size.width, self.size.height) );
        self.path = circlePath;
    } else {
        self.path = nil;
    }
}

@end
