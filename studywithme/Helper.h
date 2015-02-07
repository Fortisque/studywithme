//
//  Helper.h
//  studywithme
//
//  Created by Alice Jia Qi Liu on 2/6/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

+ (void)alertToCheckInternet;
+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (void)alertWithMessage:(NSString *)message;

@end
