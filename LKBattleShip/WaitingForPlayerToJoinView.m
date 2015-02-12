//
//  WaitingForPlayerToJoinView.m
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-07.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "WaitingForPlayerToJoinView.h"
#import "UIImage+animatedGIF.h"

@interface WaitingForPlayerToJoinView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *gifImgView;

@property (nonatomic, strong) UILabel *inviteLabel; // Server && Ciient
@property (nonatomic, strong) UILabel *countDownLabel; // Server && Ciient

@property (nonatomic, copy) NSString *hostName;


@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UIButton *acceptBtn;
@property (nonatomic, strong) UIButton *refuseBtn;

@property (nonatomic, strong) NSTimer *countDownTimer;
@property (nonatomic, strong) NSDate *timerExpDate;

@end

@implementation WaitingForPlayerToJoinView {
    
    CGFloat _deviceW;
    CGFloat _deviceH;
}

- (id)initWithFrame:(CGRect)frame andPlayerName:(NSString *)name  and:(BOOL)isHost {
    
    if (self = [super init]) {
        
        self.frame = frame;
        
        _deviceW = frame.size.width;
        _deviceH = frame.size.height;
        
        [self addBGImg];

        self.connectedPlayerNames = [NSMutableArray array];
        
        [self setUpTopBarWith:name];
        
        if (isHost) {
            [self setUpTableView];
        } else {
            [self setUpGifImgView];
        }

        [self setUpBotBar];
    }
    
    return self;
}

- (void)addBGImg {
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.frame];
    bgImgView.image = [UIImage imageNamed:@"BG7201280.png"];
    [self  addSubview:bgImgView];
}

- (void)setUpGifImgView {
    
    self.gifImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 99, 99)];
    self.gifImgView.center = self.center;
    self.gifImgView.alpha = 0.88f;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"loading-transparent" ofType:@"gif"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    self.gifImgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    [self addSubview:self.gifImgView];
}

- (void)setUpTopBarWith:(NSString *)name {

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _deviceW, 80)];
    label.text = name;
    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor darkGrayColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:39.0f];
    [self addSubview:label];
    
    
}

- (void)setUpBotBar {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, _deviceH - 80, _deviceW, 80)];
    label.text = @"LKBATTLESHIP";
    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor darkGrayColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:39.0f];
    [self addSubview:label];
}

- (void)setUpTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, _deviceW, _deviceH - 80 * 2) style:UITableViewStylePlain];
    self.tableView.rowHeight = 66;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.connectedPlayerNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = self.connectedPlayerNames[indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:23.0f];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SelectedCellBG.png"]];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    [self.delegate selectedPlayerName:cell.textLabel.text];
    
    [UIView animateWithDuration:0.5f animations:^{
        
        for (UIView *view in self.subviews) {
            
            view.userInteractionEnabled = NO;
            
            if (![view isEqual:cell] && ![view isEqual:tableView]) {
                view.alpha = 0.3f;
            }
        }
    }];

    [self addIndicator];
    
    [self addInviteLabelWithOpponentName:cell.textLabel.text];
}

- (void)addInviteLabelWithOpponentName:(NSString *)name {
    
    if (!self.inviteLabel) {
        
        CGFloat labelW = _deviceW * 0.9;
        CGFloat labelX = (_deviceW - labelW) / 2;
        CGFloat labelY = _deviceH / 2 + 30;
        
        self.inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, 50)];
        self.inviteLabel.text = [NSString stringWithFormat:@"You send invite to %@", name];
        self.inviteLabel.alpha = 0.0f;
        self.inviteLabel.textColor = [UIColor whiteColor];
        self.inviteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.inviteLabel.textAlignment = NSTextAlignmentCenter;
        self.inviteLabel.backgroundColor = [UIColor darkGrayColor];
        self.inviteLabel.layer.cornerRadius = 9.0f;
        self.inviteLabel.clipsToBounds=YES;
        [self addSubview:self.inviteLabel];
    }

    [UIView animateWithDuration:1.0f animations:^{
        
        self.inviteLabel.alpha = 1.0f;
    }];
}

- (void)addIndicator {
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    self.indicator.color = [UIColor darkGrayColor];
    self.indicator.center = self.center;
    [self addSubview:self.indicator];
    [self.indicator startAnimating];
}

- (void)receivedInviteFromPlayer:(NSString *)playerName {
    
    self.hostName = playerName;
    
    self.inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, _deviceW - 30, 50)];
    self.inviteLabel.text = [NSString stringWithFormat:@"%@ wants to play with you", playerName];
    self.inviteLabel.textAlignment = NSTextAlignmentCenter;
    self.inviteLabel.backgroundColor = [UIColor darkGrayColor];
    self.inviteLabel.textColor = [UIColor whiteColor];
    self.inviteLabel.alpha = 0.0f;
    self.inviteLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:19.0f];
    self.inviteLabel.layer.cornerRadius = 5.0f;
    self.inviteLabel.clipsToBounds=YES;
    [self addSubview:self.inviteLabel];
    
    self.acceptBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.inviteLabel.frame.origin.x, CGRectGetMaxY(self.inviteLabel.frame) + 15, self.inviteLabel.frame.size.width / 2, 50)];
    [self.acceptBtn setTitle:@"ACCETP" forState:UIControlStateNormal];
    [self setUpBtnWith:self.acceptBtn];
    
    [self.acceptBtn addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    
    self.refuseBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.acceptBtn.frame), self.acceptBtn.frame.origin.y, self.acceptBtn.frame.size.width, self.acceptBtn.frame.size.height)];
    [self.refuseBtn setTitle:@"REFUSE" forState:UIControlStateNormal];
    [self setUpBtnWith:self.refuseBtn];
    
    [self.refuseBtn addTarget:self action:@selector(refuse) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupCountDownLabel];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.inviteLabel.alpha = 1.0f;
        self.countDownLabel.alpha = 1.0f;
        self.acceptBtn.alpha = 1.0f;
        self.refuseBtn.alpha = 1.0f;
        self.gifImgView.alpha = 0.3f;
    } completion:^(BOOL finished) {
        
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }];
}

