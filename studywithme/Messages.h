//
//  Messages.h
//  studywithme
//
//  Created by Kevin Casey on 2/5/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import "JSQMessage.h"
#import "JSQMessages.h"

@class MessagesViewController;

@interface Messages : NSObject

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (weak, atomic) MessagesViewController *presenter;

- (void)reloadMessages;

@end
