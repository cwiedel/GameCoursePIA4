//
//  GameBoard+Colors.m
//  SimpleGamePIA
//
//  Created by Christian Wiedel on 03/07/14.
//  Copyright (c) 2014 Christian Wiedel. All rights reserved.
//

#import "GameBoard+Colors.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation GameBoard (Colors)

+(UIColor *) playerOneColor {
    return UIColorFromRGB(0x3a96d1);
}

+(UIColor *) playerTwoColor {
    return UIColorFromRGB(0xFF2D55);
}

+(UIColor *) unusedTileColor {
    return UIColorFromRGB(0xF3F3F3);
}

+(UIColor *) labelColor {
    return UIColorFromRGB(0x1F1F21);
}

@end
