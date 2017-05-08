//
//  ZFCollectionViewCell.h
//  Player
//
//  Created by 任子丰 on 17/3/22.
//  Copyright © 2017年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "VideoModel.h"

@interface ZFCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UIImageView *topicImageView;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (nonatomic, strong) UIButton *playBtn;
/** model */
@property (nonatomic, strong) VideoModel *model;
/** 播放按钮block */
@property (nonatomic, copy  ) void(^playBlock)(UIButton *);

@end
