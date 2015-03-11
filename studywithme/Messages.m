#import "Messages.h"
#import "MessagesViewController.h"
#import <BuiltIO/BuiltIO.h>

@implementation Messages

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messages = [NSMutableArray new];
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self;
}

- (void)reloadMessages {
    // Resets all messages.
    self.messages = [NSMutableArray new];
    
    BuiltQuery *messageQuery = [BuiltQuery queryWithClassUID:@"message"];
    [messageQuery whereKey:@"study_group" equalTo:[_presenter.studyGroup objectForKey:@"uid"]];
    [messageQuery orderByAscending:@"datetime"];
    
    [messageQuery exec:^(QueryResult *result,  ResponseType type) {
        NSArray *res = [result getResult];
        
        for (int i = 0; i < [res count]; i++) {
            BuiltObject *tmp = [res objectAtIndex:i];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
            NSDate *date = [dateFormatter dateFromString:[tmp objectForKey:@"datetime"]];
            
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[tmp objectForKey:@"sender_id"]
                                                     senderDisplayName:[tmp objectForKey:@"sender_display_name"]
                                                                  date:date
                                                                  text:[tmp objectForKey:@"message"]];
            
            [self.messages addObject:message];
        }
        
        [self.presenter finishReceivingMessageAnimated:YES];
    } onError:^(NSError *error,  ResponseType type) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't retrieve messages"
                                                        message:@"Check your internet connection and try again"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"%@", error.userInfo);
    }];
}

@end
