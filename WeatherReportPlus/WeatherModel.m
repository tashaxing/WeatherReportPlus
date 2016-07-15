//
//  WeatherModel.m
//  WeatherReport
//
//  Created by yxhe on 16/5/25.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import "WeatherModel.h"

@implementation WeatherModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_country forKey:@"country"];
    [aCoder encodeObject:_curWeather forKey:@"curWeather"];
    [aCoder encodeObject:_tmperature forKey:@"tmperature"];
    [aCoder encodeObject:_pm25 forKey:@"pm25"];
    [aCoder encodeObject:_airQuality forKey:@"airQuality"];
    [aCoder encodeObject:_dailyWeatherDatas forKey:@"dailyWeatherDatas"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        _city = [aDecoder decodeObjectForKey:@"city"];
        _country = [aDecoder decodeObjectForKey:@"country"];
        _curWeather = [aDecoder decodeObjectForKey:@"curWeather"];
        _tmperature = [aDecoder decodeObjectForKey:@"tmperature"];
        _pm25 = [aDecoder decodeObjectForKey:@"pm25"];
        _airQuality = [aDecoder decodeObjectForKey:@"airQuality"];
        _dailyWeatherDatas = [aDecoder decodeObjectForKey:@"dailyWeatherDatas"];
    }
    return self;
}


@end
