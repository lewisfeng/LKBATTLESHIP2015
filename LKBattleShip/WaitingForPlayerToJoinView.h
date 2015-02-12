//
//  WaitingForPlayerToJoinView.h
//  LKBattleShip
//
//  Created by Lewisk.Feng on 2015-02-07.
//  Copyright (c) 2015 VFS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WaitingForJoinDelegate <NSObject>


@optional

- (void)selectedPlayerName:(NSString *)name;

- (void)playerChoseRefuseTo:(NSString *)playerName;
- (void)playerChoseAcceptTo:(NSString *)playerName;

@end

@interface WaitingForPlayerToJoinView : UIView

@property (nonatomic, strong) id<WaitingForJoinDelegate> delegate;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *connectedPlayerNames;

- (id)initWithFrame:(CGRect)frame andPlayerName:(NSString *)name and:(BOOL)isHost;

- (void)receivedInviteFromPlayer:(NSString *)playerName;

- (void)opponentRefusedInvitationWith:(NSString *)name;

@end
