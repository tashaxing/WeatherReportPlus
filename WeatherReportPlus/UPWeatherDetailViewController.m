//
//  UPWeatherDetailViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import "UPWeatherDetailViewController.h"
#import "AFHTTPSessionManager.h"

@interface UPWeatherDetailViewController ()

@end

@implementation UPWeatherDetailViewController

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = @"xxx市";
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 网路连接
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
