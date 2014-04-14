//
//  SKEShip.h
//  SKMobileEx
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "CollisionCategories.h"

@interface SKEShip : SKSpriteNode

-(id)initDefault;

@property (strong, nonatomic) SKShapeNode* shipDirection;

@end