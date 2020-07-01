//
//  BaseListViewController.m


#import "BaseListViewController.h"

@interface BaseListViewController ()

@end

@implementation BaseListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    //[self setExtraCellLineHidden];
    
}



- (void) initTableView
{
    _tableView =  [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=kColorLightGaryBg;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
//}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    
    
}



#pragma mark --隐藏多余的分割线
- (void)setExtraCellLineHidden {
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
}


@end
