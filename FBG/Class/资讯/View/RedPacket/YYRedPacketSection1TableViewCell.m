//
//  YYRedPacketSection1TableViewCell.m
//  FBG
//
//  Created by yy on 2018/4/17.
//  Copyright © 2018年 ButtonRoot. All rights reserved.
//

#import "YYRedPacketSection1TableViewCell.h"
#import "YYRedPacketReceiveProgressView.h"
#import "YYRedPacketMySentListModel.h"

@interface YYRedPacketSection1TableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *redPacketNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet YYRedPacketReceiveProgressView *progessView;
@property (weak, nonatomic) IBOutlet UILabel *ingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ingHeightConstraint;

@end

@implementation YYRedPacketSection1TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setModel:(YYRedPacketMySentListModel *)model {
    if ([model isEqual:_model]) {
        return;
    }
    
    _model = model;
    
    self.redPacketNoLabel.text = model.redbag_addr;
    
    NSString *number = [NSString notRounding:model.redbag afterPoint:8];
    self.priceLabel.text = [NSString stringWithFormat:@"%.8lfETH", number.doubleValue];
    
    switch (model.status) {
        case RedBagStatusDone: {
            [self showProgressView:NO];
            self.statusLabel.text = DBHGetStringWithKeyFromTable(@"Done", nil);
            break;
        }
        case RedBagStatusCashPackaging: {
            [self showProgressView:NO];
            self.statusLabel.text = DBHGetStringWithKeyFromTable(@"Cash Packaging", nil);
            break;
        }
        case RedBagStatusCreating: {
            [self showProgressView:NO];
            self.statusLabel.text = DBHGetStringWithKeyFromTable(@"Red Packet Creating", nil);
            break;
        }
            
        case RedBagStatusOpening: {
            [self showProgressView:YES];
            self.ingLabel.text = DBHGetStringWithKeyFromTable(@"Openning", nil);
            [self.progessView setProgress:model.draw_redbag_number total:model.redbag_number];
            break;
        }
    }
}

- (void)showProgressView:(BOOL)isShow {
    self.progessView.hidden = NO;
    self.ingLabel.hidden = NO;
    
    self.statusLabel.hidden = YES;
}

- (void)setModel:(id)model showIng:(BOOL)showIng {
    _ingHeightConstraint.constant = showIng ? 15 : 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
