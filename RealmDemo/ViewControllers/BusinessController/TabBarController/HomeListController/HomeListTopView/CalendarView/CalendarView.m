//
//  CalendarView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarView.h"
#import "UserManager.h"
#import "LineProgressLayer.h"

@interface CalendarView ()<RBQFetchedResultsControllerDelegate> {
    int _todayFinishCount;//今天完成数
    int _todayNoFinishCount;//今天未完成数
    int _weekFinishCount;//本周完成数
    int _weekNoFinishCount;//本周未完成数
    
    LineProgressLayer *leftLayer;
    LineProgressLayer *leftScondLayer;
    LineProgressLayer *rightLayer;
    LineProgressLayer *rightScondLayer;
    
    UserManager *_userManager;
    RBQFetchedResultsController *_calendarFetchedResultsController;
}
@property (weak, nonatomic) IBOutlet UIButton *todayFinish;
@property (weak, nonatomic) IBOutlet UILabel *todayNoFinish;
@property (weak, nonatomic) IBOutlet UILabel *todayAll;

@property (weak, nonatomic) IBOutlet UIButton *weekFinish;
@property (weak, nonatomic) IBOutlet UILabel *weekNoFinish;
@property (weak, nonatomic) IBOutlet UILabel *weekAll;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@end

@implementation CalendarView

