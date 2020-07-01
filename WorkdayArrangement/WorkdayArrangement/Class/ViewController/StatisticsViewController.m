//
//  StatisticsViewController.m


#import "StatisticsViewController.h"
#import "ActionSheetPicker.h"
#import "CalendarDayModel.h"
#import "StatisticsItemCell.h"
#import "EmployeeModel.h"
#import "UIScrollView+DREmptyDataSet.h"

@interface StatisticsViewController ()
{
    NSInteger yearSelect;
    NSInteger monthSelect;
    BOOL hadLoad;
    NSUInteger indexUnfold;
}
@property (strong, nonatomic) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableDictionary *dictData;

@property (nonatomic, strong) NSString *strDateSelect;
@property (nonatomic, strong) UILabel *labelDate;

@property (nonatomic, strong) NSMutableArray *arrDataSection;
@property (nonatomic, strong) NSMutableArray *arrDateRow;

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Statistics";
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.tableView setupEmptyDataText:@"No staff scheduling" verticalOffset:0 emptyImage:[UIImage imageNamed:@"nodata"] tapBlock:^{
        
        
    }];
    [self buildData];
    [self buildView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (hadLoad) {
        [self buildData];
        
    }else{
        hadLoad = true;
    }
    
}

- (void)buildData {
    
    NSMutableArray *arrMonth = [NSMutableArray new];
    NSMutableArray *arrMonthDay = [NSMutableArray new];
    NSMutableDictionary *dictMonth = [NSMutableDictionary new];
    NSInteger index = -1;
    
    RLMResults<RMDayDuty *>  *arrRM = [[RMDayDuty allObjects] sortedResultsUsingKeyPath:@"yearMonth" ascending:FALSE];
    for (int i=0; i<arrRM.count; i++) {
        RMDayDuty *rm = [arrRM objectAtIndex:i];
        
        if (![arrMonth containsObject:rm.yearMonth]) {
            [arrMonth addObject:rm.yearMonth];
            dictMonth = [NSMutableDictionary new];
            [arrMonthDay addObject:dictMonth];
            index++;
        }
        NSMutableDictionary *dict = [arrMonthDay objectAtIndex:index];
        
        NSNumber *countOld = [dictMonth objectForKey:rm.name];
        NSNumber *countNew;
        if (countOld == nil) {
            countNew = @(1);
        }else{
            countNew = @(countOld.integerValue+1);
        }
        [dict setObject:countNew forKey:rm.name];
        [arrMonthDay replaceObjectAtIndex:index withObject:dict];

    }
    _arrDataSection = arrMonth;
    
    _arrDateRow = [NSMutableArray new];
    for (NSMutableDictionary *dict in arrMonthDay) {
        NSMutableArray *arr = [NSMutableArray new];
        for (NSString* key in dict) {
            NSNumber *value = dict[key];
            EmployeeModel *model = [EmployeeModel new];
            model.name = key;
            model.dutyTimes = [value integerValue];
            [arr addObject:model];
        }
        
        NSArray *comparatorSortedArray = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            EmployeeModel *model1 = obj1;
            EmployeeModel *model2 = obj2;
            
            if(model1.dutyTimes < model2.dutyTimes ){
                return(NSComparisonResult)NSOrderedDescending;
            }
            
            if(model1.dutyTimes < model2.dutyTimes){
                return(NSComparisonResult)NSOrderedAscending;
            }
            return(NSComparisonResult) NSOrderedSame;
        }];

        

        [_arrDateRow addObject:comparatorSortedArray];
    }
    [self.tableView reloadData];
    
}

- (void)buildDataDuty {
    
}

- (void)buildView {
    //[self.navigationController.navigationBar setValue:@(YES) forKey: @"hidesShadow"];
    
    self.tableView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-64-50);
    
}


#pragma mark ------------Tableview Delegete、DataSource------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _arrDataSection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (indexUnfold == section) {
        NSArray *arr = _arrDateRow[section];
        return arr.count+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row= indexPath.row;
    NSInteger section= indexPath.section;
    static NSString *voucherCellIdentifior = @"StatisticsItemCell";
    StatisticsItemCell *cell =(StatisticsItemCell *)[tableView dequeueReusableCellWithIdentifier:voucherCellIdentifior];
    if (cell==nil) {
        cell =[[NSBundle mainBundle] loadNibNamed:voucherCellIdentifior owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //cell.backgroundColor = tableView.backgroundColor;

    }
    if (indexUnfold != section) {
        return cell;
    }
    if (row == 0) {
        [cell.viewDot setHidden:TRUE];
        cell.labelName.text =@"Employee name";
        cell.labelCount.text =@"Number of shifts";
    }else{
        NSArray *arr = _arrDateRow[section];
        EmployeeModel *model = arr[row-1];
        cell.labelName.text = model.name;
        cell.labelCount.text = [NSString stringWithFormat:@"%ld",model.dutyTimes];
        
        [cell.viewDot setHidden:FALSE];
        [cell.viewDot setClipsToBounds:TRUE];
        [cell.viewDot.layer setCornerRadius:5];
        cell.viewDot.backgroundColor = [CommTools colorTheme:row];
        
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 通过取消选中动画，在短时间内提示用户选中了某一行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSInteger row= indexPath.row;
    
    
}

#pragma mark --UITableView 自定义HeaderView、FooterView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.frame.size.width-10, 44)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    label.textColor = kColor666;
    label.text = _arrDataSection[section];
    [label setFont:[UIFont systemFontOfSize:15]];
    
    [viewBg addSubview:label];
    
    if (section%2 == indexUnfold%2) {
        viewBg.backgroundColor = [UIColor whiteColor];
    }else{
        viewBg.backgroundColor = kColorGrayF0;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width-12-13, (44-6)/2, 12, 6)];
    NSString *strImageName;
    if (indexUnfold == section) {
        strImageName = @"x.png";
    }else{
        strImageName = @"s.png";
    }
    imageView.image = [UIImage imageNamed:strImageName];
    [viewBg addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    button.tag = 100+section;
    [button addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
    [viewBg addSubview: button];
    
    return viewBg;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 14)];
    viewBg.backgroundColor = [UIColor whiteColor];
    return viewBg;
}

#pragma mark --UITableView Cell、Header、Footer高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (indexUnfold == section) {
        return 14;
    }
    return 0;
}

#pragma mark --UITableView Cell、Header、Footer高度

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24;
    
}

- (void)actButton:(UIButton*)sender{
    
    NSInteger tag = sender.tag;
    indexUnfold = tag - 100;
    [self.tableView reloadData];
    
}

@end


