//
//  TransactionListVC.m
//  FBG
//
//  Created by 贾仕海 on 2017/8/25.
//  Copyright © 2017年 ButtonRoot. All rights reserved.
//

#import "TransactionListVC.h"

#import "PPNetworkCache.h"

#import "TransactionListHeaderView.h"
#import "TransactionListCell.h"
#import "TransferVC.h"
#import "ReceivablesVC.h"
#import "ScanVC.h"
#import "ConfirmationTransferVC.h"
#import "WalletOrderModel.h"
#import "TransactionInfoVC.h"
#import "DBHNEOTransferVC.h"

@interface TransactionListVC () <UITableViewDelegate, UITableViewDataSource, ScanVCDelegate>

/** 数据源 */
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) TransactionListHeaderView * headerView;
@property (nonatomic, strong) UIButton * transferButton;    //转账
@property (nonatomic, strong) UIButton * receivablesButton;    //收款

@property (nonatomic, assign) NSInteger page; // 分页
@property (nonatomic, assign) BOOL isRequestSuccess; // 是否请求成功
@property (nonatomic, assign) BOOL isCanTransferAccounts; // 是否可以转账
@property (nonatomic, assign) NSString * maxBlockNumber;  //最大块号 当前
@property (nonatomic, copy) NSString * blockPerSecond;  //发生时间  5
@property (nonatomic, copy) NSString * minBlockNumber;  //最小块号 确认 12

/** 计时器 */
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation TransactionListVC

#pragma mark - Lifecycle(生命周期)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coustromTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 55 - 64);
    self.coustromTableView.rowHeight = 80;
    [self addpull2RefreshWithTableView:self.coustromTableView WithIsInset:NO];
    //    [self addPush2LoadMoreWithTableView:self.coustromTableView WithIsInset:NO];
    self.coustromTableView.tableHeaderView = self.headerView;
    
    self.blockPerSecond = @"10";
    self.minBlockNumber = @"12";
    
    [self.view addSubview:self.coustromTableView];
    [self.view addSubview:self.transferButton];
    [self.view addSubview:self.receivablesButton];
    
    WEAKSELF
    [self.coustromTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.view);
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.transferButton.mas_top);
    }];
    [self.transferButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.view).multipliedBy(0.5);
        make.height.offset(AUTOLAYOUTSIZE(55));
        make.left.bottom.equalTo(weakSelf.view);
    }];
    [self.receivablesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(weakSelf.transferButton);
        make.right.bottom.equalTo(weakSelf.view);
    }];
    
    if (self.tokenModel)
    {
        if ([self.tokenModel.flag isEqualToString:@"NEO"] || [self.tokenModel.flag isEqualToString:@"Gas"]) {
            self.headerView.headImage.image = [UIImage imageNamed:self.tokenModel.icon];
            if ([self.tokenModel.flag isEqualToString:@"NEO"]) {
                self.headerView.priceLB.text = [NSString stringWithFormat:@"%.0f", [self.tokenModel.balance floatValue]];
            } else {
                self.headerView.priceLB.text = [NSString stringWithFormat:@"%.8f", [self.tokenModel.balance floatValue]];
            }
            if ([UserSignData share].user.walletUnitType == 1)
            {
                self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈￥%.2f", self.tokenModel.price_cny.floatValue];
            }
            else
            {
                self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈$%.2f", self.tokenModel.price_usd.floatValue];
            }
        } else {
            [self.headerView.headImage sdsetImageWithURL:self.tokenModel.icon placeholderImage:Default_General_Image];
        }
        [self loadBanlaceData];
    }
    else
    {
        self.headerView.headImage.image = [UIImage imageNamed:self.model.category_name];
        self.headerView.priceLB.text = [NSString stringWithFormat:@"%.4f", [self.banlacePrice floatValue]];
        self.headerView.cnyPriceLB.text = self.cnybanlacePrice;
    }
    
    [self addRefresh];
    [self getOrderListCache];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![UserSignData share].user.isCode)
    {
        if (self.model.category_id == 2) {
            [self countDownTime];
            [self timerDown];
        } else {
            [self loadData];
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
    //别忘了删除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)timerDown
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil]; //监听是否触发home键挂起程序.
    //开始计时
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.blockPerSecond intValue] target:self selector:@selector(countDownTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    //    self.timer.fireDate = [NSDate distantPast];
}

