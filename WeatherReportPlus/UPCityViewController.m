//
//  UPCityViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//



#import "UPCityViewController.h"
#import "UPAddCityViewController.h"
#import "UPWeatherDetailViewController.h"
#import "TileButton.h"
#import "WeatherDataStore.h"

//----------- 全局变量 -------------//
// 方块间隔
const int kTileSpace = 5;
// 一行的方块数
const int kTileInLine = 3;

// 控件尺寸
const int kTitleLabelLeftMargin = 10;
const int kTitleLabelVerticalMargin = 5;
const int kTitleLabelWidth = 100;
const int kTitleLabelHeight = 30;

enum TouchState
{
    UNTOUCHED,
    SUSPEND,
    MOVE
};

//--------------------------------//


@interface UPCityViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, TileDeleteButtonDelegate>
{
    NSInteger currentCityCount;
    enum TouchState touchState;
    NSInteger preTouchID;
}
@property (nonatomic, strong) NSMutableArray *tileArray; // 先用tilearray把这个装着把，后面换成数据相关的
@property (nonatomic, strong) UITableView *tableView; // 表视图
@property (nonatomic, assign) BOOL isTableStyle; // 是否是列表布局
@end

@implementation UPCityViewController

#pragma mark - view相关
- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置导航栏标题
    self.navigationItem.title = @"城市";
    // 添加左边切换样式按钮
    UIBarButtonItem *swithButton = [[UIBarButtonItem alloc] init];
    swithButton.title = @"切换样式";
    [swithButton setTarget:self];
    [swithButton setAction:@selector(swithLayoutStyle)];
    self.navigationItem.leftBarButtonItem = swithButton;
    // 添加右边加号
    UIBarButtonItem *addCityButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(onAddBtn)];
    self.navigationItem.rightBarButtonItem = addCityButton;
    
    float yMargin =[[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    
    // 设置label和编辑框
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTitleLabelLeftMargin, yMargin + kTitleLabelVerticalMargin, kTitleLabelWidth, kTitleLabelHeight)];
    titleLabel.text = @"管理城市";
    titleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:titleLabel];
    
    // 设置样式
    _isTableStyle = NO;
    // 添加列表
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yMargin + kTitleLabelHeight + kTitleLabelVerticalMargin, self.view.frame.size.width, self.view.frame.size.height - (yMargin + kTitleLabelHeight + kTitleLabelVerticalMargin))];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView removeFromSuperview];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    _tileArray = [NSMutableArray array];
    currentCityCount = 0;
    touchState = UNTOUCHED;
    preTouchID = -1;
    
    // 从文件初始化数据
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 添加城市
- (void)onAddBtn
{
    NSLog(@"添加城市");
    UPAddCityViewController *addCityViewController = [[UPAddCityViewController alloc] init];
    __weak UPCityViewController *wself = self;
    __weak UPAddCityViewController *waddCityViewController = addCityViewController;
    
    // 定义添加完成回调
    addCityViewController.updateUIblock = ^{
        // 根据页面的样式flag区分，更新本页面UI
        // 如果没选中任何城市或者取消掉了就不添加
        if(waddCityViewController.selectedCity)
        {
            WeatherModel *weatherModel = [[WeatherModel alloc] init];
            weatherModel.city = waddCityViewController.selectedCity;
            [[WeatherDataStore sharedWeatherStore].weatherDatas addObject:weatherModel];
            
            NSString *title = waddCityViewController.selectedCity; // 在这里拷贝一个，用于主线程block
            [wself addTile:title]; // 防止循环引用
            // 城市数量增量,要在addtile后面，否则坐标乱了
            currentCityCount++;
            
            // 主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself updateUI];
            });
        }
    };
    // 导航到天气城市页面
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addCityViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - 从文件初始化方块或者列表
- (void)initUI
{
    // 恢复方块
    NSInteger totalCount = [WeatherDataStore sharedWeatherStore].weatherDatas.count;
    while(currentCityCount < totalCount)
    {
        [self addTile:[WeatherDataStore sharedWeatherStore].weatherDatas[currentCityCount].city];
        currentCityCount++;
    }
    
    // 添加到view
    if(_isTableStyle)
    {
        for(TileButton *tile in _tileArray)
        {
            [tile removeFromSuperview];
        }
        [self.view addSubview:_tableView];
        // 重新加载数据
        [_tableView reloadData];
    }
    else
    {
        [_tableView removeFromSuperview];
        for(TileButton *tile in _tileArray)
        {
            [self.view addSubview:tile];
        }
    }
}

#pragma mark - 更新UI
- (void)updateUI
{
    if(_isTableStyle)
    {
        [_tableView reloadData];
    }
    else
    {
        [self.view addSubview:_tileArray.lastObject];
    }
}
#pragma mark - 列表相关以及添加cell

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentCityCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [WeatherDataStore sharedWeatherStore].weatherDatas[indexPath.row].city;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 此处进入具体的城市天气预报界面
    UPWeatherDetailViewController *weatherDetailViewController = [[UPWeatherDetailViewController alloc] init];
    weatherDetailViewController.currentCity = [WeatherDataStore sharedWeatherStore].weatherDatas[indexPath.row].city;
    // 记住城市索引，方便在detail页面找到
    weatherDetailViewController.cityIndex = indexPath.row;
    [self.navigationController pushViewController:weatherDetailViewController animated:YES];
}

