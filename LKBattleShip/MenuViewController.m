//
//  MenuViewController.m
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-01-15.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "MenuViewController.h"
#import "PvPViewController.h"
#import "PvAViewController.h"

#define kAnimateDur 0.5f

@interface MenuViewController () <UITextFieldDelegate>

@property (nonatomic, retain) UILabel *validNameLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *vsComputerBtn;
@property (nonatomic, strong) UIButton *vsPlayerBtn;

@property (nonatomic, assign) BOOL isHost;

@property (nonatomic, assign) BOOL isPlayWithComputer;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self play];
}

- (void)addBGImg {
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgImgView.image = [UIImage imageNamed:@"BG7201280.png"];
    [self.view  addSubview:bgImgView];
}


- (void)playWithComputer {
    
    self.isPlayWithComputer = YES;
    
    [self setUpTextField];
}

- (void)playWithplayer {
    
    self.isPlayWithComputer = NO;
    
    CGFloat vsComputerBtnY = 25;
    
    [UIView animateWithDuration:kAnimateDur animations:^{
        
        CGRect vsComputerBtnFrame = self.vsComputerBtn.frame;
        vsComputerBtnFrame.origin.y = -vsComputerBtnFrame.size.height - vsComputerBtnY;
        self.vsComputerBtn.frame = vsComputerBtnFrame;
        
        CGRect vsPlayerBtnFrame = self.vsPlayerBtn.frame;
        CGFloat vsPlayerBtnY = self.view.frame.size.height + vsPlayerBtnFrame.size.height;
        vsPlayerBtnFrame.origin.y = vsPlayerBtnY;
        self.vsPlayerBtn.frame = vsPlayerBtnFrame;
   
    } completion:^(BOOL finished) {
        
        [self.vsComputerBtn setTitle:@"HOST" forState:UIControlStateNormal];
        [self.vsPlayerBtn   setTitle:@"JOIN" forState:UIControlStateNormal];
        
        [self.vsComputerBtn removeTarget:self action:@selector(playWithComputer) forControlEvents:UIControlEventTouchUpInside];
        [self.vsPlayerBtn removeTarget:self action:@selector(playWithplayer) forControlEvents:UIControlEventTouchUpInside];
        
        [self.vsComputerBtn addTarget:self action:@selector(host) forControlEvents:UIControlEventTouchUpInside];
        [self.vsPlayerBtn   addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    
        [UIView animateWithDuration:kAnimateDur animations:^{

            CGRect vsComputerBtnFrame = self.vsComputerBtn.frame;
            vsComputerBtnFrame.origin.y = vsComputerBtnY;
            self.vsComputerBtn.frame = vsComputerBtnFrame;
            
            CGRect vsPlayerBtnFrame = self.vsPlayerBtn.frame;
            CGFloat vsPlayerBtnY = CGRectGetMaxY(self.vsComputerBtn.frame) + 5;
            vsPlayerBtnFrame.origin.y = vsPlayerBtnY;
            self.vsPlayerBtn.frame = vsPlayerBtnFrame;
        }];
    }];
}

- (void)host {
    
    self.isHost = YES;

    [self setUpTextField];
}

- (void)changeAlpha {
    
    [UIView animateWithDuration:kAnimateDur animations:^{
        
        self.textField.alpha     = 0.88f;
        self.vsComputerBtn.alpha = 0.1f;
        self.vsPlayerBtn.alpha   = 0.1f;
        self.vsComputerBtn.enabled = NO;
        self.vsPlayerBtn.enabled   = NO;
    }];
}

- (void)join {

    self.isHost = NO;

    [self setUpTextField];
}

- (void)setUpTextField {
    
    self.vsComputerBtn.enabled = NO;
    self.vsPlayerBtn.enabled = NO;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(35, 100, self.view.frame.size.width - 35 * 2, 50)];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"enter your name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                      NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15.0]}];

    self.textField.delegate = self;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.layer.cornerRadius = 9.0f;
    self.textField.clipsToBounds=YES;
    self.textField.alpha = 0.0f;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.textField.autocorrectionType = UITextSpellCheckingTypeNo;
    self.textField.font = [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:23.0f];
    [self.textField becomeFirstResponder];
    [self.view addSubview:self.textField];
    
    [self changeAlpha];
}

