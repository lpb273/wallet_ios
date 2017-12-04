//
//  UserModel.h
//  FBG
//
//  Created by mac on 2017/7/13.
//  Copyright © 2017年 ButtonRoot. All rights reserved.
//

#import "BaseModel.h"
#import "WalletLeftListModel.h"

@interface UserModel : BaseModel <NSCoding>

//储存字段

#pragma mark -- 用户基本信息
@property (nonatomic, copy) NSString * token;
@property (nonatomic, copy) NSString * open_id;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * sex;
@property (nonatomic, copy) NSString * img;
@property (nonatomic, assign) BOOL isCode; //是不是从冷钱包进入
@property (nonatomic, assign) int walletUnitType; // 1 = rmb  2 = usd

@property (nonatomic, copy) NSString * API;
@property (nonatomic, copy) NSString * IMAGE;

#pragma mark -- 用户余额信息
@property (nonatomic, assign) BOOL isRefeshAssets; //需不需要刷新价格
@property (nonatomic, copy) NSString * totalAssets_cny;   //人民币总资产
@property (nonatomic, copy) NSString * totalAssets_usd;   //美元总资产
@property (nonatomic, copy) NSString * ETHAssets_ether;   //ETH资产数量
@property (nonatomic, copy) NSString * ETHAssets_cny;   //ETH资产人民币价值
@property (nonatomic, copy) NSString * ETHAssets_usd;   //ETH资产美元价值
@property (nonatomic, copy) NSString * NEOAssets_ether;   //NEO资产数量
@property (nonatomic, copy) NSString * NEOAssets_cny;   //NEO资产人民币价值
@property (nonatomic, copy) NSString * NEOAssets_usd;   //NEO资产美元价值
@property (nonatomic, copy) NSString * BTCAssets_ether;   //BTC资产数量
@property (nonatomic, copy) NSString * BTCAssets_cny;   //BTC资产人民币价值
@property (nonatomic, copy) NSString * BTCAssets_usd;   //BTC资产美元价值

#pragma mark -- 用户钱包信息
@property (nonatomic, strong) NSMutableArray * walletIdsArray;// 备份钱包ids
@property (nonatomic, strong) NSMutableArray * codeWalletsArray; //冷钱包进入本地钱包数组
@property (nonatomic, strong) NSMutableArray * walletZhujiciIdsArray;// 备份钱包ids  (助记词)

@end
