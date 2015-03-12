#import <UIKit/UIKit.h>

#import "Helper.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
