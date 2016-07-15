//
//  UPAddCityViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "UPAddCityViewController.h"

//----------- 全局变量 -------------//
const int kLocationLabelLeftMargin = 10;
const int kLocationLabelVerticalMargin = 5;
const int kLocatoinLabelWidth = 100;
const int kLocationLabelHeight = 30;
const int kLocationTextFieldLefMargin = 110;
const int kLocationTextFieldWidth = 80;

//--------------------------------//


@interface UPAddCityViewController ()<CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UITextFieldDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager; // 位置管理器，用于获取当前城市
@property (nonatomic, strong) NSMutableArray *cityData; // 城市数据
@property (nonatomic, strong) NSMutableArray *searchResults; // 搜索的结果
@property (nonatomic, strong) UITableView *tableView; // 城市列表
@property (nonatomic, strong) UISearchController *searchController; // 搜索栏
@property (nonatomic, strong) UITextField *locationEditField; // 编辑框
@end

@implementation UPAddCityViewController

#pragma mark - UI相关

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
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
    
    // 计算顶部间隔
    float yMargin =[[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    
    // 设置label和编辑框
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLocationLabelLeftMargin, yMargin + kLocationLabelVerticalMargin, kLocatoinLabelWidth, kLocationLabelHeight)];
    locationLabel.text = @"定位位置：";
    locationLabel.textColor = [UIColor blackColor];
    [self.view addSubview:locationLabel];
    
    // 添加编辑框
    _locationEditField = [[UITextField alloc] initWithFrame:CGRectMake(kLocationTextFieldLefMargin, yMargin + kLocationLabelVerticalMargin, kLocationTextFieldWidth, kLocationLabelHeight)];
    _locationEditField.borderStyle = UITextBorderStyleRoundedRect;
    _locationEditField.delegate = self;
    [self.view addSubview:_locationEditField];
    
    // 设置tableview, 顶部是从导航栏以下算起的
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yMargin + kLocationLabelHeight + 2 * kLocationLabelVerticalMargin, self.view.frame.size.width, self.view.frame.size.height - yMargin)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // 添加搜索栏
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame = CGRectMake(0, 0, 0, 44); // 只需要指定高度
    self.searchController.dimsBackgroundDuringPresentation = NO; // 保证能选择cell
    self.searchController.hidesNavigationBarDuringPresentation = NO; // 不隐藏导航栏
    self.searchController.searchBar.backgroundColor = [UIColor orangeColor];
    
    self.searchController.searchResultsUpdater = self;
    _tableView.tableHeaderView = self.searchController.searchBar; // 需要添加到表头
    [self.searchController.searchBar sizeToFit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 解析json城市数据
    //parse the json file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"CityList" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    
    NSError *error;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                 options:NSJSONReadingMutableContainers error:&error];
    
    if (!jsonObj || error)
    {
        NSLog(@"JSON parse failed!");
    }
    // 绑定到城市列表
    self.cityData = [NSMutableArray array];
    for(NSDictionary *dict in jsonObj)
    {
        [self.cityData addObject:dict[@"name"]];
    }
    
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
             // 获取城市
             NSString *cityName = placemark.locality;
             if (!cityName)
             {
                 // 直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 cityName = placemark.administrativeArea;
             }
             _selectedCity = cityName;
             _locationEditField.text = cityName;
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
    // 系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
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

#pragma mark - 列表相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchController.active)
    {
        return _searchResults.count;
    }
    else
    {
        return _cityData.count;
    }
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //set the tableview cell height
//    return kCustomCellHeight;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // 设置选中时背景颜色
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor greenColor];
    }
    cell.textLabel.text = self.searchController.active ? _searchResults[indexPath.row] : _cityData[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _locationEditField.text = self.searchController.active ? _searchResults[indexPath.row] : _cityData[indexPath.row];
}

#pragma mark - 编辑框委托
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    // 注意此处没有做城市名校验，主要是为了可以输入国外的名字，所以不要输入奇奇怪怪的字符T_T
    return YES;
}

#pragma mark - 搜索器相关
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.searchResults removeAllObjects];
    // 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", searchController.searchBar.text];
    // 过滤table
    self.searchResults = [[self.cityData filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    // 刷新表格
    [self.tableView reloadData];
}

#pragma mark - done和cancel的按钮回调
- (void)save
{
    NSLog(@"ok");
    // 保存城市名字
    _selectedCity = self.locationEditField.text;
    // 删掉定位的名字后面的 “市” 字
    _selectedCity = [_selectedCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
    // 返回主界面
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.updateUIblock];
}

- (void)cancel
{
    NSLog(@"cancel");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
