#import "Messages.h"
#import "MessagesViewController.h"

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
    self.messages = [NSMutableArray new];
    [self loadNewMessages];
}

- (void)loadNewMessages {
    BuiltQuery *messageQuery = [BuiltQuery queryWithClassUID:@"message"];
    [messageQuery whereKey:@"study_group" equalTo:[_presenter.studyGroup objectForKey:@"uid"]];
    [messageQuery orderByAscending:@"datetime"];
    
    [messageQuery exec:^(QueryResult *result,  ResponseType type) {
        NSArray *res = [result getResult];
        
        for (int i = 0; i < [res count]; i++) {
            BuiltObject *tmp = [res objectAtIndex:i];
            
            JSQMessage *message = [self messageGivenBuiltObject:tmp];
            
            if ([self.messages indexOfObject:message] == NSNotFound) {
                [self.messages addObject:message];
            }
        }
        
        [self.presenter finishReceivingMessageAnimated:YES];
    } onError:^(NSError *error,  ResponseType type) {
        [Helper alertToCheckInternet];
        NSLog(@"%@", error.userInfo);
    }];
}

- (JSQMessage *)messageGivenBuiltObject:(BuiltObject *)obj
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    NSDate *date = [dateFormatter dateFromString:[obj objectForKey:@"datetime"]];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[obj objectForKey:@"sender_id"]
                                             senderDisplayName:[obj objectForKey:@"sender_display_name"]
                                                          date:date
                                                          text:[obj objectForKey:@"message"]];
    return message;
}

@end
