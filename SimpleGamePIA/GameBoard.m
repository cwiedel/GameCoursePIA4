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
#import "Splash.h"

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
@property (nonatomic) BOOL yourTurn;

@property (nonatomic) NSArray *gameBoard;
@property (nonatomic) NSString *gameId;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *opponentId;
@property (nonatomic) NSString *boardColumns;
@property (nonatomic) NSString *currPlayer;
@property (nonatomic) NSArray *players;

@property (nonatomic) NSDictionary *JSONResponse;

@property (nonatomic, strong) NSTimer *getJSONTimer;

@end

#define PLAYER_ONE 1
#define PLAYER_TWO 2
#define UNUSED_CELL 0
#define NUMBER_OF_ROWS 10
#define NUMBER_OF_COLUMNS 10

@implementation GameBoard

- (void)viewDidLoad
{

    [self setNeedsStatusBarAppearanceUpdate];
    
    self.currentPlayer = PLAYER_ONE;
    
    
    self.indexPathArray = [[NSMutableArray alloc]init];
    self.gameStateArray = [[NSMutableArray alloc]init];         // LOAD FROM API
    

    [self fillArrayWithEmptyCells];
    [self setupUI];
    
//    Splash *splashView = [[Splash alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:splashView];
    
    [super viewDidLoad];
}

-(void)fillArrayWithEmptyCells
{
    for(int i = 0; i<100; i++) {
        [self.gameStateArray addObject:[NSNumber numberWithInt:UNUSED_CELL]];
    }
}

-(void)setupUI {
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [layout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    layout.minimumInteritemSpacing = 0.5f;
    layout.minimumLineSpacing = 0.5f;
    
    float gridLength = 315.0f;
    float gridTopMargin = 68.0f;
    UIColor *labelColor = [GameBoard labelColor];
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, gridTopMargin, gridLength, gridLength) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    self.collectionView.center = CGPointMake(self.view.center.x, self.collectionView.center.y);
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320.0f, 64.0f)];
    [headerView setBackgroundColor:[GameBoard playerOneColor]];
    [self.view addSubview:headerView];
    
    UIFont *smallFont = [UIFont fontWithName: @"AvenirNextCondensed-Regular" size:22];
    
    self.currentPlayerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30.0f, 320.0f, 24)];
    [self.currentPlayerLabel setText:@"Five in a row"];
    [self.currentPlayerLabel setTextAlignment:NSTextAlignmentCenter];
    [self.currentPlayerLabel setTextColor:[UIColor whiteColor]];
    [self.currentPlayerLabel setFont:smallFont];
//    [self.currentPlayerLabel setBackgroundColor:[GameBoard playerOneColor]];
    self.currentPlayerLabel.center = CGPointMake(self.view.center.x, self.currentPlayerLabel.center.y);
    [self.view addSubview:self.currentPlayerLabel];
    
    
    self.startResetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, 200.0f, 50)];
    [self.startResetButton setTitle:@"Start Game" forState:UIControlStateNormal];
    [self.startResetButton.titleLabel setFont:smallFont];
    self.startResetButton.center = CGPointMake(self.view.center.x, self.startResetButton.center.y);
    [self.startResetButton setBackgroundColor:[GameBoard playerOneColor]];
    [self.startResetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startResetButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    self.startResetButton.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.startResetButton];

    // JSON TEST BUTTONS
/*
    self.JSONGetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 440, 100, 44)];
    [self.JSONGetButton setTitle:@"Get" forState:UIControlStateNormal];
    [self.JSONGetButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.JSONGetButton addTarget:self action:@selector(getJSON) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.JSONGetButton];
    
    self.JSONPostButton = [[UIButton alloc]initWithFrame:CGRectMake(80, 440, 100, 44)];
    [self.JSONPostButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.JSONPostButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.JSONPostButton addTarget:self action:@selector(postJSON) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.JSONPostButton];
    
    self.JSONPostWithIDButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 440, 100, 44)];
    [self.JSONPostWithIDButton setTitle:@"Post w ID" forState:UIControlStateNormal];
    [self.JSONPostWithIDButton setTitleColor:labelColor forState:UIControlStateNormal];
    [self.JSONPostWithIDButton addTarget:self action:@selector(postJSONWithID) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.JSONPostWithIDButton];
*/
 
}

