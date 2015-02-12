//
//  PvAViewController.m
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-10.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "PvAViewController.h"
#import "SecondScreenView.h"
#import "GameBottomVIew.h"
#import "Computer.h"
#import "Player.h"
#import "Ship.h"
#import "Map.h"


@interface PvAViewController () <PlayerDelegate, BotViewDelegate, MapDelegate, ComputerDelegate>

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Map *playerMap;
@property (nonatomic, strong) Map *computerMap;
@property (nonatomic, strong) Computer *computer;
@property (nonatomic, strong) GameBottomVIew *botView;
@property (nonatomic, strong) SecondScreenView *secondScreen;

@property (nonatomic, strong) UIWindow *secondWindow;

@property (nonatomic, assign) NSInteger aIShootBtnTag;
@property (nonatomic, assign) NSInteger playerShootBtnTag;

@end

@implementation PvAViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self addBGImg];
    
    [self readyToPlaceShips];
    
    [self checkForExistingScreenAndInitializeIfPresent];
}

#pragma Second Screen
- (void)checkForExistingScreenAndInitializeIfPresent {
    
    if ([[UIScreen screens] count] > 1) {

        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        CGRect screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        self.secondWindow.hidden = NO;
        
        self.secondScreen = [[SecondScreenView alloc] initWithName:self.playerName andOppentName:@"AI"];
        [self.secondWindow addSubview:self.secondScreen];
        
    } else {
        
        [self setUpScreenConnectionNotificationHandlers];
    }
}

