//
//  DBHProjectHomeNoTradingViewController.m
//  FBG
//
//  Created by 邓毕华 on 2018/1/26.
//  Copyright © 2018年 ButtonRoot. All rights reserved.
//

#import "DBHProjectHomeNoTradingViewController.h"

#import "DBHProjectLookViewController.h"
#import "DBHProjectOverviewNoTradingViewController.h"
#import "DBHHistoricalInformationViewController.h"

#import "DBHProjectHomeHeaderView.h"
#import "DBHInputView.h"
#import "DBHProjectHomeTypeTwoTableViewCell.h"

#import "DBHInformationDataModels.h"
#import "DBHProjectHomeNewsDataModels.h"
#import "DBHProjectDetailInformationDataModels.h"

static NSString *const kDBHProjectHomeTypeTwoTableViewCellIdentifier = @"kDBHProjectHomeTypeTwoTableViewCellIdentifier";

@interface DBHProjectHomeNoTradingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *collectBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *personBarButtonItem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBHInputView *keyboardView;

@property (nonatomic, strong) DBHProjectDetailInformationModelDataBase *projectDetailModel;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation DBHProjectHomeNoTradingViewController

#pragma mark ------ Lifecycle ------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.projectModel.unit;
    
    [self setUI];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getProjectDetailInfomation];
}

#pragma mark ------ UI ------
- (void)setUI {
    self.navigationItem.rightBarButtonItems = @[self.personBarButtonItem, self.collectBarButtonItem];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.keyboardView];
    
    WEAKSELF
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.view);
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.keyboardView.mas_top);
    }];
    [self.keyboardView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.view);
        make.height.offset(AUTOLAYOUTSIZE(47));
        make.centerX.bottom.equalTo(weakSelf.view);
    }];
}

#pragma mark ------ UITableViewDataSource ------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + (self.projectDetailModel.lastArticle ? 1 : 0);
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBHProjectHomeTypeTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDBHProjectHomeTypeTwoTableViewCellIdentifier forIndexPath:indexPath];
    if (!indexPath.section) {
        cell.projectModel = self.projectModel;
    } else {
        cell.lastModel = self.projectDetailModel.lastArticle;
    }
    
    return cell;
}

#pragma mark ------ UITableViewDelegate ------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!section) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = COLORFROM10(235, 235, 235, 1);
        return headerView;
    } else {
        DBHProjectHomeHeaderView *headerView = [[DBHProjectHomeHeaderView alloc] init];
        headerView.time = self.projectDetailModel.lastArticle.createdAt;
        return headerView;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return !section ? AUTOLAYOUTSIZE(25) : AUTOLAYOUTSIZE(42);
}

#pragma mark ------ Data ------
///**
// 获取项目资讯
// */
//- (void)getInfomation {
//    WEAKSELF
//    [PPNetworkHelper GET:[NSString stringWithFormat:@"article?cid=%ld", (NSInteger)self.projectModel.dataIdentifier] baseUrlType:3 parameters:nil hudString:nil responseCache:^(id responseCache) {
//        if (weakSelf.dataSource.count) {
//            return ;
//        }
//
//        [weakSelf.dataSource removeAllObjects];
//
//        for (NSDictionary *dic in responseCache[@"data"]) {
//            DBHProjectHomeNewsModelData *model = [DBHProjectHomeNewsModelData modelObjectWithDictionary:dic];
//
//            [weakSelf.dataSource addObject:model];
//        }
//
//        [weakSelf.tableView reloadData];
//    } success:^(id responseObject) {
//        [weakSelf.dataSource removeAllObjects];
//
//        for (NSDictionary *dic in responseObject[@"data"]) {
//            DBHProjectHomeNewsModelData *model = [DBHProjectHomeNewsModelData modelObjectWithDictionary:dic];
//
//            [weakSelf.dataSource addObject:model];
//        }
//
//        [weakSelf.tableView reloadData];
//    } failure:^(NSString *error) {
//        [LCProgressHUD showFailure:error];
//    }];
//}
/**
 获取项目详细信息
 */
