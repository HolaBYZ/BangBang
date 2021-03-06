//
//  FinishTaskView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "FinishTaskView.h"
#import "UserManager.h"
#import "TaskListCell.h"

@interface FinishTaskView  ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    UISearchBar *_searchBar;
    NSMutableArray<TaskModel*> *_taskArr;
    RBQFetchedResultsController *_inchargeFetchedResultsController;
    UITableView *_tableView;
}


@end

@implementation FinishTaskView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _taskArr = [@[] mutableCopy];
        _userManager = [UserManager manager];
        _inchargeFetchedResultsController = [_userManager createTaskFetchedResultsController:_userManager.user.currCompany.company_no];
        _inchargeFetchedResultsController.delegate = self;
        //创建搜索框
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        _searchBar.tintColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
        [_searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
        _searchBar.returnKeyType = UIReturnKeySearch;
        [self addSubview:_searchBar];
        
        [self getCurrData];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, MAIN_SCREEN_WIDTH, frame.size.height - 60) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskListCell" bundle:nil] forCellReuseIdentifier:@"TaskListCell"];
        [self addSubview:_tableView];
    }
    return self;
}
- (void)getCurrData {
    [_taskArr removeAllObjects];
    //获取完结的数据
    NSArray *array = [_userManager getTaskArr:_userManager.user.currCompany.company_no];
    for (TaskModel *model in array) {
        if(model.status == 0) continue;
        if(model.status == 7 || model.status == 8) {
            if([NSString isBlank:_searchBar.text]) {
                [_taskArr addObject:model];
            } else {
                if([model.descriptionStr rangeOfString:_searchBar.text].location != NSNotFound)
                    [_taskArr addObject:model];
            }
        }
    }
}
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    //主线程执行回调
    [self getCurrData];
    [_tableView reloadData];
}
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self endEditing:YES];
    [self getCurrData];
    [_tableView reloadData];
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListCell" forIndexPath:indexPath];
    cell.data = _taskArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(taskClicked:)]) {
        [self.delegate taskClicked:_taskArr[indexPath.row]];
    }
}

@end
