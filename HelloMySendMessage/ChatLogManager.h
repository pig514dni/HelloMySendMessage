//
//  ChatLogManager.h
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/24.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ChatLogManager : NSObject
+ (void) savePhotoWithFileName:(NSString*) originalFileName data:(NSData*)data;

+ (UIImage*) loadPhotoWithFileName:(NSString*) originalFileName;

-(void)addChatLog:(NSDictionary*)messageDictionary;

-(NSInteger) getTotleCount;
-(NSDictionary*) getMessageByIndex:(NSInteger)index;

@end
