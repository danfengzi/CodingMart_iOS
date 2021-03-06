//
//  FillTypesViewController.m
//  CodingMart
//
//  Created by Ease on 15/10/28.
//  Copyright © 2015年 net.coding. All rights reserved.
//

#import "FillTypesViewController.h"
#import "FillUserInfoViewController.h"
#import "Coding_NetAPIManager.h"
#import "Login.h"
//#import "IdentityAuthenticationModel.h"
#import "CodingMarkTestViewController.h"
#import "SkillsViewController.h"
#import "IdentityViewController.h"
#import "IdentityPassedViewController.h"
#import "IdentityStep1ViewController.h"
#import "IdentityStep2ViewController.h"
#import "IdentityInfo.h"
#import "MartSurveyViewController.h"

typedef NS_ENUM(NSInteger, IdentityStatusCode)
{
    identity_Unautherized=0,//未认证
    identity_Certificate=1,//认证通过
    identity_Authfaild=2,//认证失败
    identity_Authing=3//认证中
};

@interface FillTypesViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userinfoCheckV;
@property (weak, nonatomic) IBOutlet UIImageView *skillsCheckV;
@property (weak, nonatomic) IBOutlet UIImageView *testingCheckV;
@property (weak, nonatomic) IBOutlet UIImageView *statusCheckV;
@property (weak, nonatomic) IBOutlet UILabel *identityStatusLabel;
@property (strong, nonatomic) IBOutlet UIView *header1V;
@property (strong, nonatomic) IBOutlet UIView *header1TipV;
@property (weak, nonatomic) IBOutlet UILabel *identityTitleL;



@property (strong, nonatomic) User *curUser;

//@property (assign,nonatomic)IdentityStatusCode identityCode;
//@property (strong,nonatomic)NSDictionary *identity_server_CacheDataDic;
@end

@implementation FillTypesViewController
+ (instancetype)storyboardVC{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserInfo" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"FillTypesViewController"];
}
- (void)viewDidLoad{
    [super viewDidLoad];
//    [self getUserinfo];
//    if ([FunctionTipsManager needToTip:kFunctionTipStr_ShenFenRenZheng]) {
//        [MartFunctionTipView showFunctionImages:@[@"function_shenfenrenzheng"]];
//        [FunctionTipsManager markTiped:kFunctionTipStr_ShenFenRenZheng];
//    }
//    [MartFunctionTipView showFunctionImages:@[@"guidance_dem_rewards_publish"] onlyOneTime:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_curUser) {
        self.curUser = [Login curLoginUser];
    }else{
        [self refresh];
    }
//    [self refreshIdCardCheck];
    //新功能提示
    if ([FunctionTipsManager needToTip:kFunctionTipStr_MaShiRenZheng]) {
        CGRect fromFrame = [[_identityTitleL superview] convertRect:_identityTitleL.frame toView:self.tableView];
        fromFrame.origin.y += 44/ 2;
        [MartFunctionTipView showText:@"全新自动化认证流程，快捷方便" direction:AMPopTipDirectionDown  bubbleOffset:20 inView:self.tableView fromFrame:fromFrame dismissHandler:^{
            [FunctionTipsManager markTiped:kFunctionTipStr_MaShiRenZheng];
        }];
    }
}

- (void)refresh{
    [[Coding_NetAPIManager sharedManager] get_CurrentUserBlock:^(id data, NSError *error) {
        if (data) {
            self.curUser = data;
        }
    }];
}

//-(void)refreshIdCardCheck{
//    WEAKSELF
//    [[Coding_NetAPIManager sharedManager]get_AppInfo:^(id data, NSError *error){
//        if (data){
//            NSDictionary *dataDic =data[@"data"];
//            NSInteger status=[dataDic[@"status"] integerValue];
//            weakSelf.identityCode=status;
//            weakSelf.identity_server_CacheDataDic=data[@"data"];
//            if (weakSelf.identityCode==identity_Authfaild){
//                weakSelf.statusCheckV.hidden=YES;
//                weakSelf.identityStatusLabel.hidden=NO;
//                weakSelf.identityStatusLabel.textColor=[UIColor colorWithHexString:@"FF4B80"];
//                weakSelf.identityStatusLabel.text=@"认证失败";
//            }else if(weakSelf.identityCode==identity_Authing){
//                weakSelf.statusCheckV.hidden=YES;
//                weakSelf.identityStatusLabel.hidden=NO;
//                weakSelf.identityStatusLabel.textColor=[UIColor colorWithHexString:@"F5A623"];
//                weakSelf.identityStatusLabel.text=@"认证中";
//            }else{
//                weakSelf.statusCheckV.hidden=NO;
//                weakSelf.identityStatusLabel.hidden=YES;
//            }
//        }
//    }];
//}