- (void)setupCountDownLabel {
    
    CGFloat labelWH = 66.0f;
    CGFloat labelX  = (_deviceW - labelWH) / 2;
    CGFloat labelY  = _deviceH / 2 + 100;
    
    self.countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWH, labelWH)];
    self.countDownLabel.textAlignment = NSTextAlignmentCenter;
    self.countDownLabel.backgroundColor = [UIColor darkGrayColor];
    self.countDownLabel.textColor = [UIColor whiteColor];
    self.countDownLabel.text = @"15";
    self.countDownLabel.alpha = 0.0f;
    self.countDownLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f];
    self.countDownLabel.layer.cornerRadius = 5.0f;
    self.countDownLabel.clipsToBounds=YES;
    [self addSubview:self.countDownLabel];
}

- (void)countDown {
    
    if (!self.timerExpDate) {
        self.timerExpDate = [NSDate dateWithTimeIntervalSinceNow:15];
    }
    
    NSTimeInterval secondsRemaining = [self.timerExpDate timeIntervalSinceDate:[NSDate date]];
    
    self.countDownLabel.text = [NSString stringWithFormat:@"%.0f", secondsRemaining];
    
    if (secondsRemaining <= 0) {
        
        self.countDownLabel.text = [NSString stringWithFormat:@"0"];
        
        [self.countDownTimer invalidate];
        self.timerExpDate = nil;

        [self refuse];
    }
}

- (void)accept {
    
    [self disableBtn];

    [self addIndicatorAgain];
    [self.delegate playerChoseAcceptTo:self.hostName];
}

- (void)refuse {
    
    [self disableBtn];

    [self removeIndicator];
    [self removeLabelAndBtn];
    [self.delegate playerChoseRefuseTo:self.hostName];
}

- (void)disableBtn {
    
    [self.countDownTimer invalidate];
    self.timerExpDate = nil;
    self.countDownLabel.text = @"15";
    
    self.acceptBtn.enabled = NO;
    self.refuseBtn.enabled = NO;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.acceptBtn.alpha = 0.5f;
        self.refuseBtn.alpha = 0.5f;
    }];
}


- (void)removeLabelAndBtn {
    
    self.inviteLabel.textColor = [UIColor redColor];
    
    self.inviteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f];
    
    self.inviteLabel.text = [NSString stringWithFormat:@"You refused %@'s invitation", self.hostName];
    
    [NSTimer scheduledTimerWithTimeInterval:1.9f target:self selector:@selector(backToNormal) userInfo:nil repeats:NO];
}

- (void)opponentRefusedInvitationWith:(NSString *)name {
    
    self.inviteLabel.textColor = [UIColor redColor];
    
    self.inviteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f];
    
    self.inviteLabel.text = [NSString stringWithFormat:@"%@ refused your invitation", name];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(backToNormal) userInfo:nil repeats:NO];
}

- (void)backToNormal {
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.inviteLabel.alpha = 0.0f;
        self.acceptBtn.alpha  = 0.0f;
        self.refuseBtn.alpha = 0.0f;
        self.countDownLabel.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self removeIndicator];
        
        [self.countDownLabel removeFromSuperview];
        self.countDownLabel = nil;
        
        [self.inviteLabel removeFromSuperview];
        self.inviteLabel = nil;
        
        [self.acceptBtn removeFromSuperview];
        self.acceptBtn = nil;
        
        [self.refuseBtn removeFromSuperview];
        self.refuseBtn = nil;
    }];
}

- (void)removeIndicator {
    
    [UIView animateWithDuration:0.5f animations:^{
        
        for (UIView *view in self.subviews) {
            
            if (![view isEqual:self.acceptBtn] && ![view isEqual:self.refuseBtn]) {
                
                view.userInteractionEnabled = YES;
                view.alpha = 1.0f;
            }
        }
    }];

    [self.indicator stopAnimating];

    self.indicator.alpha = 0.0f;
}

- (void)addIndicatorAgain {
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.color = [UIColor darkGrayColor];
    self.indicator.center = self.center;
    [self addSubview:self.indicator];
    
    for (UIView *view in self.subviews) {
        
        if (![view isEqual:self.indicator]) {
            view.alpha = 0.3f;
        }
    }
    [self.indicator startAnimating];
}

- (void)setUpBtnWith:(UIButton *)btn {
    
    btn.alpha = 0.0f;
    [btn.layer setCornerRadius:9.0f];
    [btn setBackgroundColor:[UIColor darkGrayColor]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:23]];
    [self addSubview:btn];
}


@end
