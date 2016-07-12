//
//  UPCityViewController.m
//  WeatherReportPlus
//
//  Created by yxhe on 16/7/12.
//  Copyright © 2016年 yxhe. All rights reserved.
//

#import <Realm/RLMObject.h>

#import "UPCityViewController.h"
#import "UPAddCityViewController.h"
#import "UPWeatherDetailViewController.h"
#import "TileButton.h"

//----------- 全局变量 -------------//
//the space between tiles
const static int kTileSpace = 5;
//the inital max tile number in one line
const static int kTileInLine = 3;

enum TouchState
{
    UNTOUCHED,
    SUSPEND,
    MOVE
};

//--------------------------------//


@interface UPCityViewController ()<UIGestureRecognizerDelegate, TileDeleteButtonDelegate>
{
    NSInteger currentCityCount;
    enum TouchState touchState;
    NSInteger preTouchID;
}
@property (nonatomic, strong) NSMutableArray *tileArray; // 先用tilearray把这个装着把，后面换成数据相关的
@end

@implementation UPCityViewController

#pragma mark - view相关
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 加载数据

}

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
                                                                                   action:@selector(addCity)];
    self.navigationItem.rightBarButtonItem = addCityButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tileArray = [NSMutableArray array];
    currentCityCount = 0;
    touchState = UNTOUCHED;
    preTouchID = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 添加城市
- (void)addCity
{
    NSLog(@"添加城市");
    UPAddCityViewController *addCityViewController = [[UPAddCityViewController alloc] init];
    addCityViewController.updateUIblock = ^{
        NSLog(@"添加城市:");
        // 根据页面的样式flag区分，更新本页面UI
        [self addTile];
    };

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addCityViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
    
}

#pragma mark - 添加方块以及长按方块的手势
- (void)addTile
{
    // 计算方块边长
    float tileSize = (self.view.frame.size.width - kTileSpace * kTileInLine) / kTileInLine;
    // 行列标号
    int xID = currentCityCount % kTileInLine;
    int yID = currentCityCount / kTileInLine;
    
    float yMargin = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"%f", yMargin);
    TileButton *tile = [[TileButton alloc] initWithFrame:CGRectMake(kTileSpace / 2 + xID * (kTileSpace + tileSize),
                                                                    kTileSpace / 2 + yMargin * 2 + yID * (kTileSpace + tileSize),
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
    [self.view addSubview:tile];
    
    // 设置方块索引
    tile.index = currentCityCount;
    [tile setTileText:[NSString stringWithFormat:@"城市%d", currentCityCount] clickText:@"clicked"];
    
    // 城市数量增量
    currentCityCount++;
}

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
        NSLog(@"%@", button.titleLabel.text);
        // 此处进入具体的城市天气预报界面
        UPWeatherDetailViewController *weatherDetailViewController = [[UPWeatherDetailViewController alloc] init];
        [self.navigationController pushViewController:weatherDetailViewController animated:YES];
    }
}

//tile delete button clicked
- (void)tileDeleteButtonClicked:(TileButton *)tileBtn
{
    /* remove the button and adjust the tilearray */
    
    NSLog(@"deletebutton delegate responds");
    
    //remember the deleted tile's infomation
    int startIndex = tileBtn.index;
    CGPoint preCenter = tileBtn.center;
    CGPoint curCenter;
    
    //[_tileArray removeObject:tileBtn];
    //exchange the pointer in array and swap the index,
    //at last the tile_btn is at the new right place
    for(int i = startIndex + 1; i < _tileArray.count; i++)
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
    // 把当前数量减1，否则方块继续添加的位置不对
    currentCityCount--;
    // 把长按状态置会正常态，否则没法点击
    touchState = UNTOUCHED;
    
    //test the display if the array is inorder
    for(TileButton *tile in _tileArray)
    {
        NSLog(@"tile text: %@", tile.titleLabel.text);
    }
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


#pragma mark - 切换样式
- (void)swithLayoutStyle
{
    NSLog(@"切换样式");
}

@end
