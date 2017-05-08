//
//  ZFCollectionViewCell.m
//  Player
//
//  Created by 任子丰 on 17/3/22.
//  Copyright © 2017年 任子丰. All rights reserved.
//

#import "ZFCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "VideoModel.h"
#import "Masonry.h"
@implementation ZFCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.topicImageView = [[UIImageView alloc]init];
        self.topicImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.topicImageView];
        
        [self.topicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-30);
        }];
        
        
        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.font = [UIFont systemFontOfSize:13];
        self.timeLabel.textColor = [UIColor blueColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLabel];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(self.topicImageView.mas_bottom);
            make.right.equalTo(self.contentView).offset(-7);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(7);
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(self.topicImageView.mas_bottom);
            make.right.equalTo(self.timeLabel.mas_left).offset(-3);
        }];
        
        
        // 必须指定tag值，不然在ZFPlayerView里无法取到playerView加到哪里了
        self.topicImageView.tag = 200;
        // 代码添加playerBtn到imageView上
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        
        [self.playBtn setImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
        [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [self.topicImageView addSubview:self.playBtn];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topicImageView);
            make.width.height.mas_equalTo(50);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
    
   }

- (void)setModel:(VideoModel *)model {
    
    NSString *image = [[NSString alloc]initWithFormat:@"https:%@",model.img];
    [self.topicImageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];
    self.titleLabel.text = model.title;
    self.timeLabel.text = model.time;
}

- (void)play:(UIButton *)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}
@end
