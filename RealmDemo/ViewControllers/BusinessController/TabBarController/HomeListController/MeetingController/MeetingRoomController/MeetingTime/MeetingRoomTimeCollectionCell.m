//
//  MeetingRoomTimeCollectionCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingRoomTimeCollectionCell.h"

@interface MeetingRoomTimeCollectionCell ()
@property (weak, nonatomic) IBOutlet UIButton *buttonImage;
@end

@implementation MeetingRoomTimeCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.buttonImage.layer.cornerRadius = 2;
    self.buttonImage.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    MeetingRoomCellModel *model = self.data;
    self.buttonImage.backgroundColor = [UIColor whiteColor];
    //如果是过去的时间，就是灰色
    if(model.isDidDate == YES){
        self.buttonImage.backgroundColor = [UIColor darkGrayColor];
    }
    //用户选择的时间为绿色
    if(model.isUserSelectDate == YES) {
        self.buttonImage.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    }
    //如果有被占用的就是黄色
    if(model.haveMeet == YES) {
        self.buttonImage.backgroundColor = [UIColor siginColor];
    }
}
- (IBAction)timeClicked:(UIButton *)sender {
    MeetingRoomCellModel *model = self.data;
    if(model.haveMeet == NO && model.isDidDate == NO)
        if(model.isTodayDate == YES) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingRoomTime:)]) {
                [self.delegate MeetingRoomTime:self.data];
            }
        }
}

@end
