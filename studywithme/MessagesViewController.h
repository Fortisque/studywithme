//
//  MessagesViewController.h
//  studywithme
//
//  Created by Kevin Casey on 2/5/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import "JSQMessages.h"
#import "Messages.h"

@interface MessagesViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) Messages *data;
- (IBAction)refreshPressed:(id)sender;

@end
