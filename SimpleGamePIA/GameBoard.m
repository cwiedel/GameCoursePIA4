//
//  GameBoard.m
//  SimpleGamePIA
//
//  Created by Christian Wiedel on 03/07/14.
//  Copyright (c) 2014 Christian Wiedel. All rights reserved.
//

#import "GameBoard.h"
#import "GameBoard+Colors.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const BaseURLString = @"http://localhost:4730/game/";

@interface GameBoard ()

@property int currentPlayer;
@property (nonatomic, strong) UILabel *currentPlayerLabel;
@property (nonatomic, strong) UIButton *startResetButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *indexPathArray;
@property (nonatomic, strong) NSMutableArray *gameStateArray;


@property (nonatomic, strong) UIButton *JSONGetButton;
@property (nonatomic, strong) UIButton *JSONPostButton;

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
    self.currentPlayer = PLAYER_ONE;

    [self setupUI];
    
    self.indexPathArray = [[NSMutableArray alloc]init];
    self.gameStateArray = [[NSMutableArray alloc]init];         // LOAD FROM API

    [super viewDidLoad];
}

-(void)setupUI {
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [layout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    layout.minimumInteritemSpacing = 0.5f;
    layout.minimumLineSpacing = 0.5f;
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 84, 290, 290) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    self.collectionView.center = CGPointMake(self.view.center.x, self.collectionView.center.y);
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    
    [self.view addSubview:self.collectionView];
    
    self.currentPlayerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, 200, 44)];
    [self.currentPlayerLabel setText:@"Current player:"];
    [self.currentPlayerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.currentPlayerLabel setTextColor:[GameBoard labelColor]];
    self.currentPlayerLabel.center = CGPointMake(self.view.center.x, self.currentPlayerLabel.center.y);
    [self.view addSubview:self.currentPlayerLabel];
    
    self.startResetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, 200, 44)];
    [self.startResetButton setTitle:@"Start Game" forState:UIControlStateNormal];
    self.startResetButton.center = CGPointMake(self.view.center.x, self.startResetButton.center.y);
    [self.startResetButton setTitleColor:[GameBoard labelColor] forState:UIControlStateNormal];
    [self.view addSubview:self.startResetButton];
    
    self.JSONGetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 440, 100, 44)];
    [self.JSONGetButton setTitle:@"JSON Get" forState:UIControlStateNormal];
//    self.JSONGetButton.center = CGPointMake(self.view.center.x, self.JSONGetButton.center.y);
    [self.JSONGetButton setTitleColor:[GameBoard labelColor] forState:UIControlStateNormal];
    [self.view addSubview:self.JSONGetButton];
    [self.JSONGetButton addTarget:self action:@selector(jsonTestGet) forControlEvents:UIControlEventTouchUpInside];
    
    self.JSONPostButton = [[UIButton alloc]initWithFrame:CGRectMake(150, 440, 100, 44)];
    [self.JSONPostButton setTitle:@"JSON Post" forState:UIControlStateNormal];
//    self.JSONPostButton.center = CGPointMake(self.view.center.x, self.JSONPostButton.center.y);
    [self.JSONPostButton setTitleColor:[GameBoard labelColor] forState:UIControlStateNormal];
    [self.view addSubview:self.JSONPostButton];
    [self.JSONPostButton addTarget:self action:@selector(jsonTestPost) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    // add 0 to gamestate array
    [self.gameStateArray addObject:[NSNumber numberWithInt: UNUSED_CELL]];
    
//    NSLog(@"cell tag: %i",cell.tag);
    
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
                int position = [self convertIndexPathToInt:indexPath];
                [self.gameStateArray replaceObjectAtIndex:position withObject:[NSNumber numberWithInt: PLAYER_ONE]];
//                NSLog(@"foo: %@", self.gameStateArray[position]);
            }
            break;
        case PLAYER_TWO:
            if(cell.tag == UNUSED_CELL) {
                [cell setBackgroundColor:[GameBoard playerTwoColor]];
                [cell setTag: PLAYER_TWO];
                self.currentPlayer = PLAYER_ONE;
                [self.currentPlayerLabel setText:@"Player ONE"];
                [self checkIfPlayerWon];
                int position = [self convertIndexPathToInt:indexPath];
                [self.gameStateArray replaceObjectAtIndex:position withObject:[NSNumber numberWithInt: PLAYER_TWO]];
//                NSLog(@"foo: %@", self.gameStateArray[position]);
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

-(int)convertIndexPathToInt:(NSIndexPath*) indexPath
{
    int tens = indexPath.row * 10;
    int ones = indexPath.section;
    int arrayInt = tens + ones;
    NSLog(@"arrayInt: %i", arrayInt );
    return arrayInt;
}

-(BOOL)checkIfPlayerWon {
    
//    NSLog(@"%@",self.gameStateArray);
    
    //VERTICALLY
    for(int column = 0; column < NUMBER_OF_COLUMNS; column++) {
        int consecutiveCells = 0;
        for(int row = 0; row < NUMBER_OF_ROWS; row++) {
            int tag = [self getTagForCellAtIndexPath: column atRow:row];
            if(tag == self.currentPlayer) {
                consecutiveCells++;
                NSLog(@"cons cells: %i", consecutiveCells);
               // NSLog(@"cell tag: %i", tag);
            }else {
                consecutiveCells = 0;
            }
            
            if(consecutiveCells >= 5){
                NSLog(@"SOMEONE WON VERTICALLY");
                [self.currentPlayerLabel setText:@"SOMEONE WON!"];
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
//                NSLog(@"cons cells: %i", consecutiveCells);
                NSLog(@"cell tag: %i", tag);
            }else {
                consecutiveCells = 0;
            }
            
            if(consecutiveCells >= 5){
                NSLog(@"SOMEONE WON HORIZONTALLY");
                [self.currentPlayerLabel setText:@"SOMEONE WON!"];
                return true;
            }
        }
    }
    
    
    return false;
}


- (void)jsonTestGet
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:BaseURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)jsonTestPost
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"id": @"123456"};
    [manager POST:BaseURLString
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {

              NSError *e;
              NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:NSJSONReadingMutableContainers error:&e];
              
              NSLog(@"gamestate: %@", [jsonDict objectForKey:@"board"]);
              NSArray *gameState = [jsonDict objectForKey:@"board"];
              NSLog(@"gamestate length: %i",gameState.count);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
//    
}

/*
- (void)jsonTestPost
{
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:4730/game/123456"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        NSDictionary *json = (NSDictionary *)responseObject;
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    // 5
    [operation start];
}

*/

















@end
