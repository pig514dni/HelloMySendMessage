//
//  ChattingView.m
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "ChattingView.h"
#import "ChattingBubbleView.h"
#define Y_PADDING 20
@interface ChattingView()
{
    CGFloat lastChattingBubbleViewY;
    NSMutableArray *allChattingItems;
}
@end
@implementation ChattingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void) addChattingItem:(ChattingItem*) item{
    
    if (!allChattingItems) {
        allChattingItems=[NSMutableArray new];
    }
    //item聊天送出的資料
    ChattingBubbleView * bubbleView=[[ChattingBubbleView alloc] initWithItem:item offsetY:lastChattingBubbleViewY+Y_PADDING ];
    [self addSubview:bubbleView];
    
    //取得加入聊天室最後的bubbleView Y值
    lastChattingBubbleViewY=CGRectGetMaxY(bubbleView.frame);
    //讓scrollView知道最底部在哪裡
    self.contentSize = CGSizeMake(self.frame.size.width, lastChattingBubbleViewY);
    
    //scroll to bottom
    //產生一個長1寬1位置在X:0 Y:lastChattingBubbleViewY-1的物件
    //並讓畫面自動捲到能全部秀出產生的物件就停止捲動
    [self scrollRectToVisible:CGRectMake(0,lastChattingBubbleViewY-1, 1, 1) animated:true];
    
    //Keep the item
    //把資料備份到allChattingItems
    [allChattingItems addObject:item];
}
@end
