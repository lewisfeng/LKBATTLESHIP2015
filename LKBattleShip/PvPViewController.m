//
//  PvPViewController.m
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-09.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "PvPViewController.h"
#import "Player.h"
#import "Map.h"
#import "Game.h"
#import "Ship.h"
#import "GameBottomVIew.h"
#import "SecondScreenView.h"
#import "WaitingForPlayerToJoinView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PvPViewController () <GameDelegate, WaitingForJoinDelegate, MapDelegate, BotViewDelegate>

@property (nonatomic, strong) Game   *game;
@property (nonatomic, strong) Map    *map;
@property (nonatomic, strong) Map    *opponentMap;
@property (nonatomic, strong) GameBottomVIew *botView;
@property (nonatomic, strong) SecondScreenView *secondScreen;
@property (nonatomic, strong) WaitingForPlayerToJoinView *waitingForJoinView;

@property (nonatomic, retain) NSMutableArray *connectedPeers;

@property (nonatomic, assign) NSInteger btnTag;

@property (nonatomic, strong) UIWindow *secondWindow;

@end

@implementation PvPViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadGame];
}

- (void)checkForExistingScreenAndInitializeIfPresent {
    
    NSLog(@"checkForExistingScreenAndInitializeIfPresent");
    
    if ([[UIScreen screens] count] > 1) {
        
        NSLog(@"Found");

        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        CGRect screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        self.secondWindow.hidden = NO;
        
        self.secondScreen = [[SecondScreenView alloc] initWithName:self.game.player.name andOppentName:self.game.opponent.name];
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
        
        self.secondScreen = [[SecondScreenView alloc] initWithName:self.game.player.name andOppentName:self.game.opponent.name];
        [self.secondWindow addSubview:self.secondScreen];
    }
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification {
    
    if (self.secondWindow){
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
    }
}

- (void)playSoundWithSoundName:(NSString *)soundName andType:(NSString *)type {
    
    SystemSoundID completeSound;
    NSURL *audioPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:type]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
    AudioServicesPlaySystemSound (completeSound);
}

- (void)addBGImg {
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgImgView.image = [UIImage imageNamed:@"BG7201280.png"];
    [self.view addSubview:bgImgView];
}

- (void)loadGame {
    
    [self addBGImg];

    self.game = [[Game alloc] initWithPlayerName:self.playerName and:self.isHost];
    self.game.delegate = self;
    
    [self setUpWaitingForJoinView];

    [self addNotification];
}

#pragma <GameDelegate> methods - Client
- (void)opponentReceivedInvitationFrom:(NSString *)name {
    [self.waitingForJoinView receivedInviteFromPlayer:name];
}
#pragma <GameDelegate> methods - Server
- (void)opponentAcceptInvitation {
    [self readyToPlaceShips];
    [self checkForExistingScreenAndInitializeIfPresent];
}

#pragma <GameDelegate> methods - Server
- (void)opponentRefusedInvitation {
    [self.waitingForJoinView opponentRefusedInvitationWith:self.game.opponent.name];
}

#pragma <GameDelegate> methods - Server
- (void)opponentIsReady {
    self.map.opponentLbl.text = [NSString stringWithFormat:@"ready - %@", self.game.opponent.name];
    self.botView.startBtn.enabled = YES;
    self.botView.msgLbl.text = [NSString stringWithFormat:@"%@ is ready", self.game.opponent.name];
}

#pragma <GameDelegate> methods - Client
- (void)opponentReceivedStartGame {
    [self.botView startCountDown];
}

#pragma <GameDelegate> methods - Server
- (void)hostFirst {
    [self opponentsTurn];
}

#pragma <GameDelegate> methods - Client
- (void)clientFirst {
    [self yourTurn];
}

