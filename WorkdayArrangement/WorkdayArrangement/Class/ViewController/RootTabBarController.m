//
//  RootTabBarController.m


#import "RootTabBarController.h"
#import "ViewController.h"
#import "HomeViewController.h"
#import "DutyListViewController.h"
#import "StatisticsViewController.h"


@interface RootTabBarController ()


@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTabBarController];
}

- (void)initTabBarController {

    NSArray *arrTabTitle = @[@"Home", @"List", @"Statistics"];
//    NSArray *arrVc = @[[HomeViewController new],[DutyListViewController new], [StatisticsViewController new]];
    NSArray *arrVc = @[[HomeViewController new],[DutyListViewController new], [StatisticsViewController new]];

    NSMutableArray *arrTab = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        UIViewController *vc = [arrVc objectAtIndex:i];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"tab_%d",i+1]];
        UIImage *imageSelect = [UIImage imageNamed:[NSString stringWithFormat:@"tab_%dxz",i+1]];
        image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        imageSelect=[imageSelect imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:[arrTabTitle objectAtIndex:i] image:image selectedImage:imageSelect];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.tabBarItem = tabBarItem;
        vc.tabBarItem = tabBarItem;
        [arrTab addObject:nvc];
        //NSLog(@"你好，i = %d",i);
    }
    
    self.viewControllers = arrTab;
}


@end