- (void)setUpScreenConnectionNotificationHandlers {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification {
    
    UIScreen *newScreen = [aNotification object];
    CGRect screenBounds = newScreen.bounds;
    
    if (!self.secondWindow) {
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = newScreen;
        self.secondWindow.hidden = NO;
        
        self.secondScreen = [[SecondScreenView alloc] initWithName:self.playerName andOppentName:@"AI"];
        [self.secondWindow addSubview:self.secondScreen];
    }
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification {
    
    if (self.secondWindow){
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
    }
}


- (void)addBGImg {
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgImgView.image = [UIImage imageNamed:@"BG7201280.png"];
    [self.view addSubview:bgImgView];
}

#pragma <AI Delegate>
- (void)playerShipSunkWithShip:(Ship *)ship andBtnTag:(NSInteger)btnTag {
    
    [self.secondScreen showCrossMarkWithShipName:ship.name andIsOpponent:NO]; // SecondScreen
    
    [self playSoundWithSoundName:@"ShipSunk" andType:@"mp3"]; // Play sound
    
    self.botView.msgLbl.text = [NSString stringWithFormat:@"Your %@ is sunk", ship.name];
    
    [self.playerMap addCrossMarkWithShipName:ship.name];
    
    self.aIShootBtnTag = btnTag;
    
    [self.playerMap.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:1.9f target:self selector:@selector(nextHit) userInfo:nil repeats:NO];
}

#pragma <AI Delegate>
- (void)aIWinWithLastBtnTag:(NSInteger)btnTag andSunkShip:(Ship *)ship {
    
    [self.secondScreen.allBtns[btnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    [self.secondScreen showCrossMarkWithShipName:ship.name andIsOpponent:YES]; // SecondScreen
    
    [self.secondScreen gameOverWithWinnerName:@"AI"];
    
    self.aIShootBtnTag = btnTag;
    
    self.computer.isWinner = YES;
    
    [self.playerMap.allBtns[btnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    self.botView.msgLbl.text = [NSString stringWithFormat:@"Your %@ is sunk", ship.name];
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(playerLastShipSunk) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(aIisTheWinner) userInfo:nil repeats:NO];
}

- (void)playerLastShipSunk {
    
    [self.secondScreen.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal]; // Second Screen}
}

- (void)aIisTheWinner {

    [self.playerMap.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
    
    self.botView.msgLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
    
    self.playerMap.nameLbl.alpha = 0.0f;
    
    self.botView.msgLbl.text = @"All your ships are sunk";
    self.playerMap.nameLbl.text = @"AI IS THE WINNER !";
    
    self.playerMap.nameLbl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5f, 0.5f);
    
    [UIView animateWithDuration:1.5f animations:^{
        
        self.playerMap.nameLbl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15f, 1.15f);
        
        self.playerMap.alpha = 0.5f;
        self.playerMap.nameLbl.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        [self.botView addPlayAgainBtnWith:self.view];
        [self.botView.playAgainBtn addTarget:self action:@selector(playAgain:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)playAgain:(UIButton *)sender {
    
    sender.enabled = NO;
    
    [UIView animateWithDuration:1.5f animations:^{
        for (UIView *view in self.view.subviews) {
            view.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
#pragma <AI Delegate>
- (void)playerWinWithLastShip:(Ship *)ship andBtnTag:(NSInteger)tag {
    
    self.playerShootBtnTag = tag;
    
    [self.secondScreen showCrossMarkWithShipName:ship.name andIsOpponent:NO]; // SecondScreen
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    [self.secondScreen gameOverWithWinnerName:self.playerName];
    
    self.botView.msgLbl.text = [NSString stringWithFormat:@"AI's %@ is sunk", ship.name];
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(aILastShipSunk) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(youAreTheWinner) userInfo:nil repeats:NO];
}

- (void)aILastShipSunk {
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal]; // Second Screen
}

- (void)youAreTheWinner {
    
    self.botView.msgLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];

    self.computerMap.nameLbl.alpha = 0.0f;
    
    self.botView.msgLbl.text = @"All AI's ships are sunk";
    self.computerMap.nameLbl.text = @"YOU ARE THE WINNER !";

    self.computerMap.nameLbl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5f, 0.5f);
    
    [UIView animateWithDuration:1.5f animations:^{

        self.computerMap.nameLbl.alpha = 1.0f;
        self.computerMap.nameLbl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15f, 1.15f);
        self.computerMap.alpha = 0.5f;
        
    } completion:^(BOOL finished) {
        
        [self.botView addPlayAgainBtnWith:self.view];
        [self.botView.playAgainBtn addTarget:self action:@selector(playAgain:) forControlEvents:UIControlEventTouchUpInside];
    }];
}


#pragma <AI Delegate>
- (void)shipSunkWithShip:(Ship *)ship andBtnTag:(NSInteger)tag { // AI
    
    self.playerShootBtnTag = tag;
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    [self.secondScreen showCrossMarkWithShipName:ship.name andIsOpponent:YES];
    
    self.botView.msgLbl.text = [NSString stringWithFormat:@"AI's %@ is sunk", ship.name];
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(aIShipSunk) userInfo:nil repeats:NO];
}

- (void)aIShipSunk {
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal]; // Second Screen
}

#pragma <AI Delegate>
- (void)youHitItWithBtnTag:(NSInteger)tag {
    
    self.playerShootBtnTag = tag;
    
    [self.secondScreen.opponentAllBtns[tag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    self.botView.msgLbl.text = @"You hit it!";
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(youHit) userInfo:nil repeats:NO];
}

- (void)youHit {
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal]; // Second Screen
}

#pragma <AI Delegate>
- (void)youMissItWithBtnTag:(NSInteger)tag {
    
    self.playerShootBtnTag = tag;
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    self.botView.msgLbl.text = @"You miss it!";
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(youMissIt) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(aITurn) userInfo:nil repeats:NO];
}

- (void)youMissIt {
    
    [self.secondScreen.opponentAllBtns[self.playerShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"LightBlueBtn.png"] forState:UIControlStateNormal]; // Second Screen
}

#pragma <AI Delegate>
- (void)aITurn {
    
    [self.secondScreen changeMapAlphaWith:NO]; // Second Screen
    
    [UIView animateWithDuration:0.55f animations:^{
        self.playerMap.alpha = 1.0f;
        self.computerMap.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.botView.msgLbl.text = @"It's AI's turn";
        [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(aIFire) userInfo:nil repeats:NO];
    }];
}
#pragma <AI Delegate>
- (void)aIHitPlayerShipWithBtntag:(NSInteger)tag {
    
    [self.secondScreen.allBtns[tag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen

    self.aIShootBtnTag = tag;
    
    [self.playerMap.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    self.botView.msgLbl.text = @"AI hit it!";
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(nextHit) userInfo:nil repeats:NO];
}

- (void)nextHit {
    
    [self.playerMap.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
    
    [self.secondScreen.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    [self.computer whatShouldIDo];
}

- (void)nextMiss {
    
    [self.playerMap.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"LightBlueBtn.png"] forState:UIControlStateNormal];
    
    [self.secondScreen.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"LightBlueBtn.png"] forState:UIControlStateNormal]; // Second Screen

    [self yourTurn];
}

- (void)yourTurnBtnClicked {
    
    [self aITurn];
}

#pragma <AI Delegate>
- (void)aIMissPlayerShipWithBtntag:(NSInteger)tag {

    [self.secondScreen.allBtns[tag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal]; // Second Screen
    
    self.aIShootBtnTag = tag;
    
    [self.playerMap.allBtns[self.aIShootBtnTag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    self.botView.msgLbl.text = @"AI miss it!";
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(nextMiss) userInfo:nil repeats:NO];
}

- (void)aIFire {
    [self.computer whatShouldIDo];
}

#pragma <Player Delegate>
- (void)aIHitIt {
    
    self.botView.msgLbl.text = @"AI hit it!";
    
    [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(aIFire) userInfo:nil repeats:NO];
}

#pragma <Player Delegate>
- (void)aIMissIt {
    
    self.botView.msgLbl.text = @"AI miss it!";
    
    [self yourTurn];
}


- (void)setUpPlayer {
    
    self.playerMap = [[Map alloc] initWithFrame:self.view.frame andPlayerName:self.playerName];
    self.player = [[Player alloc] initWithPlayerName:@"Lewis" andMap:self.playerMap];
    self.player.delegate = self;
    self.playerMap.delegate = self;
    [self.view addSubview:self.playerMap];
    
}

- (void)setUpComputer {

    self.computerMap = [[Map alloc] initWithFrame:self.view.frame andPlayerName:@"AI"];
    self.computerMap .userInteractionEnabled = NO;
    self.computer = [[Computer alloc] initWithMap:self.computerMap andPlayerShipsArray:self.player.shipsArray];
    self.computer.delegate = self;
    [self.view addSubview:self.computerMap];
    self.computerMap.alpha = 0.0f;
}

- (void)setUpBottomView {
    
    self.botView = [[GameBottomVIew alloc] initWithMapViewFrame:self.playerMap.frame andDeviceView:self.view];
    self.botView.delegate = self;
}


- (void)readyToPlaceShips {
    
    [self setUpPlayer];
    [self setUpBottomView];
    
    [UIView animateWithDuration:0.55f animations:^{
        
        self.playerMap.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.55f animations:^{
            
            self.botView.alpha = 1.0f;
            self.botView.shipImgView.alpha = 1.0f;
        }];
    }];
}

- (void)allShipsAllPlaced {

    [self.botView hideBotViewShipImgVWith:YES];
    [self.botView.startBtn addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startGame {
    
    [self.playerMap removeAllCheckMarks];
    
    [self.botView readyToStartGameWith:YES];

    [self.botView startCountDown];
    
    [self setUpComputer];
}

- (void)gameStarted {
    
    int ranNum = arc4random() % 2;

    if (ranNum == 0 ) { // Host Start First
        
        [self yourTurn];
        
    } else { // AI Start First
        
        [self.secondScreen changeMapAlphaWith:NO]; // SecondScreen
        
        self.botView.msgLbl.text = @"Its AI's turn";
        
        [NSTimer scheduledTimerWithTimeInterval:0.55f target:self selector:@selector(aITurn) userInfo:nil repeats:NO];
    }
}
    

- (void)yourTurn {
    
    [self.secondScreen changeMapAlphaWith:YES]; // SecondScreen
    
    [UIView animateWithDuration:0.55f animations:^{
        self.playerMap.alpha = 0.0f;
        self.computerMap.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.botView.msgLbl.text = @"It's your turn";
        self.computerMap.userInteractionEnabled = YES;
    }];
}

- (void)playSoundWithSoundName:(NSString *)soundName andType:(NSString *)type {
    
    SystemSoundID completeSound;
    NSURL *audioPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:type]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
    AudioServicesPlaySystemSound (completeSound);
}


#pragma mark - touch begin
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.playerMap touchesMoved:touches withEvent:event withShipsArray:self.player.shipsArray and:self.botView.shipImgView];
    [self.botView touchesMoved:touches withEvent:event withView:self.view];
}

#pragma mark - touch end
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.playerMap touchesEnded:touches withEvent:event withShipsArray:self.player.shipsArray and:self.botView];
}


@end