#pragma <GameDelegate> methods
- (void)miss { // Opponent side
    
    [self.secondScreen.opponentAllBtns[self.btnTag] setBackgroundImage:[UIImage imageNamed:@"LightBlueBtn.png"] forState:UIControlStateNormal]; // SecondScreen

    UIButton *clickedBtn = self.opponentMap.allBtns[self.btnTag];

    [clickedBtn setBackgroundImage:[UIImage imageNamed:@"LightBlueBtn.png"] forState:UIControlStateNormal];
    
    self.botView.msgLbl.text = @"You miss it !";
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(opponentsTurn) userInfo:nil repeats:NO];
}
#pragma <GameDelegate> methods
- (void)hit { // Opponent side

    self.botView.msgLbl.text = @"You hit it !";
    
    [self updateOpponentScore];
}

- (void)updateOpponentScore {
    
    [self.secondScreen.opponentAllBtns[self.btnTag] setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal]; // SecondScreen
    
    UIButton *clickedBtn = self.opponentMap.allBtns[self.btnTag];
    [clickedBtn setBackgroundImage:[UIImage imageNamed:@"RedBtn.png"] forState:UIControlStateNormal];
    
    self.game.player.score = self.game.player.score + 1;
    self.map.nameLbl.text             = [NSString stringWithFormat:@"%@ - %i", self.playerName, self.game.player.score];
    self.opponentMap.opponentLbl.text = [NSString stringWithFormat:@"%i - %@", self.game.player.score, self.playerName];
    
    self.opponentMap.userInteractionEnabled = YES;
}

#pragma <GameDelegate> methods
- (void)shipSunkWithShipName:(NSString *)shipName { // SecondScreen

    [self.secondScreen showCrossMarkWithShipName:shipName andIsOpponent:YES]; //
    
    [self updateOpponentScore];
    
    [self playSoundWithSoundName:@"ShipSunk" andType:@"mp3"]; // Play sound
    
    self.botView.msgLbl.text = [NSString stringWithFormat:@"%@'s %@ is sunk !",self.game.opponent.name, shipName];
    [self.opponentMap addCrossMarkWithShipName:shipName];
}

#pragma <GameDelegate> methods
- (void)btnClicked:(NSInteger)tag { // your side
    
    self.btnTag = tag;
    
    [self.map.allBtns[tag] setBackgroundImage:[UIImage imageNamed:@"OrangeBtn.png"] forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkResult) userInfo:nil repeats:NO];
    
}

- (void)checkResult {
    
    NSString *imgName;
    NSString *result;
    
    if ([self isHit]) {
        
        imgName = @"RedBtn.png";
        result  = kHit;
        self.game.opponent.score = self.game.opponent.score + 1;
        
        self.botView.msgLbl.text = [NSString stringWithFormat:@"%@ hit your ship !", self.game.opponent.name];
        self.map.opponentLbl.text     = [NSString stringWithFormat:@"%@ - %i", self.game.opponent.name, self.game.opponent.score];
        self.opponentMap.nameLbl.text = [NSString stringWithFormat:@"%@ - %i", self.game.opponent.name, self.game.opponent.score];
        
    } else {
        
        imgName = @"LightBlueBtn.png";
        result  = kMiss;
        self.botView.msgLbl.text = [NSString stringWithFormat:@"%@ miss it", self.game.opponent.name];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(yourTurn) userInfo:nil repeats:NO];
    }
    [self.map.allBtns[self.btnTag] setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    [self.secondScreen.allBtns[self.btnTag] setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal]; // SecondScreen
    
    if (![self isShipSunk]) {
        [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:result];
    }

}

#pragma <GameDelegate> methods
- (void)youWin {
    
    [self.secondScreen gameOverWithWinnerName:self.game.player.name];
    
    self.opponentMap.userInteractionEnabled = NO;
    self.botView.msgLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
    self.botView.msgLbl.text = [NSString stringWithFormat:@"All %@' ships are sunk", self.game.opponent.name];
    [self gameOverWith:YES];
}

