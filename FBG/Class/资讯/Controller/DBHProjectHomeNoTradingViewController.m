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
#import "DBHWebViewController.h"

#import "DBHProjectHomeHeaderView.h"
#import "DBHInputView.h"
#import "DBHProjectHomeNoTradingTableViewCell.h"
#import "DBHProjectHomeTypeTwoTableViewCell.h"

#import "DBHInformationDataModels.h"
#import "DBHProjectHomeNewsDataModels.h"
#import "DBHProjectDetailInformationDataModels.h"

static NSString *const kDBHProjectHomeNoTradingTableViewCellIdentifier = @"kDBHProjectHomeNoTradingTableViewCellIdentifier";
static NSString *const kDBHProjectHomeTypeTwoTableViewCellIdentifier = @"kDBHProjectHomeTypeTwoTableViewCellIdentifier";

@interface DBHProjectHomeNoTradingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *collectBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *personBarButtonItem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DBHInputView *keyboardView;

@property (nonatomic, assign) NSInteger currentPage; // 当前页
@property (nonatomic, strong) DBHProjectDetailInformationModelData *projectDetailModel;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation DBHProjectHomeNoTradingViewController

#pragma mark ------ Lifecycle ------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.projectModel.unit;
    
    [self setUI];
    [self addRefresh];
    
    self.currentPage = 1;
    [self getInfomation];
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
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBHProjectHomeTypeTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDBHProjectHomeTypeTwoTableViewCellIdentifier forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.section];
    
    return cell;
}

#pragma mark ------ UITableViewDelegate ------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBHProjectHomeNewsModelData *model = self.dataSource[indexPath.section];
    KKWebView *webView = [[KKWebView alloc] initWithUrl:[NSString stringWithFormat:@"http://inwecrypto.com/newsdetail2?art_id=%ld", (NSInteger)model.dataIdentifier]];
    webView.title = model.title;
    webView.isHaveShare = YES;
    [self.navigationController pushViewController:webView animated:YES];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DBHProjectHomeNewsModelData *model = self.dataSource[section];
    DBHProjectHomeHeaderView *headerView = [[DBHProjectHomeHeaderView alloc] init];
    headerView.time = model.updatedAt;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return AUTOLAYOUTSIZE(42);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AUTOLAYOUTSIZE(215.5);
}

#pragma mark ------ Data ------
/**
 获取项目资讯
 */
- (void)getInfomation {
    WEAKSELF
    [PPNetworkHelper GET:[NSString stringWithFormat:@"article?cid=%ld&per_page=5&page=%ld", (NSInteger)self.projectModel.dataIdentifier, self.currentPage] baseUrlType:3 parameters:nil hudString:nil responseCache:^(id responseCache) {
        if (weakSelf.dataSource.count) {
            return ;
        }
        
        [weakSelf.dataSource removeAllObjects];
        NSArray *dataArray = responseCache[@"data"];
        for (NSInteger i = dataArray.count - 1; i >= 0; i--) {
            DBHProjectHomeNewsModelData *model = [DBHProjectHomeNewsModelData modelObjectWithDictionary:dataArray[i]];
            
            [weakSelf.dataSource addObject:model];
        }
        
        [weakSelf.tableView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf scrollViewToBottom:NO];
        });
    } success:^(id responseObject) {
        [weakSelf endRefresh];
        
        if (weakSelf.currentPage == 1) {
            [weakSelf.dataSource removeAllObjects];
        }
        
        NSMutableArray *dataArray = [NSMutableArray array];
        NSArray *array = responseObject[@"data"];
        for (NSInteger i = array.count - 1; i >= 0; i--) {
            DBHProjectHomeNewsModelData *model = [DBHProjectHomeNewsModelData modelObjectWithDictionary:array[i]];
            
            [dataArray addObject:model];
        }
        
        if (weakSelf.currentPage == 1) {
            [weakSelf.dataSource addObjectsFromArray:dataArray];
        } else if (dataArray.count) {
            [weakSelf.dataSource insertObjects:dataArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataArray.count)]];
        }
        
        [weakSelf.tableView reloadData];
        if (weakSelf.currentPage == 1) {
            if (weakSelf.dataSource.count > 2) {
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[weakSelf.dataSource count] - 1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        } else if (dataArray.count) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:dataArray.count] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    } failure:^(NSString *error) {
        [weakSelf endRefresh];
        [LCProgressHUD showFailure:error];
    }];
}
/**
 获取项目详细信息
 */
