//
//  PublishRewardStep1ViewController.m
//  CodingMart
//
//  Created by Ease on 15/10/10.
//  Copyright © 2015年 net.coding. All rights reserved.
//

#import "PublishRewardStep1ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ActionSheetStringPicker.h"
#import "TableViewFooterButton.h"

@interface PublishRewardStep1ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *docNotHaveBtn;
@property (weak, nonatomic) IBOutlet UIButton *docHaveBtn;
@property (weak, nonatomic) IBOutlet UIButton *pmNotNeedBtn;
@property (weak, nonatomic) IBOutlet UIButton *pmNeedBtn;

@property (weak, nonatomic) IBOutlet UIImageView *line1V;
@property (weak, nonatomic) IBOutlet UIImageView *line2V;

@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *budgetL;
@property (weak, nonatomic) IBOutlet TableViewFooterButton *nextStepBtn;


@property (strong, nonatomic) NSArray *typeList, *budgetList;

@end

@implementation PublishRewardStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发布悬赏";
    
    _typeList = @[@"网站",
                   @"iOS APP",
                   @"Android APP",
                   @"微信开发",
                   @"HTML5 应用",
                   @"其他"];
    _budgetList = @[@"1万以下",
                    @"1-3万",
                    @"3-5万",
                    @"5万以上"];

    if (!_rewardToBePublished) {
        _rewardToBePublished = [Reward rewardToBePublished];
    }
    
    self.tableView.backgroundColor = kColorTableSectionBg;
    
    UIImage *line_dot_image = [UIImage imageNamed:@"line_dot"];
    line_dot_image = [line_dot_image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode: UIImageResizingModeTile];
    _line1V.image = _line2V.image = line_dot_image;
    
    __weak typeof(self) weakSelf = self;
    [RACObserve(self, rewardToBePublished.require_clear) subscribeNext:^(NSNumber *require_clear) {
        [weakSelf p_setButton:_docNotHaveBtn toSelected:!require_clear.boolValue];
        [weakSelf p_setButton:_docHaveBtn toSelected:require_clear.boolValue];
    }];
    [RACObserve(self, rewardToBePublished.need_pm) subscribeNext:^(NSNumber *need_pm) {
        [weakSelf p_setButton:_pmNotNeedBtn toSelected:!need_pm.boolValue];
        [weakSelf p_setButton:_pmNeedBtn toSelected:need_pm.boolValue];
    }];
    [RACObserve(self, rewardToBePublished.type) subscribeNext:^(NSNumber *type) {
        if (type) {
            weakSelf.typeL.textColor = [UIColor blackColor];
            weakSelf.typeL.text = [[NSObject rewardTypeDict] findKeyFromStrValue:type.stringValue];
        }else{
            weakSelf.typeL.textColor = [UIColor colorWithHexString:@"0xCCCCCC"];
            weakSelf.typeL.text = @"请选择";
        }
    }];
    [RACObserve(self, rewardToBePublished.budget) subscribeNext:^(NSNumber *budget) {
        if (budget) {
            weakSelf.budgetL.textColor = [UIColor blackColor];
            weakSelf.budgetL.text = weakSelf.budgetList[budget.integerValue];
        }else{
            weakSelf.budgetL.textColor = [UIColor colorWithHexString:@"0xCCCCCC"];
            weakSelf.budgetL.text = @"请选择";
        }
    }];
    RAC(self.nextStepBtn, enabled) = [RACSignal combineLatest:@[RACObserve(self, rewardToBePublished.type),
                                                                RACObserve(self, rewardToBePublished.budget)] reduce:^id(NSNumber *type, NSNumber *budget){
                                                                    return @(type != nil && budget != nil);
                                                                }];
}


- (void)p_setButton:(UIButton *)button toSelected:(BOOL)seleted{
    UIColor *foreColor = [UIColor colorWithHexString:seleted? @"0x2FAEEA": @"0xCCCCCC"];
    [button doBorderWidth:1.0 color:foreColor cornerRadius:2.0];
    [button setTitleColor:foreColor forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Btn
- (IBAction)docBtnClicked:(id)sender {
    if (sender == _docHaveBtn) {
        [NSObject showHudTipStr:@"暂时还不支持上传文档"];
    }
}

- (IBAction)pmBtnClicked:(id)sender {
    if ((sender == _pmNeedBtn && !_rewardToBePublished.need_pm.boolValue)
        || ((sender == _pmNotNeedBtn && _rewardToBePublished.need_pm.boolValue))) {
        _rewardToBePublished.need_pm = _rewardToBePublished.need_pm.boolValue? @0: @1;
    }
}


#pragma mark Table M
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerV;
    if (section > 0) {
        headerV = [UIView new];
    }
    return headerV;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat sectionH = 0;
    if (section > 0) {
        sectionH = 10;
    }
    return sectionH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSArray *list;
        NSInteger curRow;
        if (indexPath.row == 0) {
            list = _typeList;
            if (_rewardToBePublished.type) {
                NSString *key = [[NSObject rewardTypeDict] findKeyFromStrValue:_rewardToBePublished.type.stringValue];
                curRow = [list indexOfObject:key];
            }else{
                curRow = 0;
            }
        }else{
            list = _budgetList;
            curRow = _rewardToBePublished.budget? _rewardToBePublished.budget.integerValue: 0;
        }
        __weak typeof(self) weakSelf = self;
        [ActionSheetStringPicker showPickerWithTitle:nil rows:@[list] initialSelection:@[@(curRow)] doneBlock:^(ActionSheetStringPicker *picker, NSArray *selectedIndex, NSArray *selectedValue) {
            NSNumber *selectedRow = selectedIndex.firstObject;
            if (indexPath.row == 0) {
                NSString *value = [[NSObject rewardTypeDict] objectForKey:list[selectedRow.integerValue]];
                weakSelf.rewardToBePublished.type = @(value.integerValue);
            }else{
                weakSelf.rewardToBePublished.budget = selectedRow;
            }
        } cancelBlock:nil origin:self.view];
        
    }
    
}
@end