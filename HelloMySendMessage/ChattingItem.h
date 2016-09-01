//
//  ChattingItem.h
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKIT/UIKIT.h>

typedef  enum:NSUInteger{
    fromMe,
    fromOthers
} ChattingItemType;

@interface ChattingItem : NSObject

@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) ChattingItemType type;
@end
