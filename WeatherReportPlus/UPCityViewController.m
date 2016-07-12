//
//  UPCityViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <Realm/RLMObject.h>
#import "AFHTTPSessionManager.h"

#import "UPCityViewController.h"


@interface UPCityViewController ()

@end

@implementation UPCityViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 加载数据

}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置导航栏标题
    self.navigationItem.title = @"城市";

    // 添加左边切换样式按钮
    UIBarButtonItem *swithButton = [[UIBarButtonItem alloc] init];
    swithButton.title = @"切换样式";
    [swithButton setTarget:self];
    [swithButton setAction:@selector(swithLayoutStyle)];
    self.navigationItem.leftBarButtonItem = swithButton;
    // 添加右边加号
    UIBarButtonItem *addCityButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addCity)];
    self.navigationItem.rightBarButtonItem = addCityButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCity
{
    NSLog(@"添加城市");
}

- (void)swithLayoutStyle
{
    NSLog(@"切换样式");
}

@end
