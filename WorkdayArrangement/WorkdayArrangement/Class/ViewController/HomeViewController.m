//
//  HomeViewController.m


#import "HomeViewController.h"
#import "ActionSheetPicker.h"
#import "CalendarDayModel.h"
#import "ToEditView.h"
#import "EmployeeListViewController.h"
#import "EmployeeModel.h"
#import "CalendarItemCellCell.h"

#import "LEITopImageButton.h"
static const int heightTop = 44;
static const CGFloat kLineSpacing = 10.f;   //列间距
static const CGFloat kItemSpacing = 0.f;   //item之间的间距
//static const NSInteger numName = 4;

@interface HomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    CGFloat widthDay;
    NSInteger yearSelect;
    NSInteger monthSelect;
    NSInteger daySelect;
    NSInteger indexSelect;
    CGFloat heightCollectionView;
    NSInteger numWorkDay;
    BOOL hadLoad;
    NSInteger numName;
    NSInteger codeBottom; //0: toEdit  1:edit
    CGFloat heightBottom;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *viewBottom;

@property (nonatomic, strong) UILabel *labelDate;
@property (nonatomic, strong) NSArray *arrDataDate;
@property (nonatomic, strong) NSArray *arrDateSelection;

@property (nonatomic, strong) NSString *strDateSelect;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableDictionary *dictData;
@property (nonatomic, strong) NSMutableArray *arrDataEmployee;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Home";
    
    [self buildData];
    [self buildView];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSString *folderPath = realm.configuration.fileURL.URLByDeletingLastPathComponent.path;
    NSLog(@"folderPath :%@", folderPath);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (hadLoad) {
        indexSelect = 0;
        [self buildDataEmployee];
        [self buildDataDuty];
        [self buildViewBottom];
        [_collectionView reloadData];
    }else{
        hadLoad = true;
    }
    
}

- (void)buildData {
    widthDay = (kScreen_Width-20-6*kItemSpacing)/7;;
    if (kScreen_Width>330) {
        numName = 5;
    }else{
        numName = 4;
    }
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
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
    
    [self buildDataEmployee];
}

- (void)buildDataEmployee {
    //获取本地员工数据
    _arrDataEmployee = [NSMutableArray new];
    RLMResults<RMEmployee *> *employees = [RMEmployee allObjects];
    for (RMEmployee *rm in employees) {
        EmployeeModel *model = [EmployeeModel new];
        model.name = rm.name;
        [_arrDataEmployee addObject:model];
    }
}

- (void)buildDataDuty {
    _dictData = [NSMutableDictionary dictionaryWithCapacity:50];
    
    NSString *strFilter = [NSString stringWithFormat:@"yearMonth = '%@'",_strDateSelect];
    RLMResults<RMDayDuty *>  *arrRM = [RMDayDuty objectsWhere:strFilter] ;
    for (RMDayDuty *rm in arrRM) {
        [_dictData setObject:rm.name forKey:[NSString stringWithFormat:@"%ld",rm.day]];
    }
    //NSLog(@"_dictData： (%@)", _dictData);
}

- (void)buildDataCalendar {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //本月第一天的NSDate对象
    NSDate *nowMonthfirst = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%d",yearSelect,monthSelect,1]];
    //本月的天数范围
    NSRange dayRange = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:nowMonthfirst];
    //本月第一天是星期几
    NSDateComponents * components = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:nowMonthfirst];
    NSInteger firstDayWeekday = [components weekday];
    
    //本月最后一天的NSDate对象
    NSDate * nextDay = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld",yearSelect,monthSelect,dayRange.length]];
    NSDateComponents * lastDay = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:nextDay];
    NSInteger dayLast = lastDay.day;
    //NSLog(@"dayLast - %ld", dayLast);
    
    [self buildDataDuty];
    
    _arrData = [NSMutableArray new];
    numWorkDay = 0;
    NSInteger dayIndex = 1;
    for (int i=0; i<dayLast+firstDayWeekday-1; i++) {
        CalendarDayModel *model = [CalendarDayModel new];
        if (i<firstDayWeekday-1) {
            model.day = 0;
        }else{
            model.day = dayIndex;
            model.weekday = i%7;
            if (model.weekday!=0 && model.weekday!=6){
                numWorkDay++;
            }
            dayIndex++;
        }
        [_arrData addObject:model];
    }
    [self buildViewCollectionView];
    //[_collectionView reloadData];
}


