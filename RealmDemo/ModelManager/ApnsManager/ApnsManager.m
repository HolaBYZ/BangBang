//
//  ApnsManager.m
//  RealmDemo
//
//  Created by Mac on 16/7/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ApnsManager.h"
#import "UserManager.h"
#import "IdentityManager.h"

@interface ApnsManager () {
    UserManager *_userManager;
}

@end

@implementation ApnsManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        _userManager = [UserManager manager];
    }
    return self;
}

+ (instancetype)manager {
    static ApnsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ApnsManager alloc] init];
    });
    return manager;
}

//注册通知
- (void)registerNotification {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |UIUserNotificationTypeSound |UIUserNotificationTypeAlert)categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
//收到本地推送
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"notification_ring" ofType:@"mp3"];
    NSURL *url = [NSURL URLWithString:path];
    SystemSoundID ID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
    AudioServicesPlayAlertSound(ID);
    
    PushMessage *pushMessage = [[PushMessage alloc] initWithJSONDictionary:notification.userInfo];
    pushMessage.addTime = [NSDate date];
    [_userManager addPushMessage:pushMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecivePushMessage" object:pushMessage];
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

@end
