//
//  WeatherDataStore.h
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/13.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WeatherModel.h"

@interface WeatherDataStore : NSObject
@property (nonatomic, strong) NSMutableArray<WeatherModel *> *weatherDatas;
+ (instancetype)sharedWeatherStore; // 返回公共数据模型
- (BOOL)saveChanges; // 文件归档
@end

