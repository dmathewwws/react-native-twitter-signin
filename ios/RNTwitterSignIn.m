//
//  TwitterSignin.m
//  TwitterSignin
//
//  Created by Justin Nguyen on 22/5/16.
//  Copyright © 2016 Golden Owl. All rights reserved.
//

#import <TwitterKit/TWTRKit.h>
#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import "RNTwitterSignIn.h"

@implementation RNTwitterSignIn

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

NSString *twitterATName1 = @"twitterATName";
NSString *twitterATSName1 = @"twitterATSName";
NSString *twitterUName1 = @"twitterUName";
NSString *twitterUIDName1 = @"twitterUIDName";

RCT_EXPORT_METHOD(init: (NSString *)consumerKey consumerSecret:(NSString *)consumerSecret resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [[Twitter sharedInstance] startWithConsumerKey:consumerKey consumerSecret:consumerSecret];
}

RCT_EXPORT_METHOD(logIn: (RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        if (session) {

            [[NSUserDefaults standardUserDefaults] setObject:session.authToken forKey:twitterATName1];
            [[NSUserDefaults standardUserDefaults] setObject:session.authTokenSecret forKey:twitterATSName1];
            [[NSUserDefaults standardUserDefaults] setObject:session.userName forKey:twitterUName1];
            [[NSUserDefaults standardUserDefaults] setObject:session.userID forKey:twitterUIDName1];

            [[NSUserDefaults standardUserDefaults] synchronize];

            TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
            [client loadUserWithID:session.userID completion:^(TWTRUser * _Nullable user, NSError * _Nullable error) {
                NSDictionary *body = @{@"authToken": session.authToken,
                                       @"authTokenSecret": session.authTokenSecret,
                                       @"userID":user.userID,
                                       @"profileAvatarURL": user.profileImageURL,
                                       @"name":user.name};
                resolve(body);
            }];
        } else {
            reject(@"Error", @"Twitter signin error", error);
        }
    }];
}

RCT_EXPORT_METHOD(logOut)
{
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    [store logOutUserID:userID];
}
@end
