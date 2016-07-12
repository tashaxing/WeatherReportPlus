//
//  UPAddCityViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "UPAddCityViewController.h"

@interface UPAddCityViewController ()<CLLocationManagerDelegate>
@property(nonatomic, strong)CLLocationManager *locationManager; // 位置管理器，用于获取当前城市
@end

@implementation UPAddCityViewController

#pragma mark - UI相关
- (void)loadView
{
    [super loadView];
    // 设置导航栏
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationItem.title = @"添加城市";
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(save)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    // 定位
    [self locate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 定位相关
- (void)locate
{
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        float iOSversion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(iOSversion >= 8.0)
        {
            // 如果是ios8以上，需要显式请求定位权限
//            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    else
    {
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"oops!"
                                                            message:@"请确认开启定位"
                                                           delegate:nil
                                                  cancelButtonTitle:@"cancel"
                                                  otherButtonTitles:@"ok", nil];
        [alertView show];
    }
    // 开始定位
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if(array.count > 0)
         {
             
             CLPlacemark *placemark = [array objectAtIndex:0];
             NSLog(@"%@",placemark.name);
             //获取城市
             NSString *cityName = placemark.locality;
             if (!cityName)
             {
                 //直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 cityName = placemark.administrativeArea;
             }
             NSLog(@"%@", cityName);
         }
         else if(error == nil && [array count] == 0)
         {
             
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             
             NSLog(@"Error: %@", error.localizedDescription);
         }
     }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // 如果定位出错，告知用户
    switch(error.code)
    {
        case kCLErrorDenied:
            NSLog(@"定位权限未开");
            break;
        case kCLErrorNetwork:
            NSLog(@"网络连接有问题");
        case kCLErrorLocationUnknown:
            NSLog(@"位置定位地点");
        default:
            NSLog(@"不明原因");
            break;
    }
}

#pragma mark - done和cancel的按钮回调
- (void)save
{
    NSLog(@"ok");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.updateUIblock];
}



- (void)cancel
{
    NSLog(@"cancel");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
