//
//  Game.h
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-06.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class Player;

@protocol GameDelegate <NSObject>

@optional

- (void)opponentReceivedInvitationFrom:(NSString *)name;    // Client
- (void)opponentAcceptInvitation;                           // Server
- (void)opponentRefusedInvitation;                          // Server
- (void)opponentIsReady;                                    // Server
- (void)opponentReceivedStartGame;                          // Client
- (void)hostFirst;                                          // Server
- (void)clientFirst;                                        // Client
- (void)miss;                                               // Server && Client
- (void)hit;                                                // Server && Client
- (void)btnClicked:(NSInteger)tag;                          // Server && Client
- (void)youWin;                                             // Server && Client
- (void)shipSunkWithShipName:(NSString *)shipName;          // Server && Client

@end

@interface Game : NSObject

extern NSString *const kConnectedPeers;
extern NSString *const kServiceType;
extern NSString *const kStartGame;
extern NSString *const kChangeStateNotification;
extern NSString *const kDidReceiveDataNotification;
extern NSString *const kClientAccept;
extern NSString *const kReceivedMsgStr;
extern NSString *const kPeerName;
extern NSString *const kPeerState;
extern NSString *const kGenerateRandomQuestion;
extern NSString *const kUpdatePlayerScoreOnTopView;
extern NSString *const kDisableOptionBtns;
extern NSString *const kDidReceiveInvitation;
extern NSString *const kGameover;

extern NSString *const kInvite;
extern NSString *const kAccept;
extern NSString *const kRefuse;
extern NSString *const kIamReady;
extern NSString *const kClientFirst;
extern NSString *const kHostFirst;
extern NSString *const kHit;
extern NSString *const kMiss;
extern NSString *const kAllShipsSunk;

extern CGFloat const kAnimateDur;
extern CGFloat const kCountDownDur;

@property (nonatomic, strong) id<GameDelegate> delegate;

- (id)initWithPlayerName:(NSString *)name and:(BOOL)isHost;
- (void)sendDataToOnePlayer:(NSArray *)onePlayer WithDataStr:(NSString *)string; // send client bg tag

- (void)sendDataWith:(NSString *)string;

- (void)stopAdvertisingPeer;

- (void)stopBrowingForPeers;

- (void)lookingForHost;

@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) Player *opponent;

@property (nonatomic, copy) NSString *winnerName;

@property (nonatomic, copy) NSArray *opponentPeerID;

@property (nonatomic, assign) BOOL isOpponentReady;

@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) BOOL isOver;

@end