- (void)countDownTime
{
    //10s 请求一次接口
    if (self.model.category_id == 2) {
        [self loadNeoDataIsLoadMore:NO];
    } else {
        [self loadMaxblockNumber];
    }
    [self loadBanlaceData];
}

- (void)appHasGoneInForeground:(NSNotification *)notification
{
    //从后台唤醒
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    //切换到后台
    [self.timer setFireDate:[NSDate distantFuture]];
}

#pragma mark - Custom Accessors (控件响应方法)

- (void)transferButtonClicked
{
    //转账
    if ([UserSignData share].user.isCode)
    {
        //冷钱包扫描
        ScanVC * vc = [[ScanVC alloc] init];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if (self.tokenModel)
        {
            //代币
            if (self.model.category_id == 2) {
                if (!self.isRequestSuccess) {
                    [LCProgressHUD showFailure:@"订单列表尚未加载完成"];
                    
                    return;
                }
                if (!self.isCanTransferAccounts) {
                    [LCProgressHUD showFailure:@"您还有未完成的订单!请稍后重试!"];
                    
                    return;
                }
                
                // NEO钱包转账
                DBHNEOTransferVC * vc = [[DBHNEOTransferVC alloc] init];
                vc.model = self.model;
                vc.tokenModel = self.tokenModel;
                vc.banlacePrice = _banlacePrice;
                vc.walletBanlacePrice = self.WalletbanlacePrice;
                vc.defaultGasNum = self.tokenModel.gas;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                // ETH钱包转账
                TransferVC * vc = [[TransferVC alloc] init];
                vc.model = self.model;
                vc.tokenModel = self.tokenModel;
                vc.banlacePrice = _banlacePrice;
                vc.walletBanlacePrice = self.WalletbanlacePrice;
                vc.defaultGasNum = self.tokenModel.gas;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            //转账
            if (self.model.category_id == 2) {
                // NEO钱包转账
                DBHNEOTransferVC * vc = [[DBHNEOTransferVC alloc] init];
                vc.model = self.model;
                vc.banlacePrice = self.banlacePrice;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                // ETH钱包转账
                TransferVC * vc = [[TransferVC alloc] init];
                vc.model = self.model;
                vc.banlacePrice = self.banlacePrice;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    
    
}

- (void)receivablesButtonClicked
{
    //收款
    if ([UserSignData share].user.isCode)
    {
        //冷钱包
        ReceivablesVC * vc = [[ReceivablesVC alloc] init];
        vc.model = self.model;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if (self.tokenModel)
        {
            //代币
            ReceivablesVC * vc = [[ReceivablesVC alloc] init];
            vc.tokenModel = self.tokenModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            //ETH
            ReceivablesVC * vc = [[ReceivablesVC alloc] init];
            vc.model = self.model;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

#pragma mark - IBActions(xib响应方法)


#pragma mark - Public (.h 公共调用方法)


#pragma mark - Private (.m 私有方法)
- (void)loadBanlaceData
{
    if ([self.tokenModel.flag isEqualToString:@"NEO"] || [self.tokenModel.flag isEqualToString:@"Gas"]) {
        // NEO Gas
        //代币余额
        [PPNetworkHelper GET:[NSString stringWithFormat:@"conversion/%d", self.model.id] isOtherBaseUrl:NO parameters:nil hudString:nil success:^(id responseObject)
         {
             NSDictionary *record = responseObject[@"record"];
             NSString *neoPriceForCny = record[@"cap"][@"price_cny"];
             NSString *neoPriceForUsd = record[@"cap"][@"price_usd"];
             NSArray *gny = record[@"gnt"];
             NSDictionary *gas = gny.firstObject;
             NSString *gasPriceForCny = gas[@"cap"][@"price_cny"];
             NSString *gasPriceForUsd = gas[@"cap"][@"price_usd"];
             NSString *neoNumber = [NSString stringWithFormat:@"%@", record[@"balance"]];
             NSString *gasNumber = [NSString stringWithFormat:@"%@", gas[@"balance"]];
             NSString *price = [self.tokenModel.flag isEqualToString:@"NEO"] ? neoNumber : gasNumber;
             NSString *price_cny = [self.tokenModel.flag isEqualToString:@"NEO"] ? neoPriceForCny : gasPriceForCny;
             NSString *price_usd = [self.tokenModel.flag isEqualToString:@"NEO"] ? neoPriceForUsd : gasPriceForUsd;
             
             if ([self.tokenModel.flag isEqualToString:@"NEO"]) {
                 self.banlacePrice = [NSString stringWithFormat:@"%.0f", [price floatValue]];
             } else {
                 self.banlacePrice = [NSString stringWithFormat:@"%.8f", [price floatValue]];
             }
             self.headerView.priceLB.text = self.banlacePrice;
             if ([UserSignData share].user.walletUnitType == 1)
             {
                 self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈￥%.2f",[[NSString DecimalFuncWithOperatorType:2 first:price secend:price_cny value:2] floatValue]];
             }
             else
             {
                 self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈$%.2f",[[NSString DecimalFuncWithOperatorType:2 first:price secend:price_usd value:2] floatValue]];
             }
         }failure:^(NSString *error)
         {
             [LCProgressHUD showFailure:error];
         }];
    } else if ([self.model.category_name isEqualToString:@"ETH"] && !self.tokenModel) {
        NSMutableDictionary * parametersDic = [[NSMutableDictionary alloc] init];
        [parametersDic setObject:[@[@(self.model.id)] toJSONStringForArray] forKey:@"wallet_ids"];
        
        [PPNetworkHelper GET:@"conversion" isOtherBaseUrl:NO parameters:parametersDic hudString:nil success:^(id responseObject)
         {
             if ([[responseObject objectForKey:@"list"] count] > 0)
             {
                 
                 for (NSDictionary * dic in [responseObject objectForKey:@"list"])
                 {
                     if (![NSString isNulllWithObject:[dic objectForKey:@"balance"]])
                     {
                         self.banlacePrice = [NSString DecimalFuncWithOperatorType:3 first:[NSString numberHexString:[[dic objectForKey:@"balance"] substringFromIndex:2]] secend:@"1000000000000000000" value:4];
                     }
                     else
                     {
                         self.banlacePrice = [NSString DecimalFuncWithOperatorType:3 first:@"0" secend:@"1000000000000000000" value:4];
                     }
                     self.headerView.priceLB.text = [NSString stringWithFormat:@"%.4f",[self.banlacePrice floatValue]];
                     
                     if ([UserSignData share].user.walletUnitType == 1)
                     {
                         NSString * price_cny = [NSString DecimalFuncWithOperatorType:2 first:self.banlacePrice secend:[[[dic objectForKey:@"category"] objectForKey:@"cap"] objectForKey:@"price_cny"] value:4];
                         self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈￥%.2f",[price_cny floatValue]];
                     }
                     else
                     {
                         NSString * price_usd = [NSString DecimalFuncWithOperatorType:2 first:self.banlacePrice secend:[[[dic objectForKey:@"category"] objectForKey:@"cap"] objectForKey:@"price_usd"] value:4];
                         self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈$%.2f",[price_usd floatValue]];
                     }
                 }
             }
         } failure:^(NSString *error)
         {
             [LCProgressHUD showFailure:error];
         }];
    } else {
        //代币余额
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:self.model.address forKey:@"address"];
        [dic setObject:self.tokenModel.address forKey:@"contract"];
        
        [PPNetworkHelper POST:@"extend/balanceOf" parameters:dic hudString:@"加载中..." success:^(id responseObject)
         {
             NSString * price = [[responseObject objectForKey:@"value"] substringFromIndex:2];
             self.banlacePrice = [NSString stringWithFormat:@"%.4f",[[NSString DecimalFuncWithOperatorType:3 first:[NSString numberHexString:price] secend:@"1000000000000000000" value:4] floatValue]];
             
             self.headerView.priceLB.text = [NSString stringWithFormat:@"%.4f",[self.banlacePrice floatValue]];
             if ([UserSignData share].user.walletUnitType == 1)
             {
                 self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈￥%.2f",[[NSString DecimalFuncWithOperatorType:2 first:self.banlacePrice secend:self.tokenModel.price_cny value:2] floatValue]];
             }
             else
             {
                 self.headerView.cnyPriceLB.text = [NSString stringWithFormat:@"≈$%.2f",[[NSString DecimalFuncWithOperatorType:2 first:self.banlacePrice secend:self.tokenModel.price_usd value:2] floatValue]];
             }
             
         } failure:^(NSString *error)
         {
             [LCProgressHUD showFailure:error];
         }];
    }
    
}

- (void)loadData
{
    //获取最小块高  默认12
    [PPNetworkHelper GET:@"min-block" isOtherBaseUrl:NO parameters:nil hudString:@"加载中..." success:^(id responseObject)
     {
         self.minBlockNumber = [responseObject objectForKey:@"min_block_num"];
         
         //获取轮询时间 当前块发生速度  最小5秒
         [PPNetworkHelper POST:@"extend/blockPerSecond" parameters:nil hudString:nil success:^(id responseObject)
          {
              self.blockPerSecond = [NSString stringWithFormat:@"%f",1 / [[responseObject objectForKey:@"bps"] floatValue]];
              [self timerDown];
              [self loadMaxblockNumber];
              
          } failure:^(NSString *error)
          {
          }];
         
    } failure:^(NSString *error)
    {
    }];
}

- (void)loadMaxblockNumber
{
    //当前最大块号  //轮询这个
    [PPNetworkHelper POST:@"extend/blockNumber" parameters:nil hudString:nil success:^(id responseObject)
     {
         self.maxBlockNumber = [NSString stringWithFormat:@"%@",[NSString numberHexString:[[responseObject objectForKey:@"value"] substringFromIndex:2]]];
         
         if (self.model.category_id == 2) {
             [self loadNeoDataIsLoadMore:NO];
         } else {
             [self loadOtherDataIsLoadMore:NO];
         }
         
     } failure:^(NSString *error)
     {
     }];
}
- (void)getOrderListCache {
    if (![NSString isNulllWithObject:[PPNetworkCache getResponseCacheForKey:[NSString stringWithFormat:@"wallet-order/%@/%d", [self.tokenModel.flag isEqualToString:@"NEO"] ? @"neo" : @"gas",  self.model.id]]])
    {
        NSDictionary *responseCache = [PPNetworkCache getResponseCacheForKey:[NSString stringWithFormat:@"wallet-order/%@/%d", [self.tokenModel.flag isEqualToString:@"NEO"] ? @"neo" : @"gas",  self.model.id]];
        if (self.model.category_id == 2) {
            if (![NSString isNulllWithObject:[responseCache objectForKey:@"list"]])
            {
                [self.dataSource removeAllObjects];
                
                for (NSDictionary * dic in [responseCache objectForKey:@"list"])
                {
                    WalletOrderModel * model = [[WalletOrderModel alloc] init];
                    model.trade_no = dic[@"tx"];
                    model.created_at = dic[@"createTime"];
                    model.fee = dic[@"value"];
                    model.flag = self.tokenModel.flag;
                    model.maxBlockNumber = self.maxBlockNumber;
                    model.minBlockNumber = self.minBlockNumber;
                    model.pay_address = dic[@"from"];
                    model.receive_address = dic[@"to"];
                    model.finished_at = dic[@"confirmTime"];
                    model.remark = dic[@"remark"];
                    model.handle_fee = @"0.00";
                    if ([dic[@"from"] isEqualToString:self.model.address] && [dic[@"to"] isEqualToString:self.model.address]) {
                        model.isMySelf = YES;
                    } else {
                        model.isMySelf = NO;
                        
                        if ([dic[@"from"] isEqualToString:self.model.address])
                        {
                            //热钱包 eth
                            //转账
                            model.isReceivables = NO;
                        }
                        else
                        {
                            //收款
                            model.isReceivables = YES;
                        }
                    }
                    [self.dataSource addObject:model];
                }
                [self.coustromTableView reloadData];
            }
        } else {
            if (![NSString isNulllWithObject:[responseCache objectForKey:@"list"]])
            {
                [self.dataSource removeAllObjects];
                
                for (NSDictionary * dic in [responseCache objectForKey:@"list"])
                {
                    WalletOrderModel * model = [[WalletOrderModel alloc] initWithDictionary:dic];
                    model.maxBlockNumber = self.maxBlockNumber;
                    model.minBlockNumber = self.minBlockNumber;
                    model.flag = [NSObject isNulllWithObject:self.tokenModel] ? @"ether" : [self.tokenModel.flag lowercaseString];
                    if ([dic[@"from"] isEqualToString:self.model.address] && [dic[@"to"] isEqualToString:self.model.address]) {
                        model.isMySelf = YES;
                    } else {
                        model.isMySelf = NO;
                        
                        if ([model.pay_address isEqualToString:self.model.address])
                        {
                            //热钱包 eth
                            //转账
                            model.isReceivables = NO;
                        }
                        else
                        {
                            //收款
                            model.isReceivables = YES;
                        }
                    }
                    [self.dataSource addObject:model];
                }
                [self.coustromTableView reloadData];
            }
        }
        }
}
- (void)loadOtherDataIsLoadMore:(BOOL)isLoadMore {
    if (isLoadMore) {
        self.page += 1;
    } else {
        self.page = 0;
    }
    WEAKSELF
    NSMutableDictionary * parametersDic = [[NSMutableDictionary alloc] init];
    [parametersDic setObject:@(self.model.id) forKey:@"wallet_id"];
    [parametersDic setObject:@(self.page) forKey:@"page"];
    [parametersDic setObject:self.tokenModel ? self.tokenModel.name : self.model.category_name forKey:@"flag"];
    [parametersDic setObject:!self.tokenModel ? @"0x0000000000000000000000000000000000000000" : [self.tokenModel.address lowercaseString] forKey:@"asset_id"];
    
    //包含事务块高  列表   （当前块高-订单里的块高）/最小块高
    [PPNetworkHelper GET:@"wallet-order" isOtherBaseUrl:NO parameters:parametersDic hudString:nil responseCache:^(id responseCache) {
//        if (![NSString isNulllWithObject:[responseCache objectForKey:@"list"]])
//        {
//            [self.dataSource removeAllObjects];
//
//            for (NSDictionary * dic in [responseCache objectForKey:@"list"])
//            {
//                WalletOrderModel * model = [[WalletOrderModel alloc] initWithDictionary:dic];
//                model.maxBlockNumber = self.maxBlockNumber;
//                model.minBlockNumber = self.minBlockNumber;
//                model.flag = [NSObject isNulllWithObject:self.tokenModel] ? @"ether" : [self.tokenModel.flag lowercaseString];
//                if ([dic[@"from"] isEqualToString:self.model.address] && [dic[@"to"] isEqualToString:self.model.address]) {
//                    model.isMySelf = YES;
//                } else {
//                    model.isMySelf = NO;
//
//                    if ([model.pay_address isEqualToString:self.model.address])
//                    {
//                        //热钱包 eth
//                        //转账
//                        model.isReceivables = NO;
//                    }
//                    else
//                    {
//                        //收款
//                        model.isReceivables = YES;
//                    }
//                }
//                [self.dataSource addObject:model];
//            }
//            [self.coustromTableView reloadData];
//        }
    } success:^(id responseObject) {
        [weakSelf endRefresh];
        if (![NSString isNulllWithObject:[responseObject objectForKey:@"list"]])
        {
            weakSelf.isRequestSuccess = YES;
            if (!isLoadMore) {
                [self.dataSource removeAllObjects];
            }
            
            NSArray *data = responseObject;
            if (data.count < 10) {
                [weakSelf.coustromTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            for (NSDictionary * dic in [responseObject objectForKey:@"list"])
            {
                WalletOrderModel * model = [[WalletOrderModel alloc] initWithDictionary:dic];
                model.maxBlockNumber = self.maxBlockNumber;
                model.minBlockNumber = self.minBlockNumber;
                model.flag = [NSObject isNulllWithObject:self.tokenModel] ? @"ether" : [self.tokenModel.flag lowercaseString];
                if ([dic[@"from"] isEqualToString:self.model.address] && [dic[@"to"] isEqualToString:self.model.address]) {
                    model.isMySelf = YES;
                } else {
                    model.isMySelf = NO;
                    
                    if ([model.pay_address isEqualToString:self.model.address])
                    {
                        //热钱包 eth
                        //转账
                        model.isReceivables = NO;
                    }
                    else
                    {
                        //收款
                        model.isReceivables = YES;
                    }
                }
                [self.dataSource addObject:model];
            }
            [self.coustromTableView reloadData];
        } else {
            [weakSelf.coustromTableView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSString *error) {
        [weakSelf endRefresh];
        [LCProgressHUD showFailure:error];
    }];
}
- (void)loadNeoDataIsLoadMore:(BOOL)isLoadMore {
    if (isLoadMore) {
        self.page += 1;
    } else {
        self.page = 0;
    }
    WEAKSELF
    NSMutableDictionary * parametersDic = [[NSMutableDictionary alloc] init];
    [parametersDic setObject:@(self.model.id) forKey:@"wallet_id"];
    [parametersDic setObject:@"NEO" forKey:@"flag"];
    [parametersDic setObject:@(self.page) forKey:@"page"];
    [parametersDic setObject:[self.tokenModel.flag isEqualToString:@"NEO"] ? @"0xc56f33fc6ecfcd0c225c4ab356fee59390af8560be0e930faebe74a6daff7c9b" : @"0x602c79718b16e442de58778e148d0b1084e3b2dffd5de6b7b16cee7969282de7" forKey:@"asset_id"];
    
    //包含事务块高  列表   （当前块高-订单里的块高）/最小块高
    [PPNetworkHelper GET:@"wallet-order" isOtherBaseUrl:NO parameters:parametersDic hudString:nil responseCache:^(id responseCache) {
//        if (![NSString isNulllWithObject:[responseCache objectForKey:@"list"]])
//        {
//            weakSelf.isRequestSuccess = YES;
//            [self.dataSource removeAllObjects];
//
//            for (NSDictionary * dic in [responseCache objectForKey:@"list"])
//            {
//                WalletOrderModel * model = [[WalletOrderModel alloc] init];
//                model.trade_no = dic[@"tx"];
//                model.created_at = dic[@"createTime"];
//                model.fee = dic[@"value"];
//                model.flag = self.tokenModel.flag;
//                model.maxBlockNumber = self.maxBlockNumber;
//                model.minBlockNumber = self.minBlockNumber;
//                model.pay_address = dic[@"from"];
//                model.receive_address = dic[@"to"];
//                model.finished_at = dic[@"confirmTime"];
//                model.remark = dic[@"remark"];
//                model.handle_fee = @"0.00";
//                if ([dic[@"from"] isEqualToString:self.model.address] && [dic[@"to"] isEqualToString:self.model.address]) {
//                    model.isMySelf = YES;
//                } else {
//                    model.isMySelf = NO;
//
//                    if ([dic[@"from"] isEqualToString:self.model.address])
//                    {
//                        //热钱包 eth
//                        //转账
//                        model.isReceivables = NO;
//                    }
//                    else
//                    {
//                        //收款
//                        model.isReceivables = YES;
//                    }
//                }
//                [self.dataSource addObject:model];
//            }
//            self.isCanTransferAccounts = NO;
//            [self.coustromTableView reloadData];
//        }
    } success:^(id responseObject) {
        weakSelf.isRequestSuccess = YES;
        [weakSelf endRefresh];
        if (![NSString isNulllWithObject:[responseObject objectForKey:@"list"]])
        {
            if (!isLoadMore) {
                [self.dataSource removeAllObjects];
            }
            
            NSArray *data = responseObject[@"list"];
            if (data.count < 10) {
                [weakSelf.coustromTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            BOOL isHaveNoFinishOrder = NO;
            for (NSDictionary * dic in [responseObject objectForKey:@"list"])
            {
                WalletOrderModel * model = [[WalletOrderModel alloc] init];
                model.trade_no = dic[@"tx"];
                model.created_at = dic[@"createTime"];
                model.fee = dic[@"value"];
                model.flag = self.tokenModel.flag;
                model.maxBlockNumber = self.maxBlockNumber;
                model.minBlockNumber = self.minBlockNumber;
                model.pay_address = dic[@"from"];
                model.receive_address = dic[@"to"];
                model.finished_at = dic[@"confirmTime"];
                model.remark = dic[@"remark"];
                model.handle_fee = @"0.00";
                if ([NSObject isNulllWithObject:model.finished_at]) {
                    isHaveNoFinishOrder = YES;
                }
                if ([dic[@"from"] isEqualToString:self.model.address] && [dic[@"to"] isEqualToString:self.model.address]) {
                    model.isMySelf = YES;
                } else {
                    model.isMySelf = NO;
                    
                    if ([dic[@"from"] isEqualToString:self.model.address])
                    {
                        //热钱包 eth
                        //转账
                        model.isReceivables = NO;
                    }
                    else
                    {
                        //收款
                        model.isReceivables = YES;
                    }
                }
                [self.dataSource addObject:model];
            }
            self.isCanTransferAccounts = !isHaveNoFinishOrder;
            [self.coustromTableView reloadData];
        } else {
            [weakSelf.coustromTableView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSString *error) {
        [weakSelf endRefresh];
        [LCProgressHUD showFailure:error];
    }];
}
- (void)addRefresh {
    WEAKSELF
    self.coustromTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadBanlaceData];
        if (weakSelf.model.category_id == 2) {
            [weakSelf loadNeoDataIsLoadMore:NO];
        } else {
            [weakSelf loadOtherDataIsLoadMore:NO];
        }
    }];
    self.coustromTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.model.category_id == 2) {
            [weakSelf loadNeoDataIsLoadMore:YES];
        } else {
            [weakSelf loadOtherDataIsLoadMore:YES];
        }
    }];
}
- (void)endRefresh {
    if (self.coustromTableView.mj_header.refreshing) {
        [self.coustromTableView.mj_header endRefreshing];
    }
    if (self.coustromTableView.mj_footer.refreshing) {
        [self.coustromTableView.mj_footer endRefreshing];
    }
}

#pragma mark - Deletate/DataSource (相关代理)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    //    NSLog(@" scrollViewDidScroll");
    NSLog(@"ContentOffset  x is  %f,yis %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    if (scrollView.contentOffset.y > 180)
    {
        self.title = [NSString stringWithFormat:@"总资产(%@)",self.headerView.cnyPriceLB.text];
    }
    else
    {
        self.title = self.tokenModel ? self.tokenModel.name : self.model.category_name;
    }
}

//扫描代理
- (void)scanSucessWithObject:(id)object
{
    //扫一扫回调  获取到json 转字典传给确认转账页面
    NSDictionary * dic = [NSDictionary dictionaryWithJsonString:object];
    
    if ([self.model.address compare:[dic objectForKey:@"wallet_address"]
                            options:NSCaseInsensitiveSearch |NSNumericSearch] != NSOrderedSame)
    {
        [LCProgressHUD showMessage:@"请使用正确的钱包"];
        return;
    }
    
    ConfirmationTransferVC * vc = [[ConfirmationTransferVC alloc] init];
    vc.model = self.model;
    
    vc.totleGasPrice = [dic objectForKey:@"show_gas"];
    vc.nonce = [dic objectForKey:@"nonce"];
    vc.price = [dic objectForKey:@"show_price"];
    vc.address = [dic objectForKey:@"transfer_address"];   //代币  合约地址
    vc.remark = [dic objectForKey:@"hit"];
    vc.ox_gas = [[dic objectForKey:@"ox_gas"] lowercaseString];
    vc.ox_Price = [[dic objectForKey:@"ox_price"] lowercaseString];   //代币  data
    vc.gas_limit = [[dic objectForKey:@"gas_limit"] lowercaseString];
    if ([[dic objectForKey:@"type"] intValue] == 2)
    {
        //代币转账
        WalletInfoGntModel * model = [[WalletInfoGntModel alloc] init];
        vc.tokenModel = model;
    }
    vc.isCodeWallet = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//下拉刷新回调
- (void)pull2RefreshWithScrollerView:(UIScrollView *)scrollerView
{
    [self loadData];
}

//此外，你还可以调整内容视图的垂直对齐（即：有用的时候，有tableheaderview可见）：
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -40.0 + 150;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TransactionListCellident"];
    cell = nil;
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"TransactionListCell" owner:nil options:nil];
        cell = array[0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.model = _dataSource[indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //记录详情
    WalletOrderModel * model = self.dataSource[indexPath.row];
    TransactionInfoVC * vc = [[TransactionInfoVC alloc] init];
    vc.isTransfer = !model.isReceivables;
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Setter/Getter

- (TransactionListHeaderView *)headerView
{
    if (!_headerView)
    {
        _headerView = [TransactionListHeaderView loadViewFromXIB];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, AUTOLAYOUTSIZE(260));
    }
    return _headerView;
}

- (UIButton *)transferButton
{
    if (!_transferButton)
    {
        _transferButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _transferButton.frame = CGRectMake(0, SCREEN_HEIGHT - 64 - 55, SCREEN_WIDTH/2, 55);
        [_transferButton setTitle:@"   转账" forState: UIControlStateNormal];
        [_transferButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_transferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _transferButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_transferButton setImage:[UIImage imageNamed:@"转账"] forState:UIControlStateNormal];
        _transferButton.backgroundColor = [UIColor colorWithHexString:@"EA642F"];
        [_transferButton addTarget:self action:@selector(transferButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transferButton;
}

- (UIButton *)receivablesButton
{
    if (!_receivablesButton)
    {
        _receivablesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _receivablesButton.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 64 - 55, SCREEN_WIDTH/2, 55);
        [_receivablesButton setTitle:@"   收款" forState: UIControlStateNormal];
        [_receivablesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_receivablesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _receivablesButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_receivablesButton setImage:[UIImage imageNamed:@"收款"] forState:UIControlStateNormal];
        _receivablesButton.backgroundColor = [UIColor colorWithHexString:@"008C55"];
        [_receivablesButton addTarget:self action:@selector(receivablesButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _receivablesButton;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
