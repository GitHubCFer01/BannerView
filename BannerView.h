//
//  BannerView.h
//  轮播图BannerDemo
//
//  Created by User on 2018/3/9.
//  Copyright © 2018年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BannerView;

@protocol BannerViewDelegate <NSObject>

@optional //可选
- (void)selectImage:(BannerView *)bannerView currentImage:(NSInteger )currentImage;

@end

@interface BannerView : UIView

@property (nonatomic , weak) id <BannerViewDelegate> delegate;

//自定义init方法
- (id)initWithFrame:(CGRect)frame addImageArray:(NSMutableArray *)addImageArray;

@end
