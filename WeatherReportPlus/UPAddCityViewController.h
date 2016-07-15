//
//  UPAddCityViewController.h
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPAddCityViewController : UIViewController
@property (nonatomic, copy) void (^updateUIblock)(void); // block用于在主界面中回调更新UI
@property (nonatomic, strong) NSString *selectedCity; // 选中的城市
@end
