//
//  EmployeeListViewController.m


#import "EmployeeListViewController.h"
#import "EmployeeCell.h"



@interface EmployeeListViewController ()

@property (strong, nonatomic) NSMutableArray *arrData;

@end

@implementation EmployeeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"Edit";
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self buildData];
    [self buildView];
    
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)buildData {
    _arrData = [NSMutableArray new];
    RLMResults<RMEmployee *> *employees = [RMEmployee allObjects];
    for (RMEmployee *rm in employees) {
        [_arrData addObject:rm.name];
    }
    [self.tableView reloadData];
}

- (void)buildView {
    UIView *viewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100)];
    UIButton *buttonEdit = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-56)/2, 60, 56, 56)];
    [buttonEdit setBackgroundImage:[UIImage imageNamed:@"jj.png"] forState:UIControlStateNormal];
    buttonEdit.tag = 10;
    [buttonEdit addTarget:self action:@selector(actButton:) forControlEvents: UIControlEventTouchUpInside];
    [viewBg addSubview:buttonEdit];
    
    self.tableView.tableFooterView = viewBg;
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
    
    static NSString *voucherCellIdentifior = @"EmployeeCell";
    EmployeeCell *cell =(EmployeeCell *)[tableView dequeueReusableCellWithIdentifier:voucherCellIdentifior];
    if (cell==nil) {
        cell =[[NSBundle mainBundle] loadNibNamed:voucherCellIdentifior owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (row%2 == _arrData.count%2) {
        cell.backgroundColor = tableView.backgroundColor;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSString *name = _arrData[row];
    cell.labelName.text = name;


    cell.buttonDel.tag = 100+row;
    [cell.buttonDel addTarget:self action:@selector(actButton:) forControlEvents:UIControlEventTouchDown];
    
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
    return 44;
    
}

- (void)actButton:(UIButton*)sender{
    
    NSInteger tag = sender.tag;
    if (tag == 10) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Employee Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField becomeFirstResponder];
            textField.placeholder = @"please enter";
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *text = [[alertController textFields][0] text];
            if (text.length > 0) {
                [self saveName:text];
            }else{
                [SVProgressHUD showErrorWithStatus:@"The name cannot be empty"];
            }
            //NSLog(@"Current password %@", [[alertController textFields][0] text]);

            
        }];
        [alertController addAction:confirmAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Canelled");
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        NSUInteger index = tag-100;
        NSString *name = _arrData[index];
        [self deleteButtonPressed:name delForIndex: index];
    }
    
    
    
}

- (void)deleteButtonPressed:(NSString *) name delForIndex:(NSUInteger )index{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Delete"
                                 message:[NSString stringWithFormat:@"This will delete all data of %@",name]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Delete"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [self delName:name delForIndex: index];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveName:(NSString *) name{
    NSString *strFilter = [NSString stringWithFormat:@"name = '%@'",name];
    RLMResults<RMEmployee *>  *arrRM = [RMEmployee objectsWhere:strFilter];
    if (arrRM.count > 0) {
        [SVProgressHUD showErrorWithStatus:@"Existing name"];
        return;
    }
    
    RMEmployee *realmModel = [[RMEmployee alloc] init];
    realmModel.name = name;
    realmModel.dateCreate = [NSDate new];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:realmModel];
    }];
    [_arrData addObject:name];
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"Success"];
}

- (void)delName:(NSString *) name delForIndex:(NSUInteger )index{
    NSString *strFilter = [NSString stringWithFormat:@"name = '%@'",name];
    RLMResults<RMEmployee *>  *arrRM = [RMEmployee objectsWhere:strFilter];
    
    NSString *strFilter2 = [NSString stringWithFormat:@"name = '%@'",name];
    RLMResults<RMDayDuty *>  *arrRM2 = [RMDayDuty objectsWhere:strFilter2];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteObject:[arrRM firstObject]];
        [realm deleteObjects:arrRM2];
    }];
    [_arrData removeObjectAtIndex:index];
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"Deleted"];
}



@end
