//
//  SKEShip.h
//  SKMobileEx
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "CollisionCategories.h"

#define SHOW_DIRECTION false

@interface SKEShip : SKShapeNode

-(id)initDefault;

@property (strong, nonatomic) SKShapeNode* shipDirection;
@property (nonatomic) CGSize size;

@end