- (void)getProjectDetailInfomation {
    WEAKSELF
    [PPNetworkHelper GET:[NSString stringWithFormat:@"category/%ld", (NSInteger)self.projectModel.dataIdentifier] baseUrlType:3 parameters:nil hudString:nil responseCache:^(id responseCache) {
        if (weakSelf.projectDetailModel) {
            return ;
        }
        
        self.projectDetailModel = [DBHProjectDetailInformationModelDataBase modelObjectWithDictionary:responseCache];
        
        [weakSelf.tableView reloadData];
    } success:^(id responseObject) {
        self.projectDetailModel = [DBHProjectDetailInformationModelDataBase modelObjectWithDictionary:responseObject];
        
        [weakSelf.tableView reloadData];
    } failure:^(NSString *error) {
        [LCProgressHUD showFailure:error];
    }];
}
/**
 项目收藏
 */
- (void)projectCollet {
    NSDictionary *paramters = @{@"enable":self.projectModel.categoryUser.categoryId == 0 ? [NSNumber numberWithBool:true] : [NSNumber numberWithBool:false]};
    
    WEAKSELF
    [PPNetworkHelper PUT:[NSString stringWithFormat:@"category/%ld/collect", (NSInteger)self.projectModel.dataIdentifier] baseUrlType:3 parameters:paramters hudString:nil success:^(id responseObject) {
        weakSelf.projectModel.categoryUser.categoryId = weakSelf.projectModel.categoryUser.categoryId == 0 ? 1 : 0;
        weakSelf.collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:self.projectModel.categoryUser.categoryId == 0 ? @"xiangmugaikuang_xing" : @"xiangmuzhuye_xing_cio"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(respondsToCollectBarButtonItem)];
        weakSelf.navigationItem.rightBarButtonItems = @[self.personBarButtonItem, self.collectBarButtonItem];
    } failure:^(NSString *error) {
        [LCProgressHUD showFailure:error];
    }];
}

#pragma mark ------ Event Responds ------
/**
 收藏
 */
- (void)respondsToCollectBarButtonItem {
    [self projectCollet];
}
/**
 项目查看
 */
- (void)respondsToPersonBarButtonItem {
    DBHProjectLookViewController *projectLookViewController = [[DBHProjectLookViewController alloc] init];
    projectLookViewController.projectModel = self.projectModel;
    [self.navigationController pushViewController:projectLookViewController animated:YES];
}

#pragma mark ------ Getters And Setters ------
- (UIBarButtonItem *)collectBarButtonItem {
    if (!_collectBarButtonItem) {
        _collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:self.projectModel.categoryUser.categoryId == 0 ? @"xiangmugaikuang_xing" : @"xiangmuzhuye_xing_cio"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(respondsToCollectBarButtonItem)];
    }
    return _collectBarButtonItem;
}
- (UIBarButtonItem *)personBarButtonItem {
    if (!_personBarButtonItem) {
        _personBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"xiangmuzhuye_ren_ico"] style:UIBarButtonItemStylePlain target:self action:@selector(respondsToPersonBarButtonItem)];
    }
    return _personBarButtonItem;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = COLORFROM10(235, 235, 235, 1);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.rowHeight = AUTOLAYOUTSIZE(215.5);
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerClass:[DBHProjectHomeTypeTwoTableViewCell class] forCellReuseIdentifier:kDBHProjectHomeTypeTwoTableViewCellIdentifier];
    }
    return _tableView;
}
- (DBHInputView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[DBHInputView alloc] init];
        _keyboardView.dataSource = @[@{@"value":@"Project Overview", @"isMore":@"0"},
                                     @{@"value":@"Project Information", @"isMore":@"0"},
                                     @{@"value":@"Project Introduction", @"isMore":@"0"}];
        
        WEAKSELF
        [_keyboardView clickButtonBlock:^(NSInteger buttonType) {
            switch (buttonType) {
                case 0: {
                    // 聊天室
                    
                    break;
                }
                case 1: {
                    // 项目概况
                    DBHProjectOverviewNoTradingViewController *projectOverviewNoTradingViewController = [[DBHProjectOverviewNoTradingViewController alloc] init];
                    projectOverviewNoTradingViewController.projectDetailModel = self.projectDetailModel;
                    [weakSelf.navigationController pushViewController:projectOverviewNoTradingViewController animated:YES];
                    break;
                }
                case 2: {
                    // 项目资讯
                    DBHHistoricalInformationViewController *historicalInformationViewController = [[DBHHistoricalInformationViewController alloc] init];
                    [weakSelf.navigationController pushViewController:historicalInformationViewController animated:YES];
                    break;
                }
                case 3: {
                    // 项目介绍
                    break;
                }
                    
                default:
                    break;
            }
        }];
    }
    return _keyboardView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
