//
//  SKEPersistent.h
//  SKEAsteroids
//
//  Created by Tom Elliott on 01/05/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKEPersistent : NSObject

+ (NSInteger) getHighScore;
+ (BOOL) updateHighScore:(int) score;

@end