- (void)gameOverWith:(BOOL)isWinner {
    
    [self.game stopBrowingForPeers];
    [self.game stopAdvertisingPeer];
    
    if (isWinner) {
        [self.opponentMap gameOverWith:isWinner];
    } else {
        [self.map gameOverWith:isWinner];
    }

    [self.botView addPlayAgainBtnWith:self.view];

    [self.botView.playAgainBtn addTarget:self action:@selector(playAgain:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playerChoseAcceptTo:(NSString *)playerName { // Client
    [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kAccept];
    [self readyToPlaceShips];
}

- (void)playerChoseRefuseTo:(NSString *)playerName {
    [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kRefuse];
}

- (BOOL)isHit {
    BOOL isHit = NO;
    for (UIButton *btn in self.map.shipsPosition) {
        if (self.btnTag == btn.tag) {
            isHit = YES;
            break;
        }
    }
    return isHit;
}

- (BOOL)isShipSunk { // your side

    BOOL isShipSunk = NO;

    for (Ship *ship in self.game.player.shipsArray) {

        for (UIButton *btn in ship.segments) {

            if (btn.tag == self.btnTag) {
                
                [ship.segments removeObject:btn];

                if (ship.segments.count == 0) {
                    
                    isShipSunk = YES;

                    self.botView.msgLbl.text = [NSString stringWithFormat:@"Your %@ is sunk !", ship.name];
                    
                    [self playSoundWithSoundName:@"ShipSunk" andType:@"mp3"]; // Play sound
                    
                    [self.secondScreen showCrossMarkWithShipName:ship.name andIsOpponent:NO]; // SecondScreen

                    [self.map addCrossMarkWithShipName:ship.name];
                    
                    [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:ship.name];

                    [self.game.player.shipsArray removeObject:ship];

                    if (self.game.player.shipsArray.count == 0) {
                        
                        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(allShipsSunk) userInfo:nil repeats:NO];
                    }
                }
                break;
            }
        }
        
        if (isShipSunk) {
            break;
        }
    }
    return isShipSunk;
}

- (void)allShipsSunk {
    
    [self.secondScreen gameOverWithWinnerName:self.game.opponent.name];

    self.botView.msgLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
    self.botView.msgLbl.text = @"All your ships are sunk !";
    [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kAllShipsSunk];
    [self gameOverWith:NO];
}

- (void)btnClickedWithBtnTagStr:(NSString *)tagStr {
    
    [self playSoundWithSoundName:@"Fire" andType:@"mp3"];
    
    self.btnTag = tagStr.integerValue;
    [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:tagStr];
}

- (void)yourTurn {
    
    [self.secondScreen changeMapAlphaWith:YES]; // SecondScreen

    [UIView animateWithDuration:kAnimateDur animations:^{
        self.map.alpha = 0.0f;
        self.opponentMap.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.botView.msgLbl.text = @"It's your turn";
        self.opponentMap.userInteractionEnabled =YES;
    }];
}

- (void)startGame {

    [self.map removeAllCheckMarks];
    
    [self.botView readyToStartGameWith:self.isHost];
    
    if (self.game.isHost) {
        
        if (self.game.isOpponentReady) {
            
            [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kStartGame];
            
            [self.botView startCountDown];
            
        } else {
            
            self.botView.msgLbl.text = [NSString stringWithFormat:@"%@ is not ready", self.game.opponent.name];
        }
        
    } else {
        
        [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kIamReady];
    }

    
}

- (void)opponentsTurn {
    
    [self.secondScreen changeMapAlphaWith:NO]; // SecondScreen
    
    [UIView animateWithDuration:kAnimateDur animations:^{
        self.opponentMap.alpha = 0.0f;
        self.map.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.botView.msgLbl.text = [NSString stringWithFormat:@"It's %@' turn", self.game.opponent.name];
    }];
}

- (void)gameStarted {
    
    [self.map gameStarted];
    
    if (self.isHost) {

        int ranNum = arc4random() % 2;
        
        if (ranNum == 0 ) { // Host Start First
            
            [self yourTurn];
            
            [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kHostFirst];
            
        } else { // Client Start First
            
            [self.secondScreen changeMapAlphaWith:NO]; // SecondScreen
            
            self.botView.msgLbl.text = [NSString stringWithFormat:@"Its %@'s turn", self.game.opponent.name];
            
            [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kClientFirst];
        }
    }
}

- (void)setUpMapView {

    self.opponentMap = [[Map alloc] initWithFrame:self.view.frame andPlayerName:self.game.opponent.name andopponentName:self.game.player.name];
    [self.opponentMap gameStarted];
    self.opponentMap.delegate = self;
    [self.view addSubview:self.opponentMap];
    
    self.map = [[Map alloc] initWithFrame:self.view.frame andPlayerName:self.game.player.name andopponentName:self.game.opponent.name];
    self.map.delegate = self;
    [self.view addSubview:self.map];
}

- (void)setUpBottomView {
    
    self.botView = [[GameBottomVIew alloc] initWithMapViewFrame:self.map.frame andDeviceView:self.view];
    self.botView.delegate = self;
}

- (void)readyToPlaceShips {
    
    [self.game stopBrowingForPeers];
    
    [self setUpMapView];
    [self setUpBottomView];
    
    [UIView animateWithDuration:kAnimateDur animations:^{
        
        self.waitingForJoinView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.waitingForJoinView removeFromSuperview];
        self.waitingForJoinView = nil;
        
        [UIView animateWithDuration:kAnimateDur animations:^{
            
            self.map.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:kAnimateDur animations:^{
                
                self.botView.alpha = 1.0f;
                self.botView.shipImgView.alpha = 1.0f;
            }];
        }];
    }];
}

