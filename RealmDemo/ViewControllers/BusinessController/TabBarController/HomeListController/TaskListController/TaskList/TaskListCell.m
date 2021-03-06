//
//  TaskListCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskListCell.h"
#import "TaskModel.h"

@interface TaskListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *taskStatusImage;//任务状态图片
@property (weak, nonatomic) IBOutlet UILabel *taskCreateName;//任务创建者名字
@property (weak, nonatomic) IBOutlet UILabel *taskDestr;//任务描述
@property (weak, nonatomic) IBOutlet UILabel *taskTimeStr;//任务剩余/超过/未接受标签
@property (weak, nonatomic) IBOutlet UILabel *taskCreateTime;//任务创建时间
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentWidth;//是否有附件
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remindWidth;//是否有提醒

@end

@implementation TaskListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    self.attachmentWidth.constant = self.remindWidth.constant = 13;
    TaskModel *model = self.data;
    //任务状态图片
    if(model.status == 1) {//新建
        self.taskStatusImage.image = [UIImage imageNamed:@"ic_task_new"];
    } else if (model.status == 2 || model.status == 4 || model.status == 6) {//进行中
        self.taskStatusImage.image = [UIImage imageNamed:@"ic_task_ing"];
    } else if (model.status == 7) {//已完成
        self.taskStatusImage.image = [UIImage imageNamed:@"ic_task_finish"];
    } else if (model.status == 8) {//已终止
        self.taskStatusImage.image = [UIImage imageNamed:@"ic_task_end"];
    }
    //任务创建者名字
    self.taskCreateName.text = model.create_realname;
    //任务详情
    if([NSString isBlank:model.descriptionStr])
        self.taskDestr.text = @"无任务描述";
    else
        self.taskDestr.text = model.descriptionStr;
    //任务创建时间
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:model.createdon_utc / 1000];
    self.taskCreateTime.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",createDate.year,createDate.month,createDate.day,createDate.hour,createDate.minute];
    //是否有附件
    if(model.attachment_count == 0)
        self.attachmentWidth.constant = 0;
    //是否有提醒
    if([NSString isBlank:model.alert_date_list])
        self.remindWidth.constant = 0;
    //任务剩余/超过/未接受标签
    if(model.status == 1) {//新建
        self.taskTimeStr.text = @"未接受";
        self.taskTimeStr.textColor = [UIColor redColor];
    } else if (model.status == 2 || model.status == 4 || model.status == 6) {//进行中
        int64_t timeDate = model.enddate_utc / 1000 - [NSDate date].timeIntervalSince1970;
        //是不是超时了
        if(timeDate < 0) {
            timeDate = -timeDate;
            self.taskTimeStr.text = [NSString stringWithFormat:@"超：%d天%d时%d分",timeDate / (24 * 60 * 60),(timeDate % (24 * 60 * 60)) / (60 * 60),(timeDate % (60 * 60)) / 60];
            self.taskTimeStr.textColor = [UIColor redColor];
        } else {
            self.taskTimeStr.text = [NSString stringWithFormat:@"余：%d天%d时%d分",timeDate / (24 * 60 * 60),(timeDate % (24 * 60 * 60)) / (60 * 60),(timeDate % (60 * 60)) / 60];
            self.taskTimeStr.textColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
        }
    } else if (model.status == 7) {//已完成
        self.taskTimeStr.text = @"已完成";
        self.taskTimeStr.textColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    } else if (model.status == 8) {//已终止
        self.taskTimeStr.text = @"已终止";
        self.taskTimeStr.textColor = [UIColor redColor];
    }

}
@end