- (void)goToPvAVC {
    
    PvAViewController *pvAVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PvAViewController"];
    pvAVC.playerName = self.textField.text;

    [self presentViewController:pvAVC animated:YES completion:^{
        
        [self reAddEveryView];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField.text.length > 2) {

        [textField resignFirstResponder];
        
        [self addIndicator];
        
        if (self.isPlayWithComputer) {
            
            [NSTimer scheduledTimerWithTimeInterval:1.9f target:self selector:@selector(goToPvAVC) userInfo:nil repeats:NO];
        
        } else {
        
            [NSTimer scheduledTimerWithTimeInterval:1.9f target:self selector:@selector(goToPvPVC) userInfo:nil repeats:NO];
        }

    } else {
        
        [self playerDoesntEnterValidName];
    }
    
    return YES;
}

- (void)goToPvPVC {
    
    PvPViewController *pvpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PvPViewController"];
    pvpVC.playerName = self.textField.text;
    pvpVC.isHost = self.isHost;
    
    [self presentViewController:pvpVC animated:YES completion:^{
        
        [self reAddEveryView];
    }];
}

- (void)reAddEveryView {
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
    [self play];
}

- (void)removeIndicator {
    
    self.vsComputerBtn.enabled = YES;
    self.vsPlayerBtn.enabled = YES;
    
    [self.indicator stopAnimating];
    
    for (UIView *view in self.view.subviews) {
        view.alpha = 1.0f;
    }
    
    self.indicator.alpha = 0.0f;
}

- (void)addIndicator {
    
    if (!self.indicator) {
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicator.color = [UIColor whiteColor];
        self.indicator.center = self.view.center;
        [self.view addSubview:self.indicator];
    }
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.indicator.alpha = 1.0f;
    }];

    [self.indicator startAnimating];
}

- (void)playerDoesntEnterValidName {
    
    [self setUpValidNameLabel];
    
    [UIView animateWithDuration:kAnimateDur animations:^{
        
        self.validNameLabel.alpha = 1.0f;
    }];
}

- (void)setUpValidNameLabel {
    
    self.validNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, CGRectGetMaxY(self.textField.frame) + 35, self.view.frame.size.width - 35 * 2, 50)];
    self.validNameLabel.text = @"please enter a valid name";
    self.validNameLabel.alpha = 0.0f;
    self.validNameLabel.textColor = [UIColor whiteColor];
    self.validNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    self.validNameLabel.textAlignment = NSTextAlignmentCenter;
    self.validNameLabel.backgroundColor = [UIColor darkGrayColor];
    self.validNameLabel.layer.cornerRadius = 9.0f;
    self.validNameLabel.clipsToBounds=YES;
    [self.view addSubview:self.validNameLabel];
}


- (void)play {
    
    [self addBGImg];

    CGFloat btnW = self.view.frame.size.width - 10;
    CGFloat btnH = (self.view.frame.size.height - 20 - 15) / 2;
    CGFloat btnX = (self.view.frame.size.width - btnW) / 2;
    CGFloat vsComputerBtnY = 25;
    
    self.vsComputerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.vsComputerBtn addTarget:self action:@selector(playWithComputer) forControlEvents:UIControlEventTouchUpInside];
    self.vsComputerBtn.frame = CGRectMake(btnX, -btnH, btnW, btnH);
    [self.vsComputerBtn setTitle:@"VS. Computer" forState:UIControlStateNormal];
    [self setUpBtnWith:self.vsComputerBtn];
    
    self.vsPlayerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.vsPlayerBtn addTarget:self action:@selector(playWithplayer) forControlEvents:UIControlEventTouchUpInside];
    self.vsPlayerBtn.frame = CGRectMake(btnX, self.view.frame.size.height + btnH, btnW, btnH);
    [self.vsPlayerBtn setTitle:@"VS. Player" forState:UIControlStateNormal];
    [self setUpBtnWith:self.vsPlayerBtn];
    
    [UIView animateWithDuration:kAnimateDur animations:^{
       
        CGRect vsComputerBtnFrame = self.vsComputerBtn.frame;
        vsComputerBtnFrame.origin.y = vsComputerBtnY;
        self.vsComputerBtn.frame = vsComputerBtnFrame;
        
        CGRect vsPlayerBtnFrame = self.vsPlayerBtn.frame;
        CGFloat vsPlayerBtnY = CGRectGetMaxY(self.vsComputerBtn.frame) + 5;
        vsPlayerBtnFrame.origin.y = vsPlayerBtnY;
        self.vsPlayerBtn.frame = vsPlayerBtnFrame;
    }];
}

- (void)setUpBtnWith:(UIButton *)btn {
    
    [btn.layer setCornerRadius:9.0f];
    [btn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [btn.layer setBorderWidth:1.0f];
    [btn.layer setShadowColor:[UIColor blackColor].CGColor];
    [btn.layer setShadowOpacity:0.8];
    [btn.layer setShadowRadius:3.0];
    [btn.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [btn.layer setShadowColor:[UIColor blackColor].CGColor];
    [btn.layer setShadowOpacity:0.8];
    [btn.layer setShadowRadius:1.0];
    [btn.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:39]];
    [self.view addSubview:btn];
}















@end