- (void)setupUI {
    self.userInteractionEnabled = YES;
    _userManager = [UserManager manager];
    _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
    _calendarFetchedResultsController.delegate = self;
    //给这几个数字填充值
    [self getCurrCount];
    //添加动画
    [self createPie];
    [_userManager addCalendarNotfition];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    _todayFinishCount = _todayNoFinishCount = _weekFinishCount = _weekNoFinishCount = 0;
    //给这几个数字填充值
    [self getCurrCount];
    //添加动画
    [self createPie];
    [_userManager addCalendarNotfition];
}
- (void)createPie {
    [leftLayer removeFromSuperlayer];
    [leftScondLayer removeFromSuperlayer];
    [rightLayer removeFromSuperlayer];
    [rightScondLayer removeFromSuperlayer];
    //今天
    float tempValue = _todayFinishCount / (float)(_todayNoFinishCount + _todayFinishCount);
    leftLayer = [LineProgressLayer layer];
    leftLayer.bounds = self.leftView.bounds;
    leftLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
    leftLayer.contentsScale = [UIScreen mainScreen].scale;
    leftLayer.color = [UIColor colorWithRed:43 / 255.f green:181 / 255.f blue:162 / 255.f alpha:1];
    if (_todayFinishCount + _todayNoFinishCount == 0) {
        
    }else{
        leftLayer.animationDuration = 1.0 * 1.5;
        leftLayer.completed = 1.0 *leftLayer.total;
        leftLayer.completedColor = [UIColor colorWithRed:251 / 255.f green:214 / 255.f blue:66 / 255.f alpha:1];
    }
    [leftLayer setNeedsDisplay];
    [leftLayer showAnimate];
    [self.leftView.layer insertSublayer:leftLayer atIndex:0];
    leftScondLayer = [LineProgressLayer layer];
    leftScondLayer.bounds = self.leftView.bounds;
    leftScondLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
    leftScondLayer.contentsScale = [UIScreen mainScreen].scale;
    leftScondLayer.animationDuration = tempValue * 1.5;
    leftScondLayer.completed = tempValue *leftLayer.total;
    leftScondLayer.color = [UIColor clearColor];
    leftScondLayer.completedColor = [UIColor colorFromHexCode:@"0x0ab499"];
    [leftScondLayer setNeedsDisplay];
    [leftScondLayer showAnimate];
    [self.leftView.layer insertSublayer:leftScondLayer above:leftLayer];
    //本周
    //本月的数据面板
    float finishValue = _weekFinishCount / (float)(_weekNoFinishCount + _weekFinishCount);
    rightLayer = [LineProgressLayer layer];
    rightLayer.bounds = self.rightView.bounds;
    rightLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
    rightLayer.contentsScale = [UIScreen mainScreen].scale;
    rightLayer.color = [UIColor colorWithRed:43 / 255.f green:181 / 255.f blue:162 / 255.f alpha:1];
    if (_weekNoFinishCount + _weekFinishCount == 0) {
        
    } else {
        rightLayer.animationDuration = 1.0 * 1.5;
        rightLayer.completed = 1.0 *rightLayer.total;
        rightLayer.completedColor = [UIColor colorWithRed:251 / 255.f green:214 / 255.f blue:66 / 255.f alpha:1];
    }
    [rightLayer setNeedsDisplay];
    [rightLayer showAnimate];
    [self.rightView.layer insertSublayer:rightLayer atIndex:0];
    
    rightScondLayer = [LineProgressLayer layer];
    rightScondLayer.bounds = self.rightView.bounds;
    rightScondLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
    rightScondLayer.contentsScale = [UIScreen mainScreen].scale;
    rightScondLayer.animationDuration = finishValue * 1.5;
    rightScondLayer.completed = finishValue *rightLayer.total;
    rightScondLayer.color = [UIColor clearColor];
    rightScondLayer.completedColor = [UIColor colorFromHexCode:@"0x0ab499"];
    [rightScondLayer setNeedsDisplay];
    [rightScondLayer showAnimate];
    [self.rightView.layer insertSublayer:rightScondLayer above:rightLayer];
}
//获取这四个数字
- (void)getCurrCount {
    //先获取今天的
    NSDate *todayDate = [NSDate date];
    NSArray *todayArr = [_userManager getCalendarArrWithDate:todayDate];
    for (Calendar *tempCalendar in todayArr) {
        if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
            if(tempCalendar.status == 1)
                _todayNoFinishCount ++;
            else
                _todayFinishCount ++;
        } else {//重复的要加上经过自己一天的
            if (tempCalendar.rrule.length > 0&&tempCalendar.r_begin_date_utc >0&&tempCalendar.r_end_date_utc>0) {
                Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                //得到所有的时间
                NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                for (NSDate *tempDate in occurences) {
                    if(tempDate.year == todayDate.year && tempDate.month == todayDate.month && tempDate.day == todayDate.day) {
                        if([tempCalendar haveDeleteDate:tempDate]) {
                            continue;
                        } else if([tempCalendar haveFinishDate:tempDate]) {
                            _todayFinishCount ++;
                        } else {
                            _todayNoFinishCount ++;
                        }
                    }
                }
            }
        }
    }
    //再获取本周的 今天是本周的第几天
    int todayOfWeek = (int)todayDate.weekday;
    for (int i = 1 ;i <= 7; i ++) {
        NSDate *tempDate = [todayDate dateByAddingTimeInterval:(i - todayOfWeek) * 24 * 60 * 60];
        NSArray *tempArr = [_userManager getCalendarArrWithDate:tempDate];
        for (Calendar *tempCalendar in tempArr) {
            if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
                if(tempCalendar.status == 1)
                    _weekNoFinishCount ++;
                else
                    _weekFinishCount ++;
            } else {//重复的要加上经过自己一天的
                if (tempCalendar.rrule.length > 0&&tempCalendar.r_begin_date_utc >0&&tempCalendar.r_end_date_utc>0) {
                    Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                    //得到所有的时间
                    NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                    for (NSDate *tempDateDate in occurences) {
                        if(tempDateDate.year == tempDate.year && tempDateDate.month == tempDate.month && tempDateDate.day == tempDate.day) {
                            if([tempCalendar haveDeleteDate:tempDate]) {
                                continue;
                            } else if([tempCalendar haveFinishDate:tempDate]) {
                                _weekFinishCount ++;
                            } else {
                                _weekNoFinishCount ++;
                            }
                        }
                    }
                }
            }
        }
    }
    [self.todayFinish setTitle:[NSString stringWithFormat:@"%d",_todayFinishCount] forState:UIControlStateNormal];
    self.todayNoFinish.text = [NSString stringWithFormat:@"%d",_todayNoFinishCount];
    self.todayAll.text = [NSString stringWithFormat:@"%d",_todayFinishCount + _todayNoFinishCount];
    [self.weekFinish setTitle:[NSString stringWithFormat:@"%d",_weekFinishCount] forState:UIControlStateNormal];
    self.weekNoFinish.text = [NSString stringWithFormat:@"%d",_weekNoFinishCount];
    self.weekAll.text = [NSString stringWithFormat:@"%d",_weekFinishCount + _weekNoFinishCount];
}
- (IBAction)todayClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(todayFinishCalendar)]) {
        [self.delegate todayFinishCalendar];
    }
}
- (IBAction)weekClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(weekFinishCalendar)]) {
        [self.delegate weekFinishCalendar];
    }
}

@end
