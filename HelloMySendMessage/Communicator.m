//
//  Communicator.m
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/17.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "Communicator.h"
#import <AFNetworking.h>
#define BASE_URL @"http://class.softarts.cc/PushMessage"

#define SENDMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendMessage.php"]

#define SENDPHOTOMESSAGE_URL [BASE_URL stringByAppendingPathComponent:@"sendPhotoMessage.php"]

#define RETRIVEMESSAGES_URL [BASE_URL stringByAppendingPathComponent:@"retriveMessages2.php"]

#define UPDATEDEVICETOKEN_URL [BASE_URL stringByAppendingPathComponent:@"updateDeviceToken.php"]

#define PHOTOS_BASE_URL [BASE_URL stringByAppendingPathComponent:@"photos/"]

@implementation Communicator

//整個APP都用_singletonCommunicator與Server溝通
static Communicator *_singletonCommunicator=nil;

+(instancetype)sharedInstance{
    if (_singletonCommunicator==nil) {
        _singletonCommunicator=[Communicator new];
    }
    return _singletonCommunicator;
}

- (void) sendTextMessage:(NSString*) message
              completion:(DoneHandler)doneHandler{
    NSDictionary * jsonObj=@{USER_NAME_KEY:MY_NAME,
                             MESSAGE_KEY:message,GROUP_NAME_KEY:GROUP_NAME};
    
    [self doPost:SENDMESSAGE_URL parameters:jsonObj completion:doneHandler];
}

- (void) updateDeviceToken:(NSString*) deviceToken
                completion:(DoneHandler)doneHandler{
    
    NSDictionary * jsonObj=@{USER_NAME_KEY:MY_NAME,
        DEVICETOKEN_KEY:deviceToken,GROUP_NAME_KEY:GROUP_NAME};
    
    [self doPost:UPDATEDEVICETOKEN_URL parameters:jsonObj completion:doneHandler];
}

-(void) retriveMessagesWithLastMessageID:(NSInteger) lastMessageID completion:(DoneHandler) doneHandler{
    //@(lastMessageID)==>Convert to NSNumber
    //@(lastMessageID)=[NSNumber numberWithInt:lastmessageID];
    NSDictionary * jsonObj=@{LAST_MESSAGE_ID_KEY:@(lastMessageID),
                             GROUP_NAME_KEY:GROUP_NAME};
    
    [self doPost:RETRIVEMESSAGES_URL parameters:jsonObj completion:doneHandler];
    
}

-(void) downloadPhotoWithFileName:(NSString*)filename completion:(DoneHandler) doneHandler{
    
    //下載工作透過SessionManager運行
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //responseSerializer 處理SERVERresponse
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    //根據網路協定一定要指定下載的Type
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"image/jpeg"];
    //stringByAppendingPathComponent 自動判斷URL會加/
    NSString *finalPhotoURLString=[PHOTOS_BASE_URL stringByAppendingPathComponent:filename];
    [manager GET:finalPhotoURLString parameters:nil
     //掌握下載進度
    progress:nil
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     //下載成功的地方
        NSLog(@"Download OK: %u bytes",[responseObject length]);
        doneHandler(nil,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //下載失敗的地方
        NSLog(@"Download Fail: %@",error);
        doneHandler(error,nil);
    }];
    
}
-(void) sendPhotoMessageWithData:(NSData*)data completion:(DoneHandler) donehandler{
    
    NSDictionary * jsonObj=@{USER_NAME_KEY:MY_NAME,
                             GROUP_NAME_KEY:GROUP_NAME};
    [self doPost:SENDPHOTOMESSAGE_URL parameters:jsonObj data:data completion:donehandler];
    
}
#pragma mark - Shared Methods

- (void) doPost:(NSString*) urlString parameters:(NSDictionary*)
         parameters data:(NSData*)data completion:(DoneHandler) doneHandler{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //Change parameters to format:"data=..."
    //NSJSONWritingPrettyPrinted 產生讓人好閱讀的json碼,缺點容量比較大
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //讓json前面加上data會比較安全
    NSDictionary *finalParameters=@{DATA_KEY:jsonString};
    
    
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    
    //使用AFNetWorking  POST上傳檔案
    [manager POST:urlString parameters:finalParameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:data
                                    //name:fileToUpload 是因為server端的PHP寫成只認得這名字能上傳
                                    name:@"fileToUpload"
                                fileName:@"image.jpg"
                                mimeType:@"image/jpg"];
        
    } progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          NSLog(@"do UpLoad Photo OK Result:%@",responseObject);
          doneHandler(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"doPOST Error:%@",error);
        doneHandler(error,nil);

        
    }];


}




- (void) doPost:(NSString*) urlString parameters:(NSDictionary*)
    parameters completion:(DoneHandler) doneHandler{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //Change parameters to format:"data=..."
    //NSJSONWritingPrettyPrinted 產生讓人好閱讀的json碼,缺點容量比較大
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //讓json前面加上data會比較安全
    NSDictionary *finalParameters=@{DATA_KEY:jsonString};
    
    
    manager.responseSerializer.acceptableContentTypes=[NSSet
                    setWithObject:@"text/html"];
    [manager POST:urlString
     parameters:finalParameters progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
           NSLog(@"doPOST OK Result:%@",responseObject);
           doneHandler(nil,responseObject);
           
     }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
           NSLog(@"doPOST Error:%@",error);
           doneHandler(error,nil);
     }
    ];
}

@end
