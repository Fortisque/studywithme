#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (void)alertToCheckInternet;
+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (void)alertWithMessage:(NSString *)message;
+ (void)setHeaderToBeTransparentForNavigationController: (UINavigationController *)navigationController;

@end
