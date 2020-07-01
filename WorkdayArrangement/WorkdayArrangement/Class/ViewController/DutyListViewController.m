//
//  DutyListViewController.m


#import "DutyListViewController.h"
#import "DutyListCell.h"
#import "ActionSheetPicker.h"
#import "CalendarDayModel.h"
#import "UIScrollView+DREmptyDataSet.h"
static const int heightTop = 44;

@interface DutyListViewController ()
{
    NSInteger yearSelect;
    NSInteger monthSelect;
    BOOL hadLoad;
}
@property (strong, nonatomic) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableDictionary *dictData;

@property (nonatomic, strong) NSString *strDateSelect;
@property (nonatomic, strong) UILabel *labelDate;

@property (nonatomic, strong) NSArray *arrDataDate;
@property (nonatomic, strong) NSArray *arrDateSelection;

@end

@implementation DutyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"List";
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self.tableView setupEmptyDataText:@"No staff scheduling" verticalOffset:0 emptyImage:[UIImage imageNamed:@"nodata"] tapBlock:^{

        
    }];
    [self buildData];
    [self buildView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (hadLoad) {
        [self buildDataDuty];
        [self.tableView reloadData];
    }else{
        hadLoad = true;
    }
    
}

- (void)buildData {
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    monthSelect = [components month];
    yearSelect = [components year];
    
    NSMutableArray * arrYear = [NSMutableArray new];
    NSMutableArray * arrMonth = [NSMutableArray new];
    for (int i = 2000; i < 2050; i++) {
        [arrYear addObject:[NSString stringWithFormat:@"%d",i]];
    }
    for (int i = 1; i < 13; i++) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
        NSString *monthName = [[df monthSymbols] objectAtIndex:(i-1)];
        [arrMonth addObject:monthName];
    }
    
    _arrDataDate = @[arrYear,arrMonth];
    
}

- (void)buildDataDuty {
    _arrData = [NSMutableArray new];
    
    NSString *strFilter = [NSString stringWithFormat:@"yearMonth = '%@'",_strDateSelect];
    RLMResults<RMDayDuty *>  *arrRM = [[RMDayDuty objectsWhere:strFilter] sortedResultsUsingKeyPath:@"day" ascending:TRUE];
    
    for (RMDayDuty *rm in arrRM) {
        CalendarDayModel *model = [CalendarDayModel new];
        model.name = rm.name;
        model.day = rm.day;
        model.weekdayName = [CommTools weekdayName:rm.pKeyDate];
        [_arrData addObject:model];
    }
    
    _dictData = [NSMutableDictionary new];
    RLMResults<RMEmployee *> *employees = [RMEmployee allObjects];
    for (int i=0; i<employees.count; i++) {
        RMEmployee *rm = [employees objectAtIndex:i];
        [_dictData setObject:@(i%8) forKey:rm.name];
    }
    
    [self.tableView reloadData];
}

- (void)buildView {
    [self.navigationController.navigationBar setValue:@(YES) forKey: @"hidesShadow"];
    
    self.tableView.frame = CGRectMake(0, heightTop, kScreen_Width, kScreen_Height-64-heightTop-50);
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, heightTop)];
    viewBg.backgroundColor = kSubjectColor;
    
    self.labelDate = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, heightTop)];
    self.labelDate.textColor = [UIColor whiteColor];
    [viewBg addSubview: _labelDate];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(84, (heightTop-6)/2, 12, 6)];
    [imageView setImage:[UIImage imageNamed:@"x_white.png"]];
    [viewBg addSubview: imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, heightTop)];
    button.tag = 10;
    [button addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
    [viewBg addSubview: button];
    [self.view addSubview:viewBg];
    [self reloadViewLabelDate];
    
}

- (void)reloadViewLabelDate {
    NSString *m = [CommTools formatAddZero:monthSelect];
    _strDateSelect = [NSString stringWithFormat:@"%@-%@",@(yearSelect),m];
    _labelDate.text = _strDateSelect;
    _arrDateSelection = @[@(yearSelect-2000), @(monthSelect-1)];
    
    [self buildDataDuty];
}

#pragma mark ------------Tableview Delegete、DataSource------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row= indexPath.row;
    
    static NSString *voucherCellIdentifior = @"DutyListCell";
    DutyListCell *cell =(DutyListCell *)[tableView dequeueReusableCellWithIdentifier:voucherCellIdentifior];
    if (cell==nil) {
        cell =[[NSBundle mainBundle] loadNibNamed:voucherCellIdentifior owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = tableView.backgroundColor;
        [cell.viewBg setClipsToBounds:TRUE];
        [cell.viewBg.layer setCornerRadius:6];
        
        [cell.labelDay setClipsToBounds:TRUE];
        [cell.labelDay.layer setCornerRadius:4];
    }
    CalendarDayModel *model = _arrData[row];
    
    NSNumber *indexColor = [_dictData objectForKey: model.name];
    if (indexColor != nil) {
        NSInteger i = [indexColor integerValue];
        cell.imageViewRight.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_color_0%ld.png",i+1]];
        cell.labelDay.backgroundColor = [CommTools colorTheme:i];
    }
    
    
    
    cell.labelName.text = model.name;
    cell.labelWeekday.text = model.weekdayName;
    cell.labelDay.text = [NSString stringWithFormat:@"%ld",model.day];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 通过取消选中动画，在短时间内提示用户选中了某一行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSInteger row= indexPath.row;
    
    
}


#pragma mark --UITableView Cell、Header、Footer高度

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
    
}

- (void)actButton:(UIButton*)sender{
    
    NSInteger tag = sender.tag;
    if (tag == 10) {
        [ActionSheetMultipleStringPicker showPickerWithTitle:@"Select the date" rows:_arrDataDate initialSelection:_arrDateSelection doneBlock:^(ActionSheetMultipleStringPicker *picker, NSArray *selectedIndexes, id selectedValues) {
            //        NSLog(@"%@", selectedIndexes);
            //        NSLog(@"%@", [selectedValues componentsJoinedByString:@", "]);
            self->yearSelect = [selectedValues[0] integerValue];
            self->monthSelect = [selectedIndexes[1] integerValue]+1;
            [self reloadViewLabelDate];
        } cancelBlock:^(ActionSheetMultipleStringPicker *picker) {
            NSLog(@"picker = %@", picker);
        } origin:(UIView *)_labelDate];
    }
    
}

@end

