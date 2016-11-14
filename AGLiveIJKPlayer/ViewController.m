//
//  ViewController.m
//  AGLiveIJKPlayer
//
//  Created by 吴书敏 on 16/11/9.
//  Copyright © 2016年 littledogboy. All rights reserved.
//

#import "ViewController.h"
#import "AGLiveIJKPlayerController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTableView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)addTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    [self.view addSubview:_tableView];
    
    //
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    //
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.frame = CGRectMake(100, 100, 120, 40);
    [button setTitle:@"视频" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(presentLiveController) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
}

- (void)presentLiveController {
    AGLiveIJKPlayerController *liveIJKController = [[AGLiveIJKPlayerController alloc] init];
//    liveIJKController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [self presentViewController:liveIJKController animated:NO completion:^{
//        
//    }];
    [self.view addSubview:liveIJKController.view];
    [self addChildViewController:liveIJKController];
}


#pragma mark- TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text  = [NSString stringWithFormat:@"%ld %ld", indexPath.row, indexPath.section];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- 屏幕旋转
// 是否支持转屏，no 不支持。yes，视图方向跟随屏幕方向旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return [self.presentedViewController  supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


@end
