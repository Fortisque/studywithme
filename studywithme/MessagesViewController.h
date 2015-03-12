#import "Helper.h"
#import "JSQMessages.h"
#import "Messages.h"

@interface MessagesViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) Messages *data;
@property (strong, nonatomic) NSDictionary *studyGroup;

@end
