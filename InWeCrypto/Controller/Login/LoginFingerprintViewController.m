//
//  LoginFingerprintViewController.m
//  InWeCrypto
//
//  Created by 赵旭瑞 on 2018/5/22.
//  Copyright © 2018年 赵旭瑞. All rights reserved.
//

#import "LoginFingerprintViewController.h"

@interface LoginFingerprintViewController ()

@end

@implementation LoginFingerprintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 暂不开启
 */
- (void)respondsToNoOpenButton {
    [self.target dismissViewControllerAnimated:YES completion:nil];
    [[AppDelegate delegate] goToTabbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end