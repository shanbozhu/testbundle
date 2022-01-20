//
//  PBLinkageTopController.m
//  TestOC
//
//  Created by shanbo on 2022/1/19.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBLinkageTopController.h"
#import "PBLinkageTopOneListController.h"
#import "PBLinkageTopTwoListController.h"

@interface PBLinkageTopController () <YNPageViewControllerDataSource, YNPageViewControllerDelegate>

@end

@implementation PBLinkageTopController

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (instancetype)linkageTopController {
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionTop;
    configration.headerViewCouldScale = YES;
    configration.showTabbar = NO;
    configration.showNavigation = NO;
    configration.scrollMenu = NO;
    configration.aligmentModeCenter = NO;
    configration.lineWidthEqualFontWidth = NO;
    configration.showBottomLine = YES;
    
    PBLinkageTopController *vc = [PBLinkageTopController pageViewControllerWithControllers:[self getArrayVCs]
                                                                                    titles:[self getArrayTitles]
                                                                                    config:configration];
    vc.dataSource = vc;
    vc.delegate = vc;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPLICATION_FRAME_WIDTH, 210)];
    vc.headerView = headerView;
    
    vc.bgScrollView.layer.borderColor = [UIColor redColor].CGColor;
    vc.bgScrollView.layer.borderWidth = 1;
    
    return vc;
}

+ (NSArray *)getArrayVCs {
    PBLinkageTopOneListController *firstVC = [[PBLinkageTopOneListController alloc] init];
    PBLinkageTopTwoListController *secondVC = [[PBLinkageTopTwoListController alloc] init];
    return @[firstVC, secondVC];
}

+ (NSArray *)getArrayTitles {
    return @[@"鞋子", @"衣服"];
}

- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index {
    UIViewController *vc = pageViewController.controllersM[index];
    if (index == 0) {
        return [(PBLinkageTopOneListController *)vc tableView];
    } else {
        return [(PBLinkageTopTwoListController *)vc tableView];
    }
}

@end