- (void)buildView {
    
    [self.navigationController.navigationBar setValue:@(YES) forKey: @"hidesShadow"];
    
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-48-64)];
    [self.view addSubview:_scrollView];
    
    [self buildViewDate];
}

- (void)reloadViewLabelDate {
    NSString *m = [CommTools formatAddZero:monthSelect];
    _strDateSelect = [NSString stringWithFormat:@"%@-%@",@(yearSelect),m];
    _labelDate.text = _strDateSelect;
    _arrDateSelection = @[@(yearSelect-2000), @(monthSelect-1)];
    [self buildDataCalendar];
}

- (void)buildViewDate {
    
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, heightTop)];
    viewBg.backgroundColor = kSubjectColor;
    [self.scrollView addSubview:viewBg];
    
    self.labelDate = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, heightTop)];
    //self.labelDate.text = @"2018-08";
    self.labelDate.textColor = [UIColor whiteColor];
    [self.scrollView addSubview: _labelDate];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(84, (heightTop-6)/2, 12, 6)];
    [imageView setImage:[UIImage imageNamed:@"x_white.png"]];
    [self.scrollView addSubview: imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, heightTop)];
    button.tag = 10;
    [button addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
    [self.scrollView addSubview: button];
    
    [self reloadViewLabelDate];
}

- (void)buildViewCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kItemSpacing;
    layout.minimumLineSpacing      = kLineSpacing;
    int rows = (int)_arrData.count/7;
    if (_arrData.count%7 != 0) {
        rows++;
    }
    heightCollectionView = rows*(widthDay+10);
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(10, heightTop+14, kScreen_Width-20, heightCollectionView) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView setScrollEnabled:FALSE];
    //[_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CalendarItemCellCell" bundle:nil] forCellWithReuseIdentifier:@"CalendarItemCellCell"];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:_collectionView];
    
    [self buildViewBottom];
}

- (void)buildViewBottom {
    CGFloat y = Y(_collectionView)+heightCollectionView+30;
    for (UIView *oldViews in _viewBottom.subviews)
    {
        [oldViews removeFromSuperview];
    }
    if (codeBottom == 1) {
        UIView *viewEdit = [self buildViewBottomEdit:y];
        _viewBottom = viewEdit;
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(actButton:)];
        buttonItem.tag = 13;
        self.navigationItem.rightBarButtonItem = buttonItem;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
        ToEditView *toEditView=[self getClassObjectFromNib:[ToEditView class]];
        toEditView.frame=CGRectMake(0, y, kScreen_Width, 300);
        [toEditView.buttonToEdit setClipsToBounds:TRUE];
        [toEditView.buttonToEdit.layer setCornerRadius:6];
        toEditView.buttonToEdit.tag = 11;
        [toEditView.buttonToEdit addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
        
        toEditView.daysWork.text = [NSString stringWithFormat:@"%ld",numWorkDay];
        NSArray *arr = [_dictData allValues];
        NSSet *set = [NSSet setWithArray:arr];
        toEditView.labelPeople.text = [NSString stringWithFormat:@"%ld",set.count];
        _viewBottom = toEditView;
        heightBottom = 170;
    }
    
    [_scrollView addSubview:_viewBottom];
    [_scrollView setContentSize:CGSizeMake(kScreen_Width, y+heightBottom)];
}