- (void)setCurUser:(User *)curUser{
    _curUser = curUser;
    [self.tableView reloadData];
    _userinfoCheckV.image = [UIImage imageNamed:_curUser.infoComplete.boolValue? @"fill_checked": @"fill_unchecked"];
    _skillsCheckV.image = [UIImage imageNamed:_curUser.skillComplete.boolValue? @"fill_checked": @"fill_unchecked"];
    _testingCheckV.image = [UIImage imageNamed:_curUser.surveyComplete.boolValue? @"fill_checked": @"fill_unchecked"];
    _statusCheckV.image = [UIImage imageNamed:_curUser.identityPassed.boolValue? @"fill_checked": @"fill_unchecked"];
    
    EAIdentityStatus identityStatus = _curUser.identityStatus.enum_identityStatus;
    if (identityStatus == EAIdentityStatus_REJECTED){
        self.statusCheckV.hidden=YES;
        self.identityStatusLabel.hidden=NO;
        self.identityStatusLabel.textColor=[UIColor colorWithHexString:@"FF4B80"];
        self.identityStatusLabel.text=@"认证失败";
    }else if(identityStatus == EAIdentityStatus_CHECKING){
        self.statusCheckV.hidden=YES;
        self.identityStatusLabel.hidden=NO;
        self.identityStatusLabel.textColor=[UIColor colorWithHexString:@"F5A623"];
        self.identityStatusLabel.text=@"认证中";
    }else{
        self.statusCheckV.hidden=NO;
        self.identityStatusLabel.hidden=YES;
    }
}

//-(void)getUserinfo{
//    [[Coding_NetAPIManager sharedManager] get_FillUserInfoBlock:^(id data, NSError *error){
//        FillUserInfo *userInfo = data[@"data"][@"info"]? [NSObject objectOfClass:@"FillUserInfo" fromJSON:data[@"data"][@"info"]]: [FillUserInfo new];
//        if (userInfo.name){
//            [IdentityAuthenticationModel cacheUserName:userInfo.name];
//        }
//    }];
//}

#pragma mark Table M
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    BOOL needTip =(_curUser.infoComplete.boolValue &&
                   !_curUser.skillComplete.boolValue &&
                   _curUser.surveyComplete.boolValue);
    return needTip? 80: 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    BOOL needTip =(_curUser.infoComplete.boolValue &&
                   !_curUser.skillComplete.boolValue &&
                   _curUser.surveyComplete.boolValue);
    return needTip? _header1TipV: _header1V;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0/[UIScreen mainScreen].scale;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3) {
        if (indexPath.row == 1) {
            if (!self.curUser.infoComplete.boolValue) {
                [NSObject showHudTipStr:@"请先完善个人信息"];
                return;
            }
            [self.navigationController pushViewController:[SkillsViewController storyboardVC] animated:YES];
        }else if (indexPath.row == 2){
            WEAKSELF
            [NSObject showHUDQueryStr:@"请稍等..."];
            [[Coding_NetAPIManager sharedManager] get_MartSurvey:^(id data, NSError *error) {
                [NSObject hideHUDQuery];
                if (data) {
                    MartSurveyViewController *vc = [MartSurveyViewController vcInStoryboard:@"UserInfo"];
                    vc.survey = data;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
    }else if (indexPath.row == 3){
        if (!self.curUser.infoComplete.boolValue) {
            [NSObject showHudTipStr:@"请先完善个人信息"];
            return;
        }
        WEAKSELF
        [NSObject showHUDQueryStr:@"请稍等..."];
        [[Coding_NetAPIManager sharedManager] get_IdentityInfoBlock:^(id data, NSError *error) {
            [NSObject hideHUDQuery];
            if (data) {
                [weakSelf goToIdetityStep:data];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
}

#pragma mark gotoVC
- (void)goToIdetityStep:(IdentityInfo *)info{
    EAIdentityStatus identityStatus = info.status.enum_identityStatus;
    Class classObj = (identityStatus == EAIdentityStatus_CHECKED? [IdentityPassedViewController class]:
//                      identityStatus == EAIdentityStatus_CHECKING? [IdentityStep2ViewController class]:
                      [IdentityStep1ViewController class]);
    UIViewController *vc = [classObj vcInStoryboard:@"UserInfo"];
    [vc setValue:info forKey:@"info"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
