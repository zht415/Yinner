//
//  YKTabbarController.m
//  Yinner
//
//  Created by Maru on 15/12/8.
//  Copyright © 2015年 Alloc. All rights reserved.
//

#import "YKTabbarController.h"
#import "YKDock.h"
#import "YKPersonnalView.h"
#import "YKFansListController.h"
#import "YKWorksListController.h"
#import "YKModaController.h"
#import "YKNavigationController.h"
#import "YKTranstaionAnimator.h"

@interface YKTabbarController () <YKPersonnalViewDelegate,UIViewControllerTransitioningDelegate>
{
    YKDock *_dock;
    UIPanGestureRecognizer *_pan;
    YKPersonnalView *_siderView;
    UIView *_maskView;
    CGPoint _beginPoint;
}
@property (nonatomic,assign) BOOL isSlidering;
@end
@implementation YKTabbarController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingDock];
    
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupGestureRecognizer];
}

#pragma mark - 初始化图标

- (void)setupView {
}

- (void)settingDock
{
    
    _dock = [[YKDock alloc] initWithFrame:self.tabBar.bounds];
    // 添加item
    [_dock addDockItemWithIcon:@"tabbar_home.png" title:@"首页"];
    [_dock addDockItemWithIcon:@"Icon-40.png" title:@""];
    [_dock addDockItemWithIcon:@"tabbar_more.png" title:@"音库"];
    [self.tabBar addSubview:_dock];

    __weak typeof(self) weakSelf = self;
    // 监听按钮的点击
    _dock.itemClickBlock = ^(int index)
    {
        [weakSelf selectDockItemAt:index];
    };
    
    // 默认第一次点击
    _dock.selectedIndex = 0;
}

#pragma mark 选中的方法
- (void)selectDockItemAt:(int)index
{
    if (index == 0) {
        _pan.enabled = YES;
        self.selectedIndex = 0;
    }else if (index == 1) {
        YKNavigationController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"matterLib"];
        vc.transitioningDelegate = self;
        vc.modalTransitionStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    }else {
        _pan.enabled = NO;
        self.selectedIndex = 1;
    }
}

- (void)setupGestureRecognizer
{
    //创建pan手势
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGuestureRecginizer:)];
        [self.view addGestureRecognizer:_pan];
    }
    
    //懒加载sliderView
    if (_siderView == nil) {
        _siderView = [[[NSBundle mainBundle] loadNibNamed:@"YKPersonnalView" owner:self options:nil] lastObject];
        _siderView.center = CGPointMake(125, KwinH * 0.5);
        _siderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
        _siderView.delegate = self;
        [self.view.window addSubview:_siderView];
        [self.view.window sendSubviewToBack:_siderView];
        //创建背景界面
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        bgImageView.image = [UIImage imageNamed:@"sidebar_bg"];
        [self.view.window insertSubview:bgImageView belowSubview:_siderView];
    }
}


#pragma mark 手势方法
- (void)showPersonalView:(UIPanGestureRecognizer *)pan
{
    self.isSlidering = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = CGPointMake((KwinW / 2) + 200, KwinH / 2);
        self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        _siderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }];
    
}

- (void)dismissPersonnalView:(UIPanGestureRecognizer *)pan
{
    self.isSlidering = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = CGPointMake(KwinW / 2, KwinH / 2);
        self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        _siderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    }];
    
}

- (void)onPanGuestureRecginizer:(UIPanGestureRecognizer *)pan
{
    //获取手指的初始坐标
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginPoint = [pan locationInView:self.view.window];
    }
    
    CGFloat instance = [pan locationInView:self.view.window].x - _beginPoint.x;
    
    //判断是否需要进行动画
    if (instance > 0 && self.view.center.x == (KwinW / 2) + 200) {
        return;
    }
    else if(instance < 0 && self.view.center.x == (KwinW / 2))
    {
        return;
    }
    
    //动画判断
    if (instance >= 200) {
        [self showPersonalView:pan];
    }
    else if (instance <= -200) {
        [self dismissPersonnalView:pan];
    }
    else if (instance > 0 && instance < 200)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.center = CGPointMake((KwinW / 2) + instance, KwinH / 2);
            self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1 - 0.2 * (instance / 200), 1 - 0.2 * (instance / 200));
            _siderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7 + 0.3 * (instance / 200), 0.7 + 0.3 * (instance / 200));
        }];
    }
    else if (instance > -200 && instance < 0)
    {
        self.view.center = CGPointMake((KwinW / 2) + instance + 200, KwinH / 2);
        self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8 + 0.2 * (-instance / 200), 0.8 + 0.2 * (-instance / 200));
        _siderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1 - 0.3 * (-instance / 200), 1 - 0.3 * (-instance / 200));
    }
    
    
    //结束手势判断
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (instance > 100 || (instance > -100 && instance < 0)) {
            [self showPersonalView:_pan];
        }
        else if (instance < - 100 || (instance < 100 && instance > 0))
        {
            [self dismissPersonnalView:_pan];
        }
    }
    
}

#pragma mark - Transition Delegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [YKTranstaionAnimator new];
}



#pragma mark - personnalvcDelegate
- (void)personnalHeadClick {
    [self dismissPersonnalView:_pan];
    
    [YKSkipHelper skipToHeadImageSetting];
}

- (void)personnalSettingClick
{
    [self dismissPersonnalView:_pan];
    
    [self performSegueWithIdentifier:@"setting" sender:self];
}

- (void)personnalHomeClick
{
    [self dismissPersonnalView:_pan];
}

- (void)personnalFriendClick
{
    [self dismissPersonnalView:_pan];
    
    [self performSegueWithIdentifier:@"friend" sender:self];
}

- (void)personnalMessageClick
{
    [self dismissPersonnalView:_pan];
    
    [self performSegueWithIdentifier:@"message" sender:self];
}

- (void)personnalFansClick {
    [self dismissPersonnalView:_pan];

    YKFansListController *fanVC = [[UIStoryboard storyboardWithName:@"Independent" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"YKFansListController"];
    
    YKModaController *nav = [[YKModaController alloc] initWithRootViewController:fanVC];

    [self presentViewController:nav animated:YES completion:nil];
}

- (void)personnalWorksClick {
    [self dismissPersonnalView:_pan];
    
    YKWorksListController *workVC = [[UIStoryboard storyboardWithName:@"Independent" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"YKWorksListController"];
    
    YKModaController *nav = [[YKModaController alloc] initWithRootViewController:workVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Get&Set
- (void)setIsSlidering:(BOOL)isSlidering
{
    
    if (isSlidering) {
        
        if(!_maskView)
        {
            _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            _maskView.backgroundColor = [UIColor blackColor];
            _maskView.alpha = 0.2;
            UIPanGestureRecognizer *backPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGuestureRecginizer:)];
            [_maskView addGestureRecognizer:backPan];
        }
        [self.view addSubview:_maskView];
    }
    else
    {
        [_maskView removeFromSuperview];
    }
    
    
}


@end
