//
//  SKEPersistent.m
//  SKEAsteroids
//  Class to handle persisting data between games.
//
//  Created by Tom Elliott on 01/05/2014.
//  Copyright (c) 2014 Tom Elliott. All rights reserved.
//

#import "SKEPersistent.h"

#define kHighScoreKey @"HighScore"

@implementation SKEPersistent


+ (NSInteger) getHighScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs integerForKey:kHighScoreKey];
}

+ (BOOL) updateHighScore:(int) score{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if(score <= [prefs integerForKey:kHighScoreKey]){
        return false;
    } else {
        [prefs setInteger:score  forKey:kHighScoreKey];
        [prefs synchronize];
        return true;
    }
}

@end
