//
//  LeftMenuController.m
//  RealmDemo
//
//  Created by Mac on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LeftMenuController.h"
#import "UserManager.h"
#import "LeftMenuCell.h"
#import "MineInfoEditController.h"
#import "BushSearchViewController.h"

@interface LeftMenuController ()<UITableViewDataSource,UITableViewDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;//用户管理器
    NSMutableArray<Company*> *_companyArr;//圈子数组
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_commpanyFetchedResultsController;//圈子数据监听
}
@property (weak, nonatomic) IBOutlet UIImageView *avaterImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMood;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager  = [UserManager manager];
    _companyArr = [@[] mutableCopy];
    _commpanyFetchedResultsController = [_userManager createCompanyFetchedResultsController];
    _commpanyFetchedResultsController.delegate = self;
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    User *user = _userManager.user;
    self.avaterImageView.layer.cornerRadius = 35.f;
    self.avaterImageView.clipsToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuCell" bundle:nil] forCellReuseIdentifier:@"LeftMenuCell"];
    self.tableView.tableFooterView = [UIView new];
    //设置用户信息
    [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = user.real_name;
    self.userMood.text = user.mood;
    //设置圈子信息 只显示自己状态为1或者4的
    for (Company *company in [_userManager getCompanyArr]) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [_companyArr addObject:company];
        }
    }
    [self.tableView reloadData];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _userFetchedResultsController) {
        User *user = controller.fetchedObjects[0];
        [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        self.userName.text = user.real_name;
        self.userMood.text = user.mood;
        [_tableView reloadData];//圈子变化了也要刷新表格视图
    } else {
        [_companyArr removeAllObjects];
        //只显示自己状态为4或者1的
        for (Company *company in (id)controller.fetchedObjects) {
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
            if(employee.status == 1 || employee.status == 4) {
                [_companyArr addObject:company];
            }
        }
        [_tableView reloadData];
    }
}
//加入圈子被点击
- (IBAction)joinCompanyClicked:(id)sender {
    BushSearchViewController *bush = [BushSearchViewController new];
    [self.navigationController pushViewController:bush animated:YES];
    //隐藏菜单控制器
    [self.frostedViewController hideMenuViewController];
}
//头像被点击
- (IBAction)avaterClicked:(id)sender {
    MineInfoEditController *mine = [MineInfoEditController new];
    [self.navigationController pushViewController:mine animated:YES];
    //隐藏菜单控制器
    [self.frostedViewController hideMenuViewController];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftMenuCell" forIndexPath:indexPath];
    cell.data = _companyArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //改变用户当前圈子
    Company *company = [_companyArr[indexPath.row] deepCopy];
    User *user = [_userManager.user deepCopy];
    user.currCompany = company;
    [_userManager updateUser:user];
    //刷新表格视图
    [_tableView reloadData];
    //隐藏菜单控制器
    [self.frostedViewController hideMenuViewController];
}
@end
