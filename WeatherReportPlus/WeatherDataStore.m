//
//  WeatherDataStore.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/13.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import "WeatherDataStore.h"

@interface WeatherDataStore()

@end

@implementation WeatherDataStore

// 获取单例
+ (instancetype)sharedWeatherStore
{
    static WeatherDataStore *weatherStore;
    if(!weatherStore)
    {
        weatherStore = [[WeatherDataStore alloc] initPrivate];
    }
    return weatherStore;
}


// 私有的init
- (instancetype)initPrivate
{
    self = [super init];
    if(self)
    {
        NSString *path = [self dataArchivePath];
        NSLog(@"load data from archive");
        _weatherDatas = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if(!_weatherDatas)
        {
            _weatherDatas = [[NSMutableArray<WeatherModel *> alloc] init];
        }
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"天气数据单例"
                                   reason:@"不要使用原始的init函数"
                                 userInfo:nil];
    return nil;
}

// 存到文件
- (NSString *)dataArchivePath
{
    // Make sure that the first argument is NSDocumentDirectory
    // and not NSDocumentationDirectory
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the one document directory from that list
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"weatherDatas.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self dataArchivePath];
    // Returns YES on success
    return [NSKeyedArchiver archiveRootObject:self.weatherDatas toFile:path];
}

@end
