//
//  Game.m
//  LKBattleShip
//
//  Created by Yi Bin (Lewis) Feng on 2015-02-06.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import "Game.h"
#import "Player.h"

@interface Game () <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCPeerID  *peerID;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *nearbySA;
@property (nonatomic, strong) MCNearbyServiceBrowser    *nearbySB;

@property (nonatomic, assign) BOOL isThereAHost;

@end

@implementation Game

NSString *const kConnectedPeers                         = @"CONNECTEDPEERS";
NSString *const kServiceType                            = @"VFSJEOPARDY";
NSString *const kStartGame                              = @"STARTGAME";
NSString *const kChangeStateNotification                = @"DidChangeStateNotification";
NSString *const kDidReceiveDataNotification             = @"DidReceiveDataNotification";
NSString *const kClientAccept                           = @"ClientAccept";
NSString *const kReceivedMsgStr                         = @"ReceivedMsgStr";
NSString *const kPeerName                               = @"PeerName";
NSString *const kGenerateRandomQuestion                 = @"GenerateRandomQuestion";
NSString *const kPeerState                              = @"State";
NSString *const kUpdatePlayerScoreOnTopView             = @"UpdatePlayerScoreOnTopView";
NSString *const kDisableOptionBtns                      = @"DisableOptionBtns";
NSString *const kDidReceiveInvitation                   = @"DidReceiveInvitation";
NSString *const kGameover                               = @"GAMEOVER";

NSString *const kInvite                                 = @"INVITE";
NSString *const kAccept                                 = @"ACCEPT";
NSString *const kRefuse                                 = @"REFUSE";
NSString *const kIamReady                               = @"IAMREADY";
NSString *const kClientFirst                            = @"CLIENTFIRST";
NSString *const kHostFirst                              = @"HOSTFIRST";
NSString *const kMiss                                   = @"MISS";
NSString *const kHit                                    = @"HIT";
NSString *const kAllShipsSunk                           = @"ALLSHIPSSUNK";

CGFloat const kAnimateDur               = 1.0f;
CGFloat const kCountDownDur             = 3.0f;

- (void)lookingForHost {
    
    MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:@"LOOKINGFORHOST"];
    self.nearbySA = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID discoveryInfo:nil serviceType:kServiceType];
    self.nearbySA.delegate = self;
    [self.nearbySA startAdvertisingPeer];
}


- (void)stopAdvertisingPeer {
    
    [self.nearbySA stopAdvertisingPeer];
    self.nearbySA.delegate = nil;
    self.nearbySA = nil;
}

- (id)initWithPlayerName:(NSString *)name and:(BOOL)isHost {
    
    if (self = [super init]) {
        
        self.isOpponentReady = NO;
        self.isOver = NO;
        self.isStarted = NO;
        
        self.isHost = isHost;
        
        MCPeerID *myPeerID = [[MCPeerID alloc] initWithDisplayName:name];
        self.mySession = [[MCSession alloc] initWithPeer:myPeerID];
        self.mySession.delegate = self;
        
        self.nearbySA = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerID discoveryInfo:nil serviceType:kServiceType];
        self.nearbySA.delegate = self;
        
        self.nearbySB = [[MCNearbyServiceBrowser alloc] initWithPeer:myPeerID serviceType:kServiceType];
        self.nearbySB.delegate = self;
        
        self.player = [[Player alloc] initWithPlayerName:name];
        
        if (isHost) {
            [self.nearbySB startBrowsingForPeers];
        } else {
            [self.nearbySA startAdvertisingPeer];
        }
    }
    return self;
}

