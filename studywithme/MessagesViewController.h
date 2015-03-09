#import "JSQMessages.h"
#import "Messages.h"
#import "Helper.h"

@interface MessagesViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) Messages *data;

- (IBAction)refreshPressed:(id)sender;

@end
