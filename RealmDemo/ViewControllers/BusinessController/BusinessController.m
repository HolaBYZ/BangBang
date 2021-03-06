//
//  BusinessController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BusinessController.h"
#import "REFrostedViewController.h"
#import "LeftMenuController.h"
#import "RequestManagerController.h"
#import "BushManageViewController.h"
#import "WebNonstandarViewController.h"
#import "RepCalendarDetailController.h"
#import "ComCalendarDetailViewController.h"
#import "TabBarController.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "TaskModel.h"
#import "IdentityManager.h"
#import "TaskDetailController.h"

@interface BusinessController () {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    UINavigationController *_businessNav;//这个导航用于弹出通知信息，是业务模块的根控制器
}
@end

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    REFrostedViewController *_rEFrostedView = [[REFrostedViewController alloc] initWithContentViewController:[TabBarController new] menuViewController:[LeftMenuController new]];
    _rEFrostedView.direction = REFrostedViewControllerDirectionLeft;
    _rEFrostedView.menuViewSize = CGSizeMake(MAIN_SCREEN_WIDTH*3/4, MAIN_SCREEN_HEIGHT + 44);
    _rEFrostedView.liveBlur = YES;
    //创建业务根视图控制器
    _businessNav = [[UINavigationController alloc] initWithRootViewController:_rEFrostedView];
    [self addChildViewController:_businessNav];
    [_businessNav.view willMoveToSuperview:self.view];
    [_businessNav willMoveToParentViewController:self];
    [_businessNav setNavigationBarHidden:YES animated:YES];
    _businessNav.navigationBar.translucent = NO;
    _businessNav.navigationBar.barTintColor = [UIColor homeListColor];
    [self.view addSubview:_businessNav.view];
    //加上新消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecivePushMessage:) name:@"DidRecivePushMessage" object:nil];
    // Do any additional setup after loading the view.
}
//在这里统一处理弹窗
- (void)didRecivePushMessage:(NSNotification*)notification {
    PushMessage *message = notification.object;
    //如果是圈子操作
    if([message.type isEqualToString:@"COMPANY"]) {
        //是否有操作
        if ([message.action isEqualToString:@"GENERAL"]) { //都不管 因为要不停的弹出来 很烦
//            [_businessNav pushViewController:[RequestManagerController new] animated:YES];
        } else {
            //其他的不用管
        }
    } else if ([message.type isEqualToString:@"TASK"]) {//任务推送
        //获取任务详情 弹窗
        [UserHttp getTaskInfo:message.target_id.intValue handler:^(id data, MError *error) {
            [self dismissTips];
            if(error) {
                [self showFailureTips:error.statsMsg];
                return ;
            }
            TaskModel *taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
            taskModel.descriptionStr = data[@"description"];
            [_userManager upadteTask:taskModel];
            
            TaskDetailController *task = [TaskDetailController new];
            task.data = taskModel;
            [self.navigationController pushViewController:task animated:YES];
        }];
    } else if([message.type isEqualToString:@"WORKTIP"]){//上下班提醒
        
    } else if([message.type isEqualToString:@"TASK_COMMENT_STATUS"]){//任务评论推送
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTaskInfo" object:message];
    } else if([message.type isEqualToString:@"TASKTIP"]) { //任务提醒推送 进入任务详情
        for (TaskModel *taskModel in [_userManager getTaskArr:message.company_no]) {
            if(message.target_id.intValue == taskModel.id) {
                TaskDetailController *task = [TaskDetailController new];
                task.data = taskModel;
                [self.navigationController pushViewController:task animated:YES];
                break;
            }
        }
    } else if([message.type isEqualToString:@"CALENDARTIP"]) {//日程提醒 进入日程详情
        for (Calendar *calendar in [_userManager getCalendarArr]) {
            if(calendar.id == message.target_id.intValue) {
                //展示详情
                if(calendar.repeat_type == 0) {
                    ComCalendarDetailViewController *com = [ComCalendarDetailViewController new];
                    com.data = calendar;
                    [self.navigationController pushViewController:com animated:YES];
                } else {
                    RepCalendarDetailController *com = [RepCalendarDetailController new];
                    com.data = calendar;
                    [self.navigationController pushViewController:com animated:YES];
                }
                break;
            }
        }
    } else if([message.type isEqualToString:@"CALENDAR"]){ //日程推送 分享日程
        NSData *calendarData = [message.entity dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *sharedCalendar = [[Calendar alloc] initWithJSONDictionary:calendarDic];
        sharedCalendar.descriptionStr = calendarDic[@"description"];
        //展示详情
        if(sharedCalendar.repeat_type == 0) {
            ComCalendarDetailViewController *com = [ComCalendarDetailViewController new];
            com.data = sharedCalendar;
            [self.navigationController pushViewController:com animated:YES];
        } else {
            RepCalendarDetailController *com = [RepCalendarDetailController new];
            com.data = sharedCalendar;
            [self.navigationController pushViewController:com animated:YES];
        }
    }else if ([message.type isEqualToString:@"REQUEST"]) {//网页
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@request/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    }else if ([message.type isEqualToString:@"APPROVAL"]){//通用审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Approval/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if ([message.type isEqualToString:@"NEW_APPROVAL"]){//审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@ApprovalByFormBuilder/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MAIL"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Mail/Details?id=%@&isSend=false&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MEETING"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Meeting/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"VOTE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Vote/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"NOTICE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@NOTICE/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    }
}
@end