- (void)getProjectDetailInfomation {
    WEAKSELF
    [PPNetworkHelper GET:[NSString stringWithFormat:@"category/%ld", (NSInteger)self.projectModel.dataIdentifier] baseUrlType:3 parameters:nil hudString:nil responseCache:^(id responseCache) {
        if (weakSelf.projectDetailModel) {
            return ;
        }
        
        weakSelf.projectDetailModel = [DBHProjectDetailInformationModelData modelObjectWithDictionary:responseCache];
        
        [weakSelf.tableView reloadData];
    } success:^(id responseObject) {
        weakSelf.projectDetailModel = [DBHProjectDetailInformationModelData modelObjectWithDictionary:responseObject];
        
        weakSelf.collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:weakSelf.projectDetailModel.categoryUser.isFavorite ? @"xiangmugaikuang_xing_s" : @"xiangmugaikuang_xing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(respondsToCollectBarButtonItem)];
        weakSelf.navigationItem.rightBarButtonItems = @[self.personBarButtonItem, self.collectBarButtonItem];
        
        [weakSelf.tableView reloadData];
    } failure:^(NSString *error) {
        [LCProgressHUD showFailure:error];
    }];
}
/**
 项目收藏
 */
- (void)projectCollet {
    NSDictionary *paramters = @{@"enable":self.projectDetailModel.categoryUser.isFavorite ? [NSNumber numberWithBool:false] : [NSNumber numberWithBool:true]};
    
    WEAKSELF
    [PPNetworkHelper PUT:[NSString stringWithFormat:@"category/%ld/collect", (NSInteger)self.projectModel.dataIdentifier] baseUrlType:3 parameters:paramters hudString:nil success:^(id responseObject) {
        NSString *is_favorite = responseObject[@"is_favorite"];
        weakSelf.projectDetailModel.categoryUser.isFavorite = is_favorite.integerValue == 1;
        weakSelf.collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:weakSelf.projectDetailModel.categoryUser.isFavorite ? @"xiangmugaikuang_xing_s" : @"xiangmugaikuang_xing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(respondsToCollectBarButtonItem)];
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

#pragma mark ------ Private Methods ------
/**
 滑动到底部
 */
- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}
/**
 添加刷新
 */
- (void)addRefresh {
    WEAKSELF
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.dataSource.count < weakSelf.currentPage * 5) {
            [weakSelf endRefresh];
            
            return ;
        }
        
        weakSelf.currentPage += 1;
        [weakSelf getInfomation];
    }];
}
/**
 结束刷新
 */
- (void)endRefresh {
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark ------ Getters And Setters ------
- (UIBarButtonItem *)collectBarButtonItem {
    if (!_collectBarButtonItem) {
        _collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:self.projectModel.categoryUser.isFavorite ? @"xiangmugaikuang_xing_s" : @"xiangmugaikuang_xing"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(respondsToCollectBarButtonItem)];
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
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerClass:[DBHProjectHomeNoTradingTableViewCell class] forCellReuseIdentifier:kDBHProjectHomeNoTradingTableViewCellIdentifier];
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
                    if (!weakSelf.projectModel.roomId) {
                        // 聊天室不存在
                        [LCProgressHUD showFailure:DBHGetStringWithKeyFromTable(@"The project has no chat room", nil)];
                        return ;
                    }
                    EaseMessageViewController *chatViewController = [[EaseMessageViewController alloc] initWithConversationChatter:[NSString stringWithFormat:@"%ld", (NSInteger)weakSelf.projectModel.roomId] conversationType:EMConversationTypeChatRoom];
                    chatViewController.title = weakSelf.projectModel.unit;
                    [weakSelf.navigationController pushViewController:chatViewController animated:YES];
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
                    historicalInformationViewController.projevtId = [NSString stringWithFormat:@"%ld", (NSInteger) weakSelf.projectModel.dataIdentifier];
                    [weakSelf.navigationController pushViewController:historicalInformationViewController animated:YES];
                    break;
                }
                case 3: {
                    // 项目介绍
                    DBHWebViewController *webViewController = [[DBHWebViewController alloc] init];
                    webViewController.isHiddenYourOpinion = YES;
                    webViewController.title = self.projectDetailModel.unit;
                    webViewController.htmlString = self.projectDetailModel.categoryPresentation.content;
                    [weakSelf.navigationController pushViewController:webViewController animated:YES];
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
