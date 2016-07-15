//
//  WeatherDailyModel.m
//  WeatherReport
//
//  Created by yxhe on 16/5/25.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import "WeatherDailyModel.h"

@implementation WeatherDailyModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_weatherDate forKey:@"weatherDate"];
    [aCoder encodeObject:_dayWeather forKey:@"dayWeather"];
    [aCoder encodeObject:_nightWeather forKey:@"nightWeather"];
    [aCoder encodeObject:_tmp_min forKey:@"tmp_min"];
    [aCoder encodeObject:_tmp_max forKey:@"tmp_max"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        _weatherDate = [aDecoder decodeObjectForKey:@"weatherDate"];
        _dayWeather = [aDecoder decodeObjectForKey:@"dayWeather"];
        _nightWeather = [aDecoder decodeObjectForKey:@"nightWeather"];
        _tmp_min = [aDecoder decodeObjectForKey:@"tmp_min"];
        _tmp_max = [aDecoder decodeObjectForKey:@"tmp_max"];
    }
    return self;
}

@end
