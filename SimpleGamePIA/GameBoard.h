//
//  GameBoard.h
//  SimpleGamePIA
//
//  Created by Christian Wiedel on 03/07/14.
//  Copyright (c) 2014 Christian Wiedel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, gameState){
    gameNotStarted,
    gameOngoing,
    gameVictory,
    gameDraw
};


@interface GameBoard : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end