- (UIView *)buildViewBottomEdit:(CGFloat ) y{
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, y, kScreen_Width, 300)];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    labelTitle.text = @"Choose employees on duty";
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.font = [UIFont systemFontOfSize:15];
    labelTitle.textColor = kColor999;
    [viewBg addSubview:labelTitle];
    
    CGFloat widthView = (kScreen_Width-20)/numName;
    NSInteger countName = _arrDataEmployee.count+1;
    CGFloat yButtonEdit = 0;
    for (int i=0; i<countName; i++) {
        NSInteger row = i/numName;
        NSInteger col = i%numName;
        UIView *viewItem = [[UIView alloc] initWithFrame:CGRectMake(10+widthView*col, 46+45*row, widthView, 46)];
        yButtonEdit = Y(viewItem) + H(viewItem);
        UIButton *button;
        if (i == 0 ) {
            button = [[UIButton alloc] initWithFrame:CGRectMake((widthView-40)/2, 3, 40, 40)];
            [button setBackgroundColor:kSubjectColor];
            [button setTitle:@"Delete" forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [button setClipsToBounds:TRUE];
            [button.layer setCornerRadius:20];
        }else{
            EmployeeModel *model = _arrDataEmployee[i-1];
            button = [[UIButton alloc] initWithFrame:CGRectMake((widthView-70)/2, 8, 70, 30)];
            [button setBackgroundColor: [CommTools colorTheme:i-1]];
            [button setTitle:model.name forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [button setClipsToBounds:TRUE];
            [button.layer setCornerRadius:6];
            
        }
        //[button setBackgroundColor:kColor999];
        button.tag = 99+i;
        [button addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
        [viewItem addSubview:button];
        [viewBg addSubview:viewItem];
    }
    
    UIButton *buttonEdit = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-42-13, yButtonEdit+30, 42, 42)];
    //[buttonEdit setBackgroundColor: [CommTools colorTheme:i+1]];
    [buttonEdit setBackgroundImage:[UIImage imageNamed:@"jj.png"] forState:UIControlStateNormal];
    buttonEdit.tag = 12;
    [buttonEdit addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
    [viewBg addSubview:buttonEdit];
    
    heightBottom = Y(buttonEdit) + H(buttonEdit)+30;
    return viewBg;
}

#pragma mark - collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarItemCellCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarItemCellCell" forIndexPath:indexPath];
    NSUInteger index = indexPath.row;
    CalendarDayModel *model = [_arrData objectAtIndex:index];
    if (model.day == 0) {
        [cell.viewBg setHidden:TRUE];
        return cell;
    }else{
        [cell.viewBg setHidden:FALSE];
    }
    
    //cell.viewBg.backgroundColor = [UIColor whiteColor];
    
    [cell.viewBg.layer setCornerRadius:6];
    
    cell.labelTitle.text = [NSString stringWithFormat:@"%@",@(model.day)];
    if (model.weekday == 6 || model.weekday == 0) {
        cell.viewBg.backgroundColor = kSubjectColor;
        cell.labelTitle.textColor = [UIColor whiteColor];
        cell.labelName.textColor = [UIColor whiteColor];
        cell.labelName.text = @"";
    }else{
        NSString *key = [NSString stringWithFormat:@"%ld",model.day];
        NSString *name = [_dictData objectForKey: key];
        if (name == nil) {
            cell.labelName.text = @"";
        }else{
            cell.labelName.text = name;
        }
        if (index == indexSelect) {
            cell.viewBg.backgroundColor = kSubjectColorLight;
            cell.labelTitle.textColor = [UIColor whiteColor];
            cell.labelName.textColor = [UIColor whiteColor];
        }else{
            cell.viewBg.backgroundColor = kColorGrayEF;
            cell.labelTitle.textColor = kColor999;
            cell.labelName.textColor = kColor999;
        }
    }
    //cell.labelName.text = @"stringWithFo";
    return cell;
    
    return cell;
}