-(void)startGame
{
    if(self.gameState == gameVictory){
        for(int i = 0; i<100; i++) {
            [self.gameStateArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:UNUSED_CELL]];
        }
        [self.collectionView reloadData];
    }
    
    self.gameState = gameOngoing;
    int randomUserId = arc4random() % 999999;
    self.userId = [NSString stringWithFormat:@"%i",randomUserId];
    
    NSLog(@"generated userID: %@",self.userId);
    self.yourTurn = YES;
    [self.currentPlayerLabel setText:@"New game!"];
    [self.startResetButton setTitle:@"Start New Game" forState:UIControlStateNormal];
    [self postJSON];
    
    self.getJSONTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getJSON) userInfo:nil repeats:YES];
}

#pragma mark Collection view functions

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(29.5, 29.5);
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 1, 0, 1);
}

#pragma mark Draw the cells

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    // Add each cell's index path to the indexPath array
    [self.indexPathArray addObject:indexPath];
    
    // match indexPath to gameStateArray and set color
    int arrayIndex = [self convertIndexPathToInt:indexPath];
//    NSLog(@"cellForItemAtIndexPath: %i ", arrayIndex);
    
    if([[self.gameStateArray objectAtIndex:arrayIndex] isEqualToNumber:[NSNumber numberWithInt:UNUSED_CELL]]){
        cell.backgroundColor = [GameBoard unusedTileColor];
        [cell setTag:UNUSED_CELL];
    }else if([[self.gameStateArray objectAtIndex:arrayIndex] isEqualToNumber:[NSNumber numberWithInt:PLAYER_ONE]]){
        cell.backgroundColor = [GameBoard playerOneColor];
        [cell setTag:PLAYER_ONE];
    }else if([[self.gameStateArray objectAtIndex:arrayIndex] isEqualToNumber:[NSNumber numberWithInt:PLAYER_TWO]]){
        cell.backgroundColor = [GameBoard playerTwoColor];
        [cell setTag:PLAYER_TWO];
    }
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if(self.gameState == gameOngoing && cell.tag == UNUSED_CELL && self.yourTurn){
        
        [cell setTag: self.currentPlayer];
        self.yourTurn = NO;
        [self.currentPlayerLabel setText:@"Waiting for opponent"];
        
        switch (self.currentPlayer) {
            case PLAYER_ONE:
                [cell setBackgroundColor:[GameBoard playerOneColor]];
                break;
            case PLAYER_TWO:
                [cell setBackgroundColor:[GameBoard playerTwoColor]];
            default:
                break;
        }
        
        int position = [self convertIndexPathToInt:indexPath];
        [self.gameStateArray replaceObjectAtIndex:position withObject:[NSNumber numberWithInt: self.currentPlayer]];
        [self postJSONWithID];
        NSLog(@"Clicked cell at position: %i", position);
        if([self checkGameStateForWinner:self.currentPlayer]){
            [self.currentPlayerLabel setText:@"You won!"];
            [self.getJSONTimer invalidate];
        }
     }
}

-(int)getTagForCellAtIndexPath:(int) column atRow:(int) row
{
    NSIndexPath *cellTagtoFetch = [NSIndexPath indexPathForRow:row inSection:column];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:cellTagtoFetch];
    return cell.tag;
}

-(int)convertIndexPathToInt:(NSIndexPath*) indexPath
{
    int tens = indexPath.row * 10;
    int ones = indexPath.section;
    int arrayInt = tens + ones;
//    NSLog(@"arrayInt: %i", arrayInt );
    return arrayInt;
}


-(BOOL)checkIfWinner: (int) player atIndex:(int) index atOffset:(int)offset atCount:(int)count
{
//    NSLog(@"checkIfWinner player: %i, atIndex: %i, atOffset: %i, atCount: %i",player, index, offset, count);
//    NSLog(@"foo: %@", [self.gameStateArray objectAtIndex:index]);
    if([self.gameStateArray objectAtIndex:index] == [NSNumber numberWithInt:player]){
        count++;
//        NSLog(@"checkIfWinner count:%i",count);
        if(count >= 5){
            NSLog(@"checkIfWinner true");
            return true;
        }
        
        if( (index + 1) % NUMBER_OF_COLUMNS == 0 &&
           (offset == 1 || offset == (NUMBER_OF_COLUMNS + 1)) ) {
            return false;
        }
        else if(index+offset >= self.gameStateArray.count){
            return false;
        }
        else {
            return [self checkIfWinner:player atIndex:index+offset atOffset:offset atCount:count];
        }
    }
    
    return false;
}

