//
//  GameBottomVIew.m
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-06.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "GameBottomVIew.h"
#import "UIImage+animatedGIF.h"

#define kCountDownDur 3.0f

@interface GameBottomVIew ()

@property (nonatomic, retain) NSMutableArray *checkMarks;

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, strong) NSDate *timerExpDate;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UIImageView *gifImgView;

@end

@implementation GameBottomVIew {
    
    UISwipeGestureRecognizer *_vertical;
    UISwipeGestureRecognizer *_horizontal;
}

- (id)initWithMapViewFrame:(CGRect)mFrame andDeviceView:(UIView *)deviceV {
    
    if (self = [super init]) {
        
        self.alpha = 0.0f;
        
        CGRect dFrame = deviceV.frame;
        
        self.checkMarks = [NSMutableArray array];
        
        // MapView
        CGFloat viewW  = dFrame.size.width * 0.95;
        CGFloat viewX  = (dFrame.size.width - viewW) / 2;
        CGFloat viewH  = dFrame.size.height - mFrame.size.height;

        self.frame = CGRectMake(viewX, mFrame.size.height, viewW, viewH);

        // msg label
        self.msgLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW, 30)];
        self.msgLbl.text = @"Place your ship";
        [self setUpLabelWith:self.msgLbl];
        
        CGFloat shipImgVWH = (self.frame.size.height - self.msgLbl.frame.size.height) * 0.5;
        CGFloat shipImgX   = (viewW - shipImgVWH) / 2;
        CGFloat shipImgY   = mFrame.size.height + self.msgLbl.frame.size.height + shipImgVWH / 2;
        
        self.shipImgView = [[UIImageView alloc] initWithFrame:CGRectMake(shipImgX, shipImgY, shipImgVWH, shipImgVWH)];
        self.shipImgView.image = [UIImage imageNamed:@"AircraftCarrier.png"];
        self.shipImgView.contentMode = UIViewContentModeScaleAspectFit;
        [deviceV addSubview:self.shipImgView];
        
        self.shipImgView.alpha = 0.0f;
        
        self.originalShipCenter = self.shipImgView.center;
        
        [self addStartBtn];
        
        [self enableSwipeGestureWithDeviceView:deviceV];
        
        [self setUpIndicator];
        
        [self setUpCopyRightLabel];
        
        [deviceV addSubview:self];
    }
    
    return self;
}

- (void)setUpCopyRightLabel {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
    label.text = @"© Lewis Feng 2015";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
}

- (void)enableSwipeGestureWithDeviceView:(UIView *)deviceV {

    _vertical = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportVerticalSwipe:)];
    _vertical.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [_vertical setNumberOfTouchesRequired:2];
    [deviceV addGestureRecognizer:_vertical];
    
    _horizontal = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportHorizontallSwipe:)];
    _horizontal.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [_horizontal setNumberOfTouchesRequired:2];
    [deviceV addGestureRecognizer:_horizontal];
}

- (void)disableSwipeGesture {
    
    [_vertical   removeTarget:self action:@selector(reportVerticalSwipe:)];
    [_horizontal removeTarget:self action:@selector(reportHorizontallSwipe:)];
}

#pragma mark - touch begin
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withView:(UIView *)deviceW {

    UITouch *touch = [touches anyObject];
    CGPoint touchCenter = [touch locationInView:deviceW];

    CGPoint shipCenter = touchCenter;
    self.shipImgView.center = shipCenter;
}

#pragma mark -  ---> (UP)
- (void)reportVerticalSwipe:(UIGestureRecognizer *)recognizer {
    
    if (self.shipImgView.image.imageOrientation != UIImageOrientationRight) {
        self.shipImgView.image = [UIImage imageWithCGImage:[self.shipImgView.image CGImage] scale:1.0f orientation:UIImageOrientationRight];
    }
    // Reposition ship to original position
    self.shipImgView.center = self.originalShipCenter;
}

#pragma mark - ---> (LEFT or RIGHT)
- (void)reportHorizontallSwipe:(UIGestureRecognizer *)recognizer {

    if (self.shipImgView.image.imageOrientation == UIImageOrientationRight) {
        self.shipImgView.image = [UIImage imageWithCGImage:[self.shipImgView.image CGImage] scale:1.0f orientation:UIImageOrientationUp];
    }
    self.shipImgView.center = self.originalShipCenter;
}

