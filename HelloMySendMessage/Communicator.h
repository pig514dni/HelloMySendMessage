//
//  Communicator.h
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/17.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ID_KEY    @"id"
#define USER_NAME_KEY    @"UserName"
#define MESSAGE_KEY    @"Message"
#define DEVICETOKEN_KEY    @"DeviceToken"
#define GROUP_NAME_KEY    @"GroupName"
#define LAST_MESSAGE_ID_KEY    @"LastMessageID"
#define TYPE_KEY    @"Type"
#define DATA_KEY    @"data"
#define MESSAGES_KEY @"Messages"

#define GROUP_NAME  @"AP102"

#define MY_NAME @"ChunLun"

typedef void (^DoneHandler)(NSError *error,id result);

@interface Communicator : NSObject

+(instancetype)sharedInstance;

- (void) updateDeviceToken:(NSString*) deviceToken
                completion:(DoneHandler)doneHandler;

- (void) sendTextMessage:(NSString*) message
                completion:(DoneHandler)doneHandler;

-(void) retriveMessagesWithLastMessageID:(NSInteger) lastMessageID completion:(DoneHandler) doneHandler;

-(void) downloadPhotoWithFileName:(NSString*)filename completion:(DoneHandler) doneHandler;

-(void) sendPhotoMessageWithData:(NSData *)data completion:(DoneHandler)doneHandler;
@end