-(BOOL)checkGameStateForWinner: (int) player
{
    for(int id = 0; id < (NUMBER_OF_COLUMNS * NUMBER_OF_ROWS); id++){
        
        if([self checkIfWinner:player atIndex:id atOffset:1 atCount:0]){
            NSLog(@"checkGameStateForWinner true");
            self.gameState = gameVictory;
            return true;
        }else if([self checkIfWinner:player atIndex:id atOffset:NUMBER_OF_COLUMNS-1 atCount:0]){
            NSLog(@"checkGameStateForWinner true");
            self.gameState = gameVictory;
            return true;
        }else if([self checkIfWinner:player atIndex:id atOffset:NUMBER_OF_COLUMNS atCount:0]){
            NSLog(@"checkGameStateForWinner true");
            self.gameState = gameVictory;
            return true;
        }else if([self checkIfWinner:player atIndex:id atOffset:NUMBER_OF_COLUMNS+1 atCount:0]){
            NSLog(@"checkGameStateForWinner true");
            self.gameState = gameVictory;
            return true;
        }
    }
    
    return false;
}


/*
-(BOOL)checkIfPlayerWon {
    
    //VERTICALLY
    for(int column = 0; column < NUMBER_OF_COLUMNS; column++) {
        int consecutiveCellsPlayerOne = 0;
        int consecutiveCellsPlayerTwo = 0;
        for(int row = 0; row < NUMBER_OF_ROWS; row++) {
            int tag = [self getTagForCellAtIndexPath: column atRow:row];
            if(tag == PLAYER_ONE) {
                consecutiveCellsPlayerOne++;
//                NSLog(@"cons cells: %i", consecutiveCellsPlayerOne);
            }else if(tag == PLAYER_TWO ) {
                consecutiveCellsPlayerTwo++;
//                NSLog(@"cons cells: %i", consecutiveCellsPlayerOne);
            }else {
                consecutiveCellsPlayerOne = 0;
                consecutiveCellsPlayerTwo = 0;
            }
            
            if(consecutiveCellsPlayerOne >= 5){
//                NSLog(@"PLAYER ONE WON");
                [self.currentPlayerLabel setText:@"PLAYER ONE WON!"];
                self.gameState = gameVictory;
                [self.getJSONTimer invalidate];
                return true;
            }else if(consecutiveCellsPlayerTwo >= 5){
//                NSLog(@"PLAYER TWO WON");
                [self.currentPlayerLabel setText:@"PLAYER TWO WON!"];
                self.gameState = gameVictory;
                [self.getJSONTimer invalidate];
                return true;
            }
        }
    }
    
    //HORIZONTALLY
    for(int column = 0; column < NUMBER_OF_COLUMNS; column++) {
        int consecutiveCellsPlayerOne = 0;
        int consecutiveCellsPlayerTwo = 0;
        for(int row = 0; row < NUMBER_OF_ROWS; row++) {
            int tag = [self getTagForCellAtIndexPath: row atRow:column];
            if(tag == PLAYER_ONE) {
                consecutiveCellsPlayerOne++;
//                NSLog(@"cons cells: %i", consecutiveCellsPlayerOne);
            }else if(tag == PLAYER_TWO ) {
                consecutiveCellsPlayerTwo++;
//                NSLog(@"cons cells: %i", consecutiveCellsPlayerOne);
            }else {
                consecutiveCellsPlayerOne = 0;
                consecutiveCellsPlayerTwo = 0;
            }
            
            if(consecutiveCellsPlayerOne >= 5){
//                NSLog(@"PLAYER ONE WON");
                [self.currentPlayerLabel setText:@"PLAYER ONE WON!"];
                self.gameState = gameVictory;
                [self.getJSONTimer invalidate];
                return true;
            }else if(consecutiveCellsPlayerTwo >= 5){
//                NSLog(@"PLAYER TWO WON");
                [self.currentPlayerLabel setText:@"PLAYER TWO WON!"];
                self.gameState = gameVictory;
                [self.getJSONTimer invalidate];
                return true;
            }
        }
    }
    
    //DIAGONALLY
    for(int column = 0; column < NUMBER_OF_COLUMNS; column++) {
        int consecutiveCellsPlayerOne = 0;
        int consecutiveCellsPlayerTwo = 0;
        for(int row = 0; row < NUMBER_OF_ROWS; row++) {
            int tag = [self getTagForCellAtIndexPath: row atRow:row];
//            NSLog(@"diag row: %i, col: %i", row,row);
            if(tag == PLAYER_ONE) {
                consecutiveCellsPlayerOne++;
//                NSLog(@"cons cells diag p1: %i", consecutiveCellsPlayerOne);
            }else if(tag == PLAYER_TWO ) {
                consecutiveCellsPlayerTwo++;
//                NSLog(@"cons cells diag p2: %i", consecutiveCellsPlayerOne);
            }else {
                consecutiveCellsPlayerOne = 0;
                consecutiveCellsPlayerTwo = 0;
            }
            
            if(consecutiveCellsPlayerOne >= 5){
//                NSLog(@"PLAYER ONE WON");
                [self.currentPlayerLabel setText:@"PLAYER ONE WON!"];
                self.gameState = gameVictory;
                [self.getJSONTimer invalidate];
                return true;
            }else if(consecutiveCellsPlayerTwo >= 5){
//                NSLog(@"PLAYER TWO WON");
                [self.currentPlayerLabel setText:@"PLAYER TWO WON!"];
                self.gameState = gameVictory;
                [self.getJSONTimer invalidate];
                return true;
            }
        }
    }
    
    
    
    
    return false;
}
 */

