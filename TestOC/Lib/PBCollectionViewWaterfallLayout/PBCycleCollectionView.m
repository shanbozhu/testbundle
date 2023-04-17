//
//  PBCycleCollectionView.m
//  TestOC
//
//  Created by shanbo on 2022/4/21.
//  Copyright © 2022 DaMaiIOS. All rights reserved.
//

#import "PBCycleCollectionView.h"
#import "PBCycleCell.h"
#import "PBCycleTimerProxy.h"

// 轮播时间间隔
static CGFloat scrollInterval = 3.0f;

@interface PBCycleCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PBCycleTimerProxyDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) PBScrollDirection scrollDirection; // 滚动方向

@end

@implementation PBCycleCollectionView

//+ (id)testListView {
//    return [[self alloc] initWithFrame:CGRectZero];
//}

- (id)initWithFrame:(CGRect)frame scrollDirection:(PBScrollDirection)scrollDirection {
    if (self = [super initWithFrame:frame]) {
        self.scrollDirection = scrollDirection;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        if (self.scrollDirection == PBScrollDirectionHorizontal) {
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.collectionView = collectionView;
        [self addSubview:collectionView];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        collectionView.pagingEnabled = true;
        collectionView.showsHorizontalScrollIndicator = false;
        collectionView.showsVerticalScrollIndicator = false;
        
        collectionView.layer.borderColor = [UIColor blueColor].CGColor;
        collectionView.layer.borderWidth = 1.1;
        
        //
        CGFloat controlHeight = 35.0f;
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - controlHeight, self.bounds.size.width, controlHeight)];
        self.pageControl = pageControl;
        [self addSubview:self.pageControl];
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        
        pageControl.layer.borderColor = [UIColor grayColor].CGColor;
        pageControl.layer.borderWidth = 1.1;
        
        //
        self.autoPage = NO;
    }
    return self;
}

- (void)startTimer {
    [self stopTimer];
    
    //
    PBCycleTimerProxy *cycleTimerProxy = [[PBCycleTimerProxy alloc] init];
    cycleTimerProxy.delegate = self;
    SEL showNext = NSSelectorFromString(@"showNext");
    NSTimer *timer = [NSTimer timerWithTimeInterval:scrollInterval target:cycleTimerProxy selector:showNext userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)setAutoPage:(BOOL)autoPage {
    _autoPage = autoPage;
    autoPage ? [self startTimer] : [self stopTimer];
}

- (void)setTestList:(PBCellHeightZero *)testList {
    _testList = testList;
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:testList.data];
    [tmpArr addObject:testList.data.firstObject];
    [tmpArr insertObject:testList.data.lastObject atIndex:0];
    testList.data = tmpArr;
    
    self.pageControl.numberOfPages = testList.data.count - 2;
    if (self.scrollDirection == PBScrollDirectionHorizontal) {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
    } else {
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.bounds.size.height)];
    }
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.testList.data.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCycleCell *cell = [PBCycleCell testListCellWithCollectionView:collectionView indexPath:indexPath];
    cell.index = indexPath.item;
    cell.testListData = self.testList.data[indexPath.item];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

// 手动拖拽结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self cycleScroll];
    
    // 手动拖拽结束,间隔3s继续轮播
    if (self.autoPage) {
        [self startTimer];
    }
}

- (void)cycleScroll {
    if (self.scrollDirection == PBScrollDirectionHorizontal) {
        NSInteger page = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
        if (page == 0) {
            // 滚动到左边
            self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width * (self.testList.data.count - 2), 0);
            self.pageControl.currentPage = self.testList.data.count - 2;
        } else if (page == self.testList.data.count - 1) {
            // 滚动到右边
            self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width, 0);
            self.pageControl.currentPage = 0;
        } else {
            self.pageControl.currentPage = page - 1;
        }
    } else {
        NSInteger page = self.collectionView.contentOffset.y / self.collectionView.bounds.size.height;
        if (page == 0) {
            // 滚动到左边
            self.collectionView.contentOffset = CGPointMake(0, self.collectionView.bounds.size.height * (self.testList.data.count - 2));
            self.pageControl.currentPage = self.testList.data.count - 2;
        } else if (page == self.testList.data.count - 1) {
            // 滚动到右边
            self.collectionView.contentOffset = CGPointMake(0, self.collectionView.bounds.size.height);
            self.pageControl.currentPage = 0;
        } else {
            self.pageControl.currentPage = page - 1;
        }
    }
}

- (void)cycleTimerProxy:(PBCycleTimerProxy *)timerProxy {
    // 手指拖拽时如果计时器没有停止,禁止自动轮播
    if (self.collectionView.isDragging) {
        return;
    }
    if (self.scrollDirection == PBScrollDirectionHorizontal) {
        CGFloat targetX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
        [self.collectionView setContentOffset:CGPointMake(targetX, 0) animated:true];
    } else {
        CGFloat targetY = self.collectionView.contentOffset.y + self.collectionView.bounds.size.height;
        [self.collectionView setContentOffset:CGPointMake(0, targetY) animated:true];
    }
}

// 自动轮播结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self cycleScroll];
}

- (void)dealloc {
    [self stopTimer];
    NSLog(@"PBCycleCollectionView对象被释放了");
}

@end
