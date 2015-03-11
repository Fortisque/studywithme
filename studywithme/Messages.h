#import "JSQMessage.h"
#import "JSQMessages.h"

@class MessagesViewController;

@interface Messages : NSObject

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (weak, atomic) MessagesViewController *presenter;

- (void)loadNewMessages;

@end