- (void)hideBotViewShipImgVWith:(BOOL)isHost {
    
    NSString *title;
    if (isHost) {
        title = @"START";
    } else {
        title = @"READY";
    }
    
    [self.startBtn setTitle:title forState:UIControlStateNormal];
    
    [UIView animateWithDuration:1.0f animations:^{
        self.shipImgView.alpha = 0.0f;
        self.startBtn.alpha = 1.0f;
    }];
}


- (void)readyToStartGameWith:(BOOL)isHost {

    [self disableSwipeGesture];
    
    [self.shipImgView removeFromSuperview];
    self.shipImgView = nil;

    if (!isHost) {
        [self enableIndicator];
        self.startBtn.alpha = 0.5f;
        self.startBtn.enabled = NO;
        self.msgLbl.text = @"waitting for host to start";
    }
}

- (void)enableIndicator {
    
    self.indicator.alpha = 1.0f;
    [self.indicator startAnimating];
}

- (void)disableIndicator {
    
    self.indicator.alpha = 0.0f;
    [self.indicator stopAnimating];
}

- (void)setUpIndicator {
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.center = self.startBtn.center;
    [self addSubview:self.indicator];
}

- (void)addStartBtn {
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnWH = self.shipImgView.frame.size.width;
    CGFloat btnY  = self.msgLbl.frame.size.height + btnWH / 2;
    self.startBtn.frame = CGRectMake(self.shipImgView.frame.origin.x, btnY, btnWH, btnWH);
    self.startBtn.alpha = 0.0f;
    [self.startBtn.layer setCornerRadius:9.0f];
    [self.startBtn setBackgroundColor:[UIColor darkGrayColor]];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:19]];
    [self addSubview:self.startBtn];
}

- (void)setUpLabelWith:(UILabel *)label {
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor darkGrayColor];
    label.alpha = 0.9f;
    label.layer.cornerRadius = 5.0f;
    label.clipsToBounds=YES;
    [self addSubview:label];
}

- (void)startCountDown {
    
    self.startBtn.enabled = NO;
    
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    [UIView animateWithDuration:kCountDownDur animations:^{
        
        self.startBtn.alpha = 0.0f;
        
    } completion:^(BOOL finished) {

        [self addGifImgView];
        
        [UIView animateWithDuration:1.0f animations:^{
            
            self.gifImgView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            [self.startBtn removeFromSuperview];
            self.startBtn = nil;
        }];
    }];
    
    [self enableIndicator];
}

- (void)addGifImgView {
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"Preloader_6" ofType:@"gif"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    self.gifImgView = [[UIImageView alloc] initWithFrame:self.startBtn.frame];
    self.gifImgView.alpha = 0.0f;
    self.gifImgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    [self addSubview:self.gifImgView];
}

- (void)countDown {
    
    if (!self.timerExpDate) {
        self.timerExpDate = [NSDate dateWithTimeIntervalSinceNow:kCountDownDur];
    }
    
    NSTimeInterval secondsRemaining = [self.timerExpDate timeIntervalSinceDate:[NSDate date]];
    
    self.msgLbl.text = [NSString stringWithFormat:@"Game will start in %.0f sec", secondsRemaining];
    
    if (secondsRemaining <= 0) {
        
        self.msgLbl.text = [NSString stringWithFormat:@"Game Start!"];
        
        [self.countDownTimer invalidate];
        self.timerExpDate = nil;
        
        [UIView animateWithDuration:1.0f animations:^{
            
            [self disableIndicator];
            
            self.startBtn.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
           
            [self.delegate gameStarted];
        }];  
    }
}

- (void)addPlayAgainBtnWith:(UIView *)deviceV {
    
    CGFloat btnW = self.frame.size.width * 0.75;
    CGFloat btnH = btnW * 0.5;
    CGFloat btnX = (self.frame.size.width - btnW) / 2;
    CGFloat btnY = (self.frame.size.height - self.msgLbl.frame.size.height - btnH) / 2 + self.msgLbl.frame.size.height;
    
    self.playAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
    [self.playAgainBtn setBackgroundImage:[UIImage imageNamed:@"PlayAgain.png"] forState:UIControlStateNormal];
    [self.playAgainBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:33.0f]];
    [self.playAgainBtn setTitle:@"PLAY AGAIN" forState:UIControlStateNormal];
    self.playAgainBtn.alpha = 0.0f;
    self.playAgainBtn.enabled = YES;
    [self addSubview:self.playAgainBtn];

    [UIView animateWithDuration:1.5f animations:^{
        self.playAgainBtn.alpha = 0.75f;
        self.gifImgView.alpha = 0.0f;
    }];
}

@end
