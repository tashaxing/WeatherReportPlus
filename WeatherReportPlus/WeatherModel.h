//
//  WeatherModel.h
//  WeatherReport
//
//  Created by yxhe on 16/5/25.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherDailyModel.h"

@interface WeatherModel : NSObject<NSCoding>

//current weather data keys
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *curWeather;
@property (nonatomic, strong) NSString *tmperature;
@property (nonatomic, strong) NSString *pm25;
@property (nonatomic, strong) NSString *airQuality;

//7-days weather data array
@property (nonatomic, strong) NSMutableArray<WeatherDailyModel *> *dailyWeatherDatas;
@end
