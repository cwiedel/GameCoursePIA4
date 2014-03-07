//
//  GameBoard.m
//  SimpleGamePIA
//
//  Created by Christian Wiedel on 03/07/14.
//  Copyright (c) 2014 Christian Wiedel. All rights reserved.
//

#import "GameBoard.h"

@interface GameBoard ()

@end

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
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:collectionView];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 10;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor grayColor];
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
    
    [cell setBackgroundColor:[UIColor blueColor]];
    NSLog(@"touched cell %@ at indexPath %@", cell, indexPath);

}

@end