//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    NSUInteger index = indexPath.row;
//    CalendarDayModel *model = [_arrData objectAtIndex:index];
//    if (model.day == 0) {
//        return cell;
//    }
//
//    cell.backgroundColor = [UIColor whiteColor];
//
//    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(5, 0, widthDay-10, widthDay-10)];
//
//    [viewBg.layer setCornerRadius:6];
//    [cell addSubview:viewBg];
//
//    UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(6, 4, widthDay-10, 20)];
//    labelDay.font = [UIFont systemFontOfSize:14];
//    [viewBg addSubview:labelDay];
//
//    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(6, H(viewBg)-24, widthDay-10, 20)];
//    labelName.font = [UIFont systemFontOfSize:11];
//    [viewBg addSubview:labelName];
//
//    labelDay.text = [NSString stringWithFormat:@"%@",@(model.day)];
//    if (model.weekday == 6 || model.weekday == 0) {
//        viewBg.backgroundColor = kSubjectColor;
//        labelDay.textColor = [UIColor whiteColor];
//        labelName.textColor = [UIColor whiteColor];
//    }else{
//        NSString *key = [NSString stringWithFormat:@"%ld",model.day];
//        NSString *name = [_dictData objectForKey: key];
//        if (name != nil) {
//            labelName.text = name;
//        }
//        if (model.day == daySelect) {
//            viewBg.backgroundColor = kSubjectColorLight;
//            labelDay.textColor = [UIColor whiteColor];
//            labelName.textColor = [UIColor whiteColor];
//        }else{
//            viewBg.backgroundColor = kColorGrayEF;
//            labelDay.textColor = kColor999;
//            labelName.textColor = kColor999;
//        }
//    }
//    labelName.text = @"stringWithFo";
//    return cell;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = indexPath.row;
    

    
    if (codeBottom != 1) {
        return;
    }
    NSLog(@"%@",self.dictData);
    
    if (self.arrDataEmployee.count == 0) {
        [self showMessage:@"No staff clicks the button at the bottom left of the screen to add people"];
    }
    indexSelect = index;
//    CalendarDayModel *model = [_arrData objectAtIndex:index];
//    daySelect = model.day;
    [_collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(widthDay, widthDay);
}



- (void)onDatePicked:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"onDatePicked");
}

- (void)actButton:(UIButton*)sender{
    NSUInteger tag = sender.tag;
    //NSLog(@"tag %ld",tag);
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
    }else if (tag == 11) {
        codeBottom = 1;
        [self buildViewBottom];
    }else if (tag == 12) {
        EmployeeListViewController *vc = [[EmployeeListViewController alloc] init];
        [[self navigationController] pushViewController:vc animated:YES];
    }else if (tag == 13) {
        codeBottom = 0;
        indexSelect = 0;
        [self buildViewBottom];
        [_collectionView reloadData];
    }
    else{
        CalendarDayModel *model = [_arrData objectAtIndex:indexSelect];
        if (model.day == 0) {
            [self showMessage:@"Please select a date in the calendar now and then do it again.(Please note: the date on the red background is weekend, not available)"];
            return;
        }
        NSString *strKeyDate = [NSString stringWithFormat:@"%@-%@",_strDateSelect, [CommTools formatAddZero:model.day]];
        if (tag == 99) {
            NSLog(@"%@",[_dictData objectForKey:[NSString stringWithFormat:@"%ld",model.day]]);
            
            
            if (![_dictData objectForKey:[NSString stringWithFormat:@"%ld",model.day]]) {
                [self showMessage:@"There is no person on the day you choose, please arrange the person before deleting."];
            }
            
            //Delete
            [_dictData removeObjectForKey:[NSString stringWithFormat:@"%ld",model.day]];
            [_collectionView reloadData];
            
            NSString *strFilter = [NSString stringWithFormat:@"pKeyDate = '%@'",strKeyDate];
            RLMResults<RMDayDuty *>  *arrRM = [RMDayDuty objectsWhere:strFilter];
            if (arrRM.count > 0) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    [realm deleteObjects:arrRM];
                }];
            }
            
            
        }else{
            NSUInteger index = tag-100;
            EmployeeModel *modelEmployee = _arrDataEmployee[index];
            
            [_dictData setObject:modelEmployee.name forKey:[NSString stringWithFormat:@"%ld",model.day]];
            [_collectionView reloadData];
            
            RMDayDuty *realmModel = [[RMDayDuty alloc] init];
            realmModel.name = modelEmployee.name;
            realmModel.day = model.day;
            realmModel.pKeyDate = strKeyDate;
            realmModel.yearMonth = _strDateSelect;
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                //[realm addObject:realmModel];
                [realm addOrUpdateObject:realmModel];
            }];
            
            
        }
        
    }
    
    
    
    
}
-(void)showMessage:(NSString *)message{
    
    
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:@"Note" message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction*action = [UIAlertAction
                            actionWithTitle:@"Sure"
                            style:UIAlertActionStyleDefault handler:nil];
    
    
    [alert addAction:action];
    
    [self presentViewController:alert
                       animated:YES completion:nil];
    
    
    
}
@end
