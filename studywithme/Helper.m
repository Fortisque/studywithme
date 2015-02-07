//
//  Helper.m
//  studywithme
//
//  Created by Alice Jia Qi Liu on 2/6/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)alertWithMessage:(NSString *)message {
    if ([message length] == 0) {
        message = @"Please check your internet";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)alertToCheckInternet {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong!"
                                                    message:@"Please check your internet"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

    
}

@end