- (void)peerChangedStateWithNotification:(NSNotification *)notification {
    
    self.connectedPeers = [NSMutableArray arrayWithArray:[[notification userInfo] objectForKey:kConnectedPeers]];
    
    [self.waitingForJoinView.connectedPlayerNames removeAllObjects];
    
    for (MCPeerID *peer in self.connectedPeers) {
        [self.waitingForJoinView.connectedPlayerNames addObject:peer.displayName];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.waitingForJoinView.tableView reloadData];
    });
}

- (void)selectedPlayerName:(NSString *)name {
    
    NSArray *onePlayer;
    
    for (MCPeerID *peer in self.connectedPeers) {
        if ([peer.displayName isEqualToString:name]) {
            onePlayer = [NSArray arrayWithObject:peer];
            break;
        }
    }
    [self.game sendDataToOnePlayer:onePlayer WithDataStr:kInvite];
}

- (void)setUpWaitingForJoinView {
    
    self.waitingForJoinView = [[WaitingForPlayerToJoinView alloc] initWithFrame:self.view.frame andPlayerName:self.game.player.name and:self.isHost];
    self.waitingForJoinView.delegate = self;
    [self.view addSubview:self.waitingForJoinView];
}

#pragma mark - touch begin
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.map touchesMoved:touches withEvent:event withShipsArray:self.game.player.shipsArray and:self.botView.shipImgView];
    [self.botView touchesMoved:touches withEvent:event withView:self.view];
}

#pragma mark - touch end
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.map touchesEnded:touches withEvent:event withShipsArray:self.game.player.shipsArray and:self.botView];
}

- (void)allShipsAllPlaced {
    
    if (self.isHost) {
        [self.game sendDataToOnePlayer:self.game.opponentPeerID WithDataStr:kIamReady];
    }
    
    [self.botView hideBotViewShipImgVWith:self.isHost];
    [self.botView.startBtn addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
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

- (void)addNotification {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerChangedStateWithNotification:)
                                                 name:kChangeStateNotification
                                               object:nil];
}
@end
