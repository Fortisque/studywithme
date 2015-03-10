#import "FeedbackViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _feedbackTextView.layer.cornerRadius = 5;
    _feedbackTextView.layer.borderColor = [[UIColor colorWithRed:0.35 green:0.54 blue:0.83 alpha:1.0] CGColor];
    _feedbackTextView.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)onSubmit:(id)sender {
    if (_feedbackTextView.text.length == 0) {
        [Helper alertWithTitle:@"No Message" andMessage:@"Cannot submit without a message!"];
    } else {
        [BuiltExtension  executeWithName:@"sendFeedback"
                                    data:@{@"feedback": _feedbackTextView.text, @"from": [[BuiltUser currentUser] objectForKey:@"email"]}
                               onSuccess:^(id response) {
                                   // response will contain the response of the extension method
                                   // here, the response is the user profile, with the authtoken
                                   [Helper alertWithTitle:@"Yay!" andMessage:@"Thank you for your feedback!"];
                                   _feedbackTextView.text = @"";
                               } onError:^(NSError *error) {
                                   // error block in case of any error
                                   [Helper alertToCheckInternet];
                                   NSLog(@"%@", error);
                               }];
    }
}

@end