- (void)stopBrowingForPeers {
    [self.nearbySB stopBrowsingForPeers];
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    if (state != MCSessionStateConnecting) {

        NSDictionary *userInfo = @{kPeerName : peerID.displayName, kPeerState : @(state), kConnectedPeers : self.mySession.connectedPeers};
        

        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification
                                                            object:nil
                                                          userInfo:userInfo];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSString *receivedMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Received msg from %@ - %@", peerID.displayName, receivedMsg);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([receivedMsg isEqualToString:kInvite]) { // Server -> Client

            self.opponent = [[Player alloc] initWithPlayerName:peerID.displayName];

            if (self.delegate && [self.delegate respondsToSelector:@selector(opponentReceivedInvitationFrom:)]) {
                [self.delegate opponentReceivedInvitationFrom:peerID.displayName];
            }
            
            for (MCPeerID *peer in self.mySession.connectedPeers) {
                if ([peer.displayName isEqualToString:peerID.displayName]) {
                    self.opponentPeerID = [NSArray arrayWithObject:peer];
                    break;
                }
            }
            
        } else if ([receivedMsg isEqualToString:kStartGame]) { // Server -> Client
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(opponentReceivedStartGame)]) {
                [self.delegate opponentReceivedStartGame];
            }
            
        } else if ([receivedMsg isEqualToString:kClientFirst]) { // Server -> Client
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(clientFirst)]) {
                [self.delegate clientFirst];
            }

        } else if ([receivedMsg isEqualToString:kHostFirst]) { // Server
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(hostFirst)]) {
                [self.delegate hostFirst];
            }

        } else if ([receivedMsg isEqualToString:kAccept]) {  // Client -> Server
        
            self.opponent = [self opponentWith:peerID.displayName];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(opponentAcceptInvitation)]) {
                [self.delegate opponentAcceptInvitation];
            }  
        
        }  else if ([receivedMsg isEqualToString:kRefuse]) {  // Client -> Server

            self.opponent = [self opponentWith:peerID.displayName];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(opponentRefusedInvitation)]) {
                [self.delegate opponentRefusedInvitation];
            }
            
        } else if ([receivedMsg isEqualToString:kIamReady]) { // Client -> Server
            
            self.isOpponentReady = YES;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(opponentIsReady)]) {
                [self.delegate opponentIsReady];
            }

        } else if ([receivedMsg isEqualToString:kMiss]) { // Server && Client

            if (self.delegate && [self.delegate respondsToSelector:@selector(miss)]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(miss)]) {
                    [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(miss) userInfo:nil repeats:NO];
                }
            }
            
        } else if ([receivedMsg isEqualToString:kHit]) { // Server && Client
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(hit)]) {
                [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(hit) userInfo:nil repeats:NO];
            }
            
        } else if ([receivedMsg isEqualToString:kAllShipsSunk]) { // Server && Client
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(youWin)]) {
                [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(allShipsSunk) userInfo:nil repeats:NO];
            }
            
            self.winnerName = peerID.displayName;
            
        }  else if ([receivedMsg isEqualToString:@"AircraftCarrier"] || // Server && Client
                    [receivedMsg isEqualToString:@"Battleship"]      ||
                    [receivedMsg isEqualToString:@"Cruiser"]         ||
                    [receivedMsg isEqualToString:@"Destroyer"]       ||
                    [receivedMsg isEqualToString:@"Submarine"]
                    ) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(shipSunkWithShipName:)]) {
                [self.delegate shipSunkWithShipName:receivedMsg];
            }
            
        } else { // // Server || Client  Btn Tag
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(btnClicked:)]) {
                [self.delegate btnClicked:receivedMsg.integerValue];
            }
        }
    });
}

- (Player *)opponentWith:(NSString *)peerDisplayName {
    
    for (MCPeerID *peer in self.mySession.connectedPeers) {
        if ([peer.displayName isEqualToString:peerDisplayName]) {
            self.opponentPeerID = [NSArray arrayWithObject:peer];
            break;
        }
    }
    
    return  [[Player alloc] initWithPlayerName:peerDisplayName];
}

- (void)allShipsSunk {
    
    [self.delegate youWin];
}

- (void)hit {
    
    [self.delegate hit];
}

- (void)miss {
    
    [self.delegate miss];
}

- (void)sendDataToOnePlayer:(NSArray *)onePlayer WithDataStr:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.mySession sendData:data toPeers:onePlayer withMode:MCSessionSendDataReliable error:nil];
}

- (void)sendDataWith:(NSString *)string {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.mySession sendData:data toPeers:self.mySession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}





#pragma mark -  Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiveInvitation
                                                        object:nil
                                                      userInfo:nil];
    
    invitationHandler(YES, self.mySession);
}

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    [self.nearbySB invitePeer:peerID toSession:self.mySession withContext:nil timeout:60.0f];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    //NSLog(@"didNotStartBrowsingForPeers");
}


- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}


@end
