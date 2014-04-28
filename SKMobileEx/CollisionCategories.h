//
//  CollisionCategories.h
//  SKMobileEx
//
//  Created by Tom Elliott on 13/04/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#ifndef SKMobileEx_CollisionCategories_h
#define SKMobileEx_CollisionCategories_h

static const uint32_t missileCategory = 0x1 << 0;
static const uint32_t shipCategory = 0x1 << 1;
static const uint32_t asteroidCategory = 0x1 << 2;

static const uint32_t wraparoundCategory = 0x1 << 3; // Objects that wraparound

// World boundary borders
static const uint32_t borderTop = 0x1 << 4;
static const uint32_t borderBottom = 0x1 << 5;
static const uint32_t borderLeft = 0x1 << 6;
static const uint32_t borderRight = 0x1 << 7;


#endif
