//
//  BannerView.m
//  轮播图BannerDemo
//
//  Created by User on 2018/3/9.
//  Copyright © 2018年 User. All rights reserved.
//

#import "BannerView.h"

@interface BannerView ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic , assign) CGFloat width;

@property (nonatomic , assign) CGFloat height;

@property (nonatomic , strong) NSMutableArray *dataArray;

@property (nonatomic , strong) UIPageControl *pageControl;

@property (nonatomic , strong) NSTimer *timer;

@end

@implementation BannerView

//自定义init方法/构造方法
- (id)initWithFrame:(CGRect)frame addImageArray:(NSMutableArray *)addImageArray
{
    if (self = [super initWithFrame:frame])
    {
        //获取self宽度
        _width = self.frame.size.width;
        
        //获取self高度
        _height = self.frame.size.height;
        
        //改变图片数组 1 2 3 4 5 6
        _dataArray = [NSMutableArray arrayWithArray:addImageArray];
        
        //在数组的最后一位添加上第一张图片 1 2 3 4 5 6 1
        [_dataArray addObject:addImageArray[0]];
        
        //在第一个位置插入图片6 | 6 1 2 3 4 5 6 1
        [_dataArray insertObject:[addImageArray lastObject] atIndex:0];
        
        //将scrollView添加到self上
        [self addSubview:self.scrollView];
        
        //添加page
        [self addSubview:self.pageControl];
        
        //添加定时器
        [self addTimer];
    }
    
    return self;
}

//添加定时器
- (void)addTimer
{
    _timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(change) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

//定时器方法
- (void)change
{
    //获取起始位置
    CGFloat startX = _scrollView.contentOffset.x;
    
    //获取终点
    CGFloat endX = startX + _width;
    
    if (endX == (_dataArray.count - 1) * _width)
    {
        //动画时长  animateWithDuration
        [UIView animateWithDuration:0.25 animations:
        ^{
            //往最后一位走
            _scrollView.contentOffset = CGPointMake(endX, 0);
        }
        completion:^(BOOL finished)
        {
            //走向第二位
            _scrollView.contentOffset = CGPointMake(_width, 0);
            
            //走到对应的点
            NSInteger tmpPage = _scrollView.contentOffset.x / _width;
            
            _pageControl.currentPage = tmpPage - 1;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:
        ^{
            _scrollView.contentOffset = CGPointMake(endX, 0);
        }];
        
        //走到对应的点
        NSInteger tmpPage = _scrollView.contentOffset.x / _width;
        
        _pageControl.currentPage = tmpPage - 1;
    }
    
    
}

//初始化scrollView
- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        //滚动范围
        _scrollView.contentSize = CGSizeMake(_width * _dataArray.count, _height);
        
        //起始页
        _scrollView.contentOffset = CGPointMake(_width, 0);
        
        //添加分页效果
        _scrollView.pagingEnabled = YES;
        
        //禁止弹簧效果
        _scrollView.bounces = NO;
        
        _scrollView.delegate = self;
        
        //禁止水平滚动
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        for (int i = 0; i < _dataArray.count; i++)
        {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_width * i, 0, _width, _height)];
            
            imageView.image = [UIImage imageNamed:_dataArray[i]];
            
            //添加手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            
            //将手势添加到图片上
            [imageView addGestureRecognizer:tap];
            
            //与用户交互
            imageView.userInteractionEnabled = YES;
            
            [_scrollView addSubview:imageView];
        }
    }
    
    return _scrollView;
}

//手势方法
- (void)tapAction:(UITapGestureRecognizer *)recognizer
{
    //如果代理响应该方法 , 就走该方法
    if ([self.delegate respondsToSelector:@selector(selectImage:currentImage:)])
    {
        [self.delegate selectImage:self currentImage:self.pageControl.currentPage];
    }
}
 
//初始化pageControl
- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl  alloc]initWithFrame:CGRectMake(20, _height - 30, _width - 20 * 2, 30)];
        
        //小圆点的数量
        _pageControl.numberOfPages = _dataArray.count - 2;
        
        _pageControl.currentPageIndicatorTintColor  = [UIColor redColor];
        
        //不让用户交互
        _pageControl.userInteractionEnabled = NO;
    }
    
    return _pageControl;
}

//代理方法  将要拖拽的时候把timer停止
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_timer)
    {
        //timer停止在未来的一个时间
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

//代理方法  已经结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //恢复时间timer
    if (_timer)
    {
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    }
    
    //获取滑动结束的偏移量
    CGPoint currentOffSet = scrollView.contentOffset;
    
    //如果是在最后一页的话 , 让scrollView滚到第一页
    if (currentOffSet.x == (_dataArray.count - 1)* _width)
    {
        _scrollView.contentOffset = CGPointMake(_width, 0);
    }
    
    //如果是第一页的时候 , 偏移量为0
    if (currentOffSet.x == 0)
    {
        _scrollView.contentOffset = CGPointMake((_dataArray.count - 2) * _width, 0);
    }
    
    //获取最新偏移量
    CGPoint newOffSet = _scrollView.contentOffset;
    
    //获取偏移了多少个宽度
    NSInteger tmpPage = newOffSet.x / _width;
    
    //设置当前pageControl的当前点
    _pageControl.currentPage = tmpPage - 1;
    
}

@end
