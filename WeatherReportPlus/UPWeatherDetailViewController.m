//
//  UPWeatherDetailViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import "UPWeatherDetailViewController.h"
#import "AFHTTPSessionManager.h"
#import "WeatherDataStore.h"

//----------- 全局变量 -------------//
// 控件尺寸
const int kCurWeatherLabelHeight = 150;


// 天气api： http://www.heweather.com
#define apiAddress @"http://apis.baidu.com/heweather/weather/free"
#define apiKey @"7941288324b589ad9cf1f2600139078e"

// 文字标签的行数
const int kCurWeatherLabelLines = 6;
// 列表行数
const int kTableLines = 7;
// 列表行高
const float kTableCellHeight = 120;
//--------------------------------//


@interface UPWeatherDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UILabel *curWeatherLabel; // 当前天气label
@property (nonatomic, strong) UITableView *dailyWeatherTable;
@end

@implementation UPWeatherDetailViewController

#pragma mark - view相关
- (void)loadView
{
    [super loadView];
    self.navigationItem.title = _currentCity;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    float yMargin =[[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    
    // 添加当前天气label
    _curWeatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yMargin, self.view.frame.size.width, kCurWeatherLabelHeight)];
    [self.view addSubview:_curWeatherLabel];
    [_curWeatherLabel setNumberOfLines:kCurWeatherLabelLines];
    [_curWeatherLabel setTextAlignment:NSTextAlignmentCenter];
    
    // 添加列表
    _dailyWeatherTable = [[UITableView alloc] initWithFrame:CGRectMake(0, yMargin + kCurWeatherLabelHeight, self.view.frame.size.width, self.view.frame.size.height - kCurWeatherLabelHeight - yMargin)];
    _dailyWeatherTable.delegate = self;
    _dailyWeatherTable.dataSource = self;
    [self.view addSubview:_dailyWeatherTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 先从缓存刷UI
    [self updateUI];
    
    // 网路连接
    NSString *url = apiAddress;
    NSDictionary *params = @{@"city" : _currentCity};
    [self httpRequest:url withParams:params];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 列表相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kTableLines;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = indexPath.row % 2 ? [UIColor greenColor]:[UIColor whiteColor];
    cell.textLabel.numberOfLines = 5;
    //use weather data to set cell text
    WeatherModel *weatherModel = [WeatherDataStore sharedWeatherStore].weatherDatas[_cityIndex];
    cell.textLabel.text = [NSString stringWithFormat:@"日期: %@\n白天天气: %@\n夜间天气: %@\n温度: %@-%@ 摄氏度",
                           [weatherModel.dailyWeatherDatas[indexPath.row] weatherDate],
                           [weatherModel.dailyWeatherDatas[indexPath.row] dayWeather],
                           [weatherModel.dailyWeatherDatas[indexPath.row] nightWeather],
                           [weatherModel.dailyWeatherDatas[indexPath.row] tmp_min],
                           [weatherModel.dailyWeatherDatas[indexPath.row] tmp_max]];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set the tableview cell height
    return kTableCellHeight;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

#pragma mark - 网路请求和回调
- (void)httpRequest:(NSString *)url withParams:(NSDictionary *)params
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // Must add this code, or error occurs
    // Prepare the URL, parameters can be add to URL (could be html, json, xml, plist address)
    [manager.requestSerializer setValue:apiKey forHTTPHeaderField:@"apikey"]; // 设置请求头
    
    __weak UPWeatherDetailViewController *wself = self;
    [manager GET:url
      parameters:params
        progress:^(NSProgress * _Nonnull downloadProgress) {
            // Process the progress here
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            UPWeatherDetailViewController *sself = wself;
            if(sself)
            {
                [sself processData:responseObject];

            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
}

- (void)processData:(id)data
{
    NSError *error;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingMutableContainers error:&error];
    
    if (!jsonObj || error)
    {
        NSLog(@"JSON parse failed!");
    }
    
    NSMutableArray *jsonArray = [jsonObj objectForKey:@"HeWeather data service 3.0"];
    
    //    NSLog(@"%@", jsonArray);
    
    // 解析数据
    WeatherModel *weatherModel = [[WeatherModel alloc] init];
    // 判断返回状态正常才
    if([jsonArray.firstObject[@"status"] isEqualToString:@"ok"])
    {
        weatherModel.city = jsonArray.firstObject[@"basic"][@"city"]; //because the json has only one big array
        weatherModel.country = jsonArray.firstObject[@"basic"][@"cnty"];
        weatherModel.curWeather = jsonArray.firstObject[@"now"][@"cond"][@"txt"];
        weatherModel.tmperature = jsonArray.firstObject[@"now"][@"tmp"];
        
        if([weatherModel.country isEqualToString:@"中国"]) //only china has the aqi data
        {
            weatherModel.pm25 = jsonArray.firstObject[@"aqi"][@"city"][@"pm25"];
            weatherModel.airQuality = jsonArray.firstObject[@"aqi"][@"city"][@"qlty"];
        }
        
        NSMutableArray *dailyForecastArray = [jsonArray.firstObject objectForKey:@"daily_forecast"];
        
        //fill the 7 day weather
        NSMutableArray *dailyArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < dailyForecastArray.count; i++)
        {
            WeatherDailyModel *dailyModel = [[WeatherDailyModel alloc] init];
            dailyModel.weatherDate = dailyForecastArray[i][@"date"];
            dailyModel.dayWeather = dailyForecastArray[i][@"cond"][@"txt_d"];
            dailyModel.nightWeather = dailyForecastArray[i][@"cond"][@"txt_n"];
            dailyModel.tmp_min = dailyForecastArray[i][@"tmp"][@"min"];
            dailyModel.tmp_max = dailyForecastArray[i][@"tmp"][@"max"];
            [dailyArray addObject:dailyModel];
        }
        
        weatherModel.dailyWeatherDatas = [NSMutableArray arrayWithArray:dailyArray]; //cannot directly add object to this array
    }
    
    
    
    // 填充对应的weathermodel，注意这里是置换不是添加

    [[WeatherDataStore sharedWeatherStore].weatherDatas setObject:weatherModel atIndexedSubscript:_cityIndex];

    
    // 更新UI
    __weak UPWeatherDetailViewController *wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UPWeatherDetailViewController *sself = wself;
        if(sself)
        {
            [sself updateUI];
        }
        
    });
}

#pragma mark - 更新UI
- (void)updateUI
{
    WeatherModel *weatherModel = [WeatherDataStore sharedWeatherStore].weatherDatas[_cityIndex];
   
    self.curWeatherLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n温度: %@ 摄氏度\nPM2.5: %@\n%@",
                                 weatherModel.city,
                                 weatherModel.country,
                                 weatherModel.curWeather,
                                 weatherModel.tmperature,
                                 weatherModel.pm25,
                                 weatherModel.airQuality];
    [self.dailyWeatherTable reloadData];
}


@end
