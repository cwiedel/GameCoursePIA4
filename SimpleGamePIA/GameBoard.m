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
@property (nonatomic, strong) UIButton *JSONPostWithIDButton;

@property (nonatomic) gameState gameState;

@property (nonatomic) NSString *gameId;
@property (nonatomic) NSString *userId;

@property (nonatomic) NSDictionary *testResponseJSON;



@end

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
    
    float gridLength = 315.0f;
    float gridTopMargin = 64.0f;
    UIColor *labelColor = [GameBoard labelColor];
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, gridTopMargin, gridLength, gridLength) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    self.collectionView.center = CGPointMake(self.view.center.x, self.collectionView.center.y);
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
    
    self.currentPlayerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 200, 44)];
    [self.currentPlayerLabel setText:@"Current player:"];
    [self.currentPlayerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.currentPlayerLabel setTextColor:labelColor];
    self.currentPlayerLabel.center = CGPointMake(self.view.center.x, self.currentPlayerLabel.center.y);
    [self.view addSubview:self.currentPlayerLabel];
    
    self.startResetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, 200, 44)];
    [self.startResetButton setTitle:@"Start Game" forState:UIControlStateNormal];
    self.startResetButton.center = CGPointMake(self.view.center.x, self.startResetButton.center.y);
    [self.startResetButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.startResetButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startResetButton];
    

    // JSON TEST BUTTONS
    
    self.JSONGetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 440, 100, 44)];
    [self.JSONGetButton setTitle:@"Get" forState:UIControlStateNormal];
    [self.JSONGetButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.JSONGetButton addTarget:self action:@selector(jsonTestGet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.JSONGetButton];
    
    self.JSONPostButton = [[UIButton alloc]initWithFrame:CGRectMake(80, 440, 100, 44)];
    [self.JSONPostButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.JSONPostButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.JSONPostButton addTarget:self action:@selector(jsonTestPost) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.JSONPostButton];
    
    self.JSONPostWithIDButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 440, 100, 44)];
    [self.JSONPostWithIDButton setTitle:@"Post w ID" forState:UIControlStateNormal];
    [self.JSONPostWithIDButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.JSONPostWithIDButton addTarget:self action:@selector(jsonTestPostWithGameId) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.JSONPostWithIDButton];
    
}

-(void)startGame
{
    self.gameState = gameOngoing;
    int randomUserId = arc4random() % 999999;
    self.userId = [NSString stringWithFormat:@"%i",randomUserId];
    NSLog(@"generated userID: %@",self.userId);
    //CALL SERVER
    //DRAW BOARD FROM GAME BOARD ARRAY
    
    
    NSDictionary *testValidJson = @{@"board": self.gameStateArray};
    
    NSLog(@"testValidJson: %@", testValidJson);
    
    
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
    // match indexPath to gameStateArray and set color
    int arrayIndex = [self convertIndexPathToInt:indexPath];
    NSLog(@"cellForItemAtIndexPath: %i ", arrayIndex);
    [self.gameStateArray addObject:[NSNumber numberWithInt: UNUSED_CELL]];
    
//    NSLog(@"cell tag: %i",cell.tag);
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(29.5, 29.5);
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
                self.gameState = gameVictory;
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
                self.gameState = gameVictory;
                return true;
            }
        }
    }
    
    
    return false;
}


- (void)jsonTestGet
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    NSString *URLWithId = [NSString stringWithFormat:@"%@%@", BaseURLString, self.gameId];
    
    NSLog(@"%@", URLWithId);
    
    [manager GET:URLWithId parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"jsonTestGet: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)jsonTestPost
{
    
    //Post first to get a game id
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    //add game board array to params
    NSDictionary *parameters = @{@"id": self.userId,
                                 @"name": @"Christian"};
    

    [manager POST:@"http://localhost:4730/game/"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"jsonTestPost: %@", responseObject);

              NSError *e;
              self.testResponseJSON = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:NSJSONReadingMutableContainers error:&e];
              
              //NSLog(@"gamestate: %@", [jsonDict objectForKey:@"board"]);
              NSArray *gameState = [self.testResponseJSON objectForKey:@"board"];
              NSString *gameId = [self.testResponseJSON objectForKey:@"id"];
              self.gameId = gameId;
              NSString *currentPlayer = [self.testResponseJSON objectForKey:@"currentPlayer"];
              
              int foo = [currentPlayer intValue];
              
              NSLog(@"gameid: %@, currentPlayer: %@",gameId, currentPlayer);
              // rita upp spelet
             // NSLog(@"gamestate length: %lu",(unsigned long)gameState.count);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void)jsonTestPostWithGameId
{
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:self.testResponseJSON
                                                   options:NSJSONWritingPrettyPrinted error:Nil];
    NSString *URLWithId = [NSString stringWithFormat:@"%@%@", BaseURLString, self.gameId];
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URLWithId]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:[aStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"Data: %@",aStr);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];

  
     
}


@end