- (void)   tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
   forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 移除这行的数据
        [[WeatherDataStore sharedWeatherStore].weatherDatas removeObjectAtIndex:indexPath.row];
        
        // 必须把列表行数减1
        currentCityCount--;
        
        // 顺带移除方块(这块写得不够解耦。。。)
        //remember the deleted tile's infomation
        NSInteger startIndex = indexPath.row;
        CGPoint preCenter = [_tileArray[startIndex] center];
        CGPoint curCenter;
        for(NSInteger i = startIndex + 1; i < _tileArray.count; i++)
        {
            TileButton *movedTileBtn = _tileArray[i];
            curCenter = movedTileBtn.center;
            movedTileBtn.center = preCenter;
            //save the precenter
            preCenter = curCenter;
            //reduce the tile index
            movedTileBtn.index--;
            //move the pointer one by one
            _tileArray[i-1] = movedTileBtn;
        }
        //every time remove the last object
        [_tileArray removeLastObject];
        
        // 移除
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - 添加方块以及长按方块的手势
- (void)addTile:(NSString *)title
{
    // 计算方块边长
    float tileSize = (self.view.frame.size.width - kTileSpace * kTileInLine) / kTileInLine;
    // 行列标号
    int xID = currentCityCount % kTileInLine;
    int yID = currentCityCount / kTileInLine;
    
    // 获取状态栏和导航栏高度和，空开这个距离
    float yMargin =[[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    
    TileButton *tile = [[TileButton alloc] initWithFrame:CGRectMake(kTileSpace / 2 + xID * (kTileSpace + tileSize),
                                                                     yMargin + 30 + 5 + kTileSpace + yID * (kTileSpace + tileSize),
                                                                    tileSize, tileSize)];
    
    [tile addTarget:self action:@selector(tileClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加每个方块的手势
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] init];
    [longGesture addTarget:self action:@selector(onLongGresture:)];
    [tile addGestureRecognizer:longGesture];
    
    // 添加点击事件
    [tile addTarget:self action:@selector(tileClicked:) forControlEvents:UIControlEventTouchUpInside];
    tile.delegate = self;
    
    // 添加方块到array和当前view
    [self.tileArray addObject:tile];
    
    // 设置方块索引
    tile.index = currentCityCount;
    [tile setTileText:title clickText:@"clicked"];

}



//tile delete button clicked
- (void)tileDeleteButtonClicked:(TileButton *)tileBtn
{
    /* remove the button and adjust the tilearray */
    
    NSLog(@"deletebutton delegate responds");
    
    //remember the deleted tile's infomation
    NSInteger startIndex = tileBtn.index;
    CGPoint preCenter = tileBtn.center;
    CGPoint curCenter;
    
    //[_tileArray removeObject:tileBtn];
    //exchange the pointer in array and swap the index,
    //at last the tile_btn is at the new right place
    for(NSInteger i = startIndex + 1; i < _tileArray.count; i++)
    {
        __block TileButton *movedTileBtn = _tileArray[i];
        curCenter = movedTileBtn.center;
        
        [UIView animateWithDuration:0.3 animations:^{
            movedTileBtn.center = preCenter;
        }];
        
        //save the precenter
        preCenter = curCenter;
        
        //reduce the tile index
        movedTileBtn.index--;
        
        //move the pointer one by one
        _tileArray[i-1] = movedTileBtn;
    }
    
    //every time remove the last object
    [_tileArray removeLastObject];
    
    //must remove the tileBtn from the view
    //we can also use performselector so that button disappears with animation
    [tileBtn removeFromSuperview];
    // 把长按状态置会正常态，否则没法点击
    touchState = UNTOUCHED;
    
    //test the display if the array is inorder
    for(TileButton *tile in _tileArray)
    {
        NSLog(@"tile text: %@", tile.titleLabel.text);
    }
    
    // 把当前数量减1，否则方块继续添加的位置不对
    currentCityCount--;
    // 更新数据
    [[WeatherDataStore sharedWeatherStore].weatherDatas removeObjectAtIndex:tileBtn.index];
}

- (void)onLongGresture:(UILongPressGestureRecognizer *)sender
{
    TileButton *tileBtn = (TileButton *)sender.view;
    switch(sender.state)
    {
        case UIGestureRecognizerStateBegan:
            [tileBtn tileSuspended];
            touchState = SUSPEND;
            preTouchID = tileBtn.index;
            break;
        default:
            break;
            
    }
}

#pragma mark - 点击方块导航
- (void)tileClicked:(TileButton *)button
{
    if(touchState == SUSPEND)
    {
        [_tileArray[preTouchID] tileSettled];
        touchState = UNTOUCHED;
        NSLog(@"suspend canceld");
    }
    else if(touchState == UNTOUCHED)
    {
        // 此处进入具体的城市天气预报界面
        UPWeatherDetailViewController *weatherDetailViewController = [[UPWeatherDetailViewController alloc] init];
        weatherDetailViewController.currentCity = [WeatherDataStore sharedWeatherStore].weatherDatas[button.index].city;
        // 记住索引
        weatherDetailViewController.cityIndex = button.index;
        [self.navigationController pushViewController:weatherDetailViewController animated:YES];
    }
}


#pragma mark - 切换样式
- (void)swithLayoutStyle
{
    NSLog(@"切换样式");
    _isTableStyle = !_isTableStyle;
    if(_isTableStyle)
    {
        for(TileButton *tile in _tileArray)
        {
            [tile removeFromSuperview];
        }
        [self.view addSubview:_tableView];
        // 重新加载数据
        [_tableView reloadData];
    }
    else
    {
        [_tableView removeFromSuperview];
        for(TileButton *tile in _tileArray)
        {
            [self.view addSubview:tile];
        }
    }
}

@end
