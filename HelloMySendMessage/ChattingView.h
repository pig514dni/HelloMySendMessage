//
//  ChattingView.h
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChattingItem.h"
@interface ChattingView : UIScrollView

-(void) addChattingItem:(ChattingItem*) item;

@end
