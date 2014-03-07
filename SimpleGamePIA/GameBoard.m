//
//  GameBoard.m
//  SimpleGamePIA
//
//  Created by Christian Wiedel on 03/07/14.
//  Copyright (c) 2014 Christian Wiedel. All rights reserved.
//

#import "GameBoard.h"
#import "GameBoard+Colors.h"

@interface GameBoard ()

@property int currentPlayer;

@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define PLAYER_ONE 1
#define PLAYER_TWO 2
#define NUMBER_OF_ROWS 10
#define NUMBER_OF_COLUMNS 10

@implementation GameBoard

- (void)viewDidLoad
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [layout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    layout.minimumInteritemSpacing = 0.5f;
    layout.minimumLineSpacing = 0.5f;
    
    UICollectionView *collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, 280, 280) collectionViewLayout:layout];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    collectionView.center = self.view.center;
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    
    [self.view addSubview:collectionView];
    
    self.currentPlayer = PLAYER_ONE;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return NUMBER_OF_COLUMNS;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return NUMBER_OF_ROWS;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [GameBoard unusedTileColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(26, 26);
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
     return UIEdgeInsetsMake(0, 1, 0, 1);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    switch (self.currentPlayer) {
        case PLAYER_ONE:
            [cell setBackgroundColor:[GameBoard playerOneColor]];
            self.currentPlayer = PLAYER_TWO;
            break;
        case PLAYER_TWO:
            [cell setBackgroundColor:[GameBoard playerTwoColor]];
            self.currentPlayer = PLAYER_ONE;
            break;
        default:
            break;
    }
    
    NSLog(@"touched cell %@ at indexPath %@", cell, indexPath);

}

@end
