//
//  Splash.m
//  SimpleGamePIA
//
//  Created by Christian Wiedel on 12/03/14.
//  Copyright (c) 2014 Christian Wiedel. All rights reserved.
//

#import "Splash.h"
#import "GameBoard+Colors.h"

@implementation Splash

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}


-(void)setupUI
{
    UIFont *smallFont = [UIFont fontWithName: @"HelveticaNeue-Light" size:22];
    
    UITextField *textView = [[UITextField alloc]initWithFrame:CGRectMake(0, 60, 280, 80)];
    textView.center = CGPointMake(self.center.x, textView.center.y);
    
    [textView setPlaceholder:@"Hi! Enter your user name"];
    [textView setTextAlignment:NSTextAlignmentCenter];
    textView.layer.borderWidth = 0.5f;
    [self addSubview:textView];
    
    UIButton *startResetButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 150, 280, 50)];
    [startResetButton setTitle:@"GO" forState:UIControlStateNormal];
    [startResetButton.titleLabel setFont:smallFont];
    [startResetButton setBackgroundColor:[GameBoard playerOneColor]];
    startResetButton.center = CGPointMake(self.center.x, startResetButton.center.y);
    [startResetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:startResetButton];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
