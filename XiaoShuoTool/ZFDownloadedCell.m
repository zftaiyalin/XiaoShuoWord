//
//  ZFDownloadedCell.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFDownloadedCell.h"
#import "Masonry.h"

@implementation ZFDownloadedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        self.fileImage = [[UIImageView alloc]init];
        self.fileImage.image = [UIImage imageNamed:@"file"];
        [self.contentView addSubview:self.fileImage];
        
        [self.fileImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(35);
            make.left.equalTo(self.contentView).offset(13);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.sizeLabel = [[UILabel alloc]init];
        self.sizeLabel.font = [UIFont systemFontOfSize:15];
        self.sizeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.sizeLabel];
        
        [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-5);
            make.right.equalTo(self.contentView.mas_right).offset(-7);
            make.height.equalTo(@20);
        }];

        
        self.fileNameLabel = [[UILabel alloc]init];
        self.fileNameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.fileNameLabel];
        
        [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.fileImage.mas_right).offset(7);
            make.height.equalTo(@20);
            make.right.equalTo(self.contentView).offset(-5);
        }];

        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFileInfo:(ZFFileModel *)fileInfo {
    _fileInfo = fileInfo;
    NSString *totalSize = [ZFCommonHelper getFileSizeString:fileInfo.fileSize];
    self.fileNameLabel.text = fileInfo.fileName;
    self.sizeLabel.text = totalSize;
}

@end
