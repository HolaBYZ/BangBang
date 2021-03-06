//
//  NoResultView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "NoResultView.h"

@implementation NoResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *iamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_result_icon"]];
        iamgeView.frame = CGRectMake(0.5 * (frame.size.width - iamgeView.frame.size.width), 50, iamgeView.frame.size.width, iamgeView.frame.size.height);
        [self addSubview:iamgeView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iamgeView.frame) + 20, frame.size.width, 10)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"帮帮未找到该地址哦~~";
        [self addSubview:label];
    }
    return self;
}

@end
