//
//  AGLiveIJKPlayerController.m
//  AGLiveIJKPlayer
//
//  Created by 吴书敏 on 16/11/9.
//  Copyright © 2016年 littledogboy. All rights reserved.
//

#import "AGLiveIJKPlayerController.h"
#import "LiveIJKPlayerView.h"
#import <Masonry.h>
#import <CoreMotion/CoreMotion.h>

#define FULLScreenFrame [UIScreen mainScreen].bounds
#define WindowFrame CGRectMake(0, 0, 375, 200)


@interface AGLiveIJKPlayerController () <LiveIJKPlayerViewDelegate>

@property (nonatomic, strong) LiveIJKPlayerView *liveView;
@property (nonatomic, strong) UIView *darkView;
@property (nonatomic, assign) CGFloat zRotation; // z轴的旋转角度
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation AGLiveIJKPlayerController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 375, 200))];
    self.view.backgroundColor = [UIColor redColor];
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    self.darkView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.darkView.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)name:UIDeviceOrientationDidChangeNotification object:nil];
    // Do any additional setup after loading the view.
    [self addMotionManager];
}

- (void)loadData {
    NSString *urlString =  @"http://live.bilibili.com/AppNewIndex/recommend?access_key=a97c86bad48e821156213b9728ba3cec&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3910&buvid=f6f22b968fe7729b6af9d7e3a8dd3359&device=phone&mobi_app=iphone&platform=ios&scale=2&sign=1792d55eab8630d25b69fecb27da49c8&ts=1476954237";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *rootDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *playurl = [[[rootDic valueForKeyPath:@"data.recommend_data.banner_data"] lastObject] valueForKeyPath:@"playurl"];
        NSLog(@"%@", playurl);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLiveView:playurl];
        });
    }];
    [dataTask resume];
}

- (void)addLiveView:(NSString *)playurl {
    self.liveView = [[LiveIJKPlayerView alloc] initWithFrame:CGRectZero liveURLString:playurl];
    _liveView.delegate = self;
    _liveView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_liveView];
    __weak typeof(self) weakSelf = self;
    [_liveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view);
    }];
}

/**
 *  该方法为控制controller.view 旋转的方法
 *
 *  @param pi          旋转弧度
 *  @param frame       旋转后的frame
 *  @param orientation 旋转后status的方向
 *  @param isHiddren   旋转完成后是否显示后面的黑色视图
 */
- (void)viewTransformRotate:(CGFloat)pi
                      frame:(CGRect)frame
       statusBarOrientation:(UIInterfaceOrientation)orientation
          isHiddrenDarkView:(BOOL)isHiddren {
    if(isHiddren == YES) {
        [_darkView removeFromSuperview];
    }
    [UIApplication sharedApplication].statusBarHidden = YES;
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        CGAffineTransform transform = CGAffineTransformRotate(self.view.transform, pi);
        self.view.transform = transform;
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
        if (isHiddren == NO) {
            [self.parentViewController.view insertSubview:_darkView belowSubview:self.view];
        }
    }];
}

// 只做旋转
- (void)viewTransformRotate:(CGFloat)pi
       statusBarOrientation:(UIInterfaceOrientation)orientation
          isHiddrenDarkView:(BOOL)isHiddren {
    if(isHiddren == YES) {
        [_darkView removeFromSuperview];
    }
    [UIApplication sharedApplication].statusBarHidden = YES;
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
        CGAffineTransform transform = CGAffineTransformRotate(self.view.transform, pi);
        self.view.transform = transform;
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarHidden = NO;
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
        if (isHiddren == NO) {
            [self.parentViewController.view insertSubview:_darkView belowSubview:self.view];
        }
    }];
}

- (void)liveViewRatation {
    CMAcceleration acceleration = self.motionManager.accelerometerData.acceleration;
    CGFloat xACC = acceleration.x; // x受力方向。
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        
        if (xACC <= 0) {
            [self viewTransformRotate:M_PI_2 frame:FULLScreenFrame statusBarOrientation:(UIInterfaceOrientationLandscapeRight) isHiddrenDarkView:NO];
        } else if (xACC > 0) {
            [self viewTransformRotate:-M_PI_2 frame:FULLScreenFrame statusBarOrientation:(UIInterfaceOrientationLandscapeLeft) isHiddrenDarkView:NO];
        }
        
    } else if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        [self viewTransformRotate:-M_PI_2 frame:WindowFrame statusBarOrientation:(UIInterfaceOrientationPortrait) isHiddrenDarkView:YES];
        
    } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self viewTransformRotate:M_PI_2 frame:WindowFrame statusBarOrientation:(UIInterfaceOrientationPortrait) isHiddrenDarkView:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}
//
//// 支持的方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//    NSLog(@"aaa");
//}

// 隐藏状态条
//- (BOOL)prefersStatusBarHidden {
//
//}




- (void)orientChange:(NSNotification *)notification
{
    UIDeviceOrientation  orientenation = [UIDevice currentDevice].orientation;
    switch (orientenation)
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                [self viewTransformRotate:M_PI statusBarOrientation:(UIInterfaceOrientationLandscapeRight) isHiddrenDarkView:NO];
            }
        }
            break;
            
        case UIDeviceOrientationLandscapeRight:
        {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                [self viewTransformRotate:M_PI statusBarOrientation:(UIInterfaceOrientationLandscapeLeft) isHiddrenDarkView:NO];
            }
        }
            break;
            
            default:
            break;
    }
}

#pragma mark- 加速计获取x轴受力
- (void)addMotionManager {
    // 1. 创建
    self.motionManager = [[CMMotionManager alloc] init];
    // 2. 判断是否可用
    if (!self.motionManager.isAccelerometerAvailable) {
        return;
    }
    
    // pull 方式， 由我们决定
    [self.motionManager startAccelerometerUpdates];
    
    // push 方式, 一直有
    // 3. 设置间隔
//    self.motionManager.gyroUpdateInterval = 1;
//    self.motionManager.accelerometerUpdateInterval = 1;
    // 4. 开始采样
//    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//        CMAcceleration acceleration = accelerometerData.acceleration;
//        NSLog(@"%.2f %.2f %.2f", acceleration.x, acceleration.y, acceleration.z);
//    }];
}

/*
 总结： 旋转视图的要点
 1. controller 作为 子controller 添加到 父viewController上。
 2. 旋转时，改变的是 controller.view  的transform。
 3. 设置 statusBarOrientation 时，需要注意 info.plist文件中，View controller-based status bar appearance
    默认plist文件中无该选项，需要添加。如果为yes，则view Controller 优先级高于 application，为no则以application 为准。
 4. 如果想要获取设备的矢量方向可以用加速器获取力的方向，来判断
 */


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