#pragma mark JSON functions

- (void)getJSON
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    NSString *URLWithId = [NSString stringWithFormat:@"%@%@", BaseURLString, self.gameId];
    
//    NSLog(@"%@", URLWithId);
    
    [manager GET:URLWithId
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSLog(@"jsonTestGet: %@", responseObject);
             
             NSError *e;
             NSDictionary *JSONResp = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:NSJSONReadingMutableContainers error:&e];
             
             BOOL gameStateHasntChanged = [self.gameStateArray isEqualToArray:[JSONResp objectForKey:@"board"]];
             
             if(!gameStateHasntChanged){
                 self.gameStateArray = [JSONResp objectForKey:@"board"];
                 
                 int opponentID = 0;
                 if(self.currentPlayer == PLAYER_ONE){
                     opponentID = PLAYER_TWO;
                 }else if(self.currentPlayer == PLAYER_TWO){
                     opponentID = PLAYER_ONE;
                 }
                 
                 if(![self checkGameStateForWinner:opponentID]){
                    self.yourTurn = YES;
                    [self.currentPlayerLabel setText:@"Your turn"];
                 }else{
                     [self.currentPlayerLabel setText:@"Your opponent won!"];
                 }
                 [self.collectionView reloadData];
             }
         
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
//    [self checkGameStateForWinner:self.currentPlayer];
}


- (void)postJSON
{
    if(self.gameState == gameOngoing) {
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        //add game board array to params
        NSDictionary *parameters = @{@"id": self.userId,
                                     @"name": @"PLAYER ONE"};
        
        [manager POST:BaseURLString
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                  NSLog(@"jsonTestPost: %@", responseObject);
                  
                  NSError *e;
                  self.JSONResponse = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:NSJSONReadingMutableContainers error:&e];
                  [self parseJSONData];
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
              }];
    }
}

- (void)postJSONWithID
{
    if(self.gameState == gameOngoing) {
        
        NSDictionary *JSONToPost = [self getJSONDataToPost];
        NSData* data = [NSJSONSerialization dataWithJSONObject:JSONToPost
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
        
//        NSLog(@"Data: %@",aStr);
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    }
}

-(void)parseJSONData
{
    self.gameBoard = [self.JSONResponse objectForKey:@"board"];
    self.gameId = [self.JSONResponse objectForKey:@"id"];
    self.boardColumns = [self.JSONResponse objectForKey:@"boardColumns"];
    self.currPlayer = [self.JSONResponse objectForKey:@"currentPlayer"];
    self.players = [self.JSONResponse objectForKey:@"players"];
    
    switch (self.players.count) {
        case PLAYER_ONE:
            self.currentPlayer = PLAYER_ONE;
            [self.players[0] setObject:@"PLAYER ONE" forKey:@"name"];
            [self.players[0] setObject:self.userId forKey:@"id"];
            break;
        case PLAYER_TWO:
            self.currentPlayer = PLAYER_TWO;
            self.opponentId = [self.players[1] objectForKey:@"id"];
            [self.players[1] setObject:@"PLAYER TWO" forKey:@"name"];
            [self.players[1] setObject:self.opponentId forKey:@"id"];
            break;
        default:
            break;
    }
    
    
}

-(NSDictionary*)getJSONDataToPost
{
    NSDictionary *JSONToPost = @{@"board": self.gameStateArray,
                                 @"id": self.gameId,
                                 @"boardColumns": self.boardColumns,
                                 @"currentPlayer": self.userId,
                                 @"players":self.players
                                 };
    return JSONToPost;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
