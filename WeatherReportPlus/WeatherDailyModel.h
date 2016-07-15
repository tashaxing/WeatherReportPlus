//
//  WeatherDailyModel.h
//  WeatherReport
//
//  Created by yxhe on 16/5/25.
//  Copyright © 2016年 yxhe. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface WeatherDailyModel : NSObject<NSCoding>

//weather data of each day
@property (nonatomic, strong) NSString *weatherDate;
@property (nonatomic, strong) NSString *dayWeather, *nightWeather;
@property (nonatomic, strong) NSString *tmp_min, *tmp_max;

@end
