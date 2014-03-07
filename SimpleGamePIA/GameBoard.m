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
@property (nonatomic, strong) UILabel *currentPlayerLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *indexPathArray;

@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define PLAYER_ONE 1
#define PLAYER_TWO 2
#define UNUSED_CELL 0
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
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, 290, 290) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    self.collectionView.center = self.view.center;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    
    [self.view addSubview:self.collectionView];
    
    self.currentPlayer = PLAYER_ONE;
    
    self.currentPlayerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, 200, 44)];
    [self.currentPlayerLabel setText:@"Current player:"];
    [self.currentPlayerLabel setTextAlignment:NSTextAlignmentCenter];
    self.currentPlayerLabel.center = CGPointMake(self.view.center.x, self.currentPlayerLabel.center.y);
    [self.view addSubview:self.currentPlayerLabel];
    
    self.indexPathArray = [[NSMutableArray alloc]init];
    
    
    [super viewDidLoad];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NUMBER OF ITEMS IN SECTION
    return NUMBER_OF_COLUMNS;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //SECTIONS
    return NUMBER_OF_ROWS;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [GameBoard unusedTileColor];
    
    // Add each cell's index path to the indexPath array
    [self.indexPathArray addObject:indexPath];
    
    NSLog(@"cell tag: %i",cell.tag);
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(27, 27);
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
            if(cell.tag == UNUSED_CELL) {
                [cell setBackgroundColor:[GameBoard playerOneColor]];
                [cell setTag: PLAYER_ONE];
                self.currentPlayer = PLAYER_TWO;
                [self.currentPlayerLabel setText:@"Player TWO"];
                [self checkIfPlayerWon];
            }
            break;
        case PLAYER_TWO:
            if(cell.tag == UNUSED_CELL) {
                [cell setBackgroundColor:[GameBoard playerTwoColor]];
                [cell setTag: PLAYER_TWO];
                self.currentPlayer = PLAYER_ONE;
                [self.currentPlayerLabel setText:@"Player ONE"];
                [self checkIfPlayerWon];
            }
            break;
        default:
            break;
    }
   
    
    //NSLog(@"touched cell %@ at indexPath %@", cell, indexPath);
}
-(int)getTagForCellAtIndexPath:(int) column atRow:(int) row {
    
    NSIndexPath *cellTagtoFetch = [NSIndexPath indexPathForRow:row inSection:column];

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:cellTagtoFetch];
    
    return cell.tag;
}

-(BOOL)checkIfPlayerWon {
    
    //VERTICALLY
    for(int column = 0; column < NUMBER_OF_COLUMNS; column++) {
        int consecutiveCells = 0;
        for(int row = 0; row < NUMBER_OF_ROWS; row++) {
            int tag = [self getTagForCellAtIndexPath: column atRow:row];
            if(tag == self.currentPlayer) {
                consecutiveCells++;
                NSLog(@"cons cells: %i", consecutiveCells);
                NSLog(@"cell tag: %i", tag);
            }else {
                consecutiveCells = 0;
            }
            
            if(consecutiveCells >= 5){
                NSLog(@"SOMEONE WON VERTICALLY");
                return true;
            }
        }
    }
    
    //HORIZONTALLY
    for(int column = 0; column < NUMBER_OF_COLUMNS; column++) {
        int consecutiveCells = 0;
        for(int row = 0; row < NUMBER_OF_ROWS; row++) {
            int tag = [self getTagForCellAtIndexPath: row atRow:column];
            if(tag == self.currentPlayer) {
                consecutiveCells++;
                NSLog(@"cons cells: %i", consecutiveCells);
                NSLog(@"cell tag: %i", tag);
            }else {
                consecutiveCells = 0;
            }
            
            if(consecutiveCells >= 5){
                NSLog(@"SOMEONE WON HORIZONTALLY");
                return true;
            }
        }
    }
    
    
    return false;
    
//    NSLog(@"touched cell at indexPath %@", indexPath);
//    NSLog(@"touched cell at row: %i, section: %i", indexPath.row, indexPath.section);
//    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//    
//    NSLog(@"%@", self.indexPathArray);
    
//    int count = self.collectionView.subviews.count;
//    NSLog(@"subviews: %i", count);
//    
//    for(int i = 0; i < count; i++)
//    {
//        UICollectionViewCell *cell = self.collectionView.subviews[i];
//        NSLog(@"cell tag: %i",cell.tag);
//
//    }
}



@end
