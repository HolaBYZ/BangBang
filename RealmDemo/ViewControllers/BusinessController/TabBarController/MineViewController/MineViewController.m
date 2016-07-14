//
//  MineViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/14.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MineViewController.h"
#import "BushManageViewController.h"
#import "UserManager.h"

@interface MineViewController ()<RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    RBQFetchedResultsController *_userFetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMood;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //把视图移动到最顶部 即使有状态栏和导航
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    User *user = _userManager.user;
    self.avaterImage.layer.cornerRadius = 30.f;
    self.avaterImage.clipsToBounds = YES;
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = [NSString stringWithFormat:@"%@(%@)",user.real_name,@(user.user_no)];
    self.userMood.text = user.mood;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            BushManageViewController *bushManager = [BushManageViewController new];
            bushManager.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:bushManager animated:YES];
        } else {
            
        }
    }
}
@end
