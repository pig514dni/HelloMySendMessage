//
//  ViewController.m
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/17.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "ViewController.h"
#import "Communicator.h"
#import "AppDelegate.h"
#import "ChattingView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChatLogManager.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    Communicator *comm;
    NSMutableArray * incomingMessages;
    NSInteger lastMessageID;
    ChatLogManager *logManager;
    
    BOOL isRefreshing;
    BOOL shouldRefreshAgain;
}
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet ChattingView *ChattingView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    incomingMessages =[NSMutableArray new];
    logManager =[ChatLogManager new];
    comm=[Communicator sharedInstance];
    
    //Listen to the notification:DID_RECEIVED_REMOTE_NOTIFICATION
    //增加addObserver這個監聽者 直到APP關閉或者手動停止
    //這裡的object是可以限定監聽群組name裡的某個object物件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doRefresh) name:DID_RECEIVED_REMOTE_NOTIFICATION object:nil];
    
    // Load lastMessageID from NSUserDefaults
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    lastMessageID = [defaults integerForKey:LAST_MESSAGE_ID_KEY];
    if (lastMessageID==0) {
        lastMessageID=1;
    }
    //For text only
//    lastMessageID=1;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Show latest log
    NSInteger totalLogCount= [logManager getTotleCount];
    NSInteger startIndex = totalLogCount - 20;
    if (startIndex < 0 ) {
        startIndex=0;
    }
    
    for (NSInteger i=startIndex; i<totalLogCount; i++) {
        NSDictionary *tmpMessage = [logManager getMessageByIndex:i];
        [incomingMessages addObject:tmpMessage];
    }
    [self handleIncomingMessages:false];
    // Download when VC is launched.
    [self doRefresh];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendTextBtnPressed:(UIButton *)sender {
    if (_inputTextField.text.length == 0) {
        return;
    }
    
    //收起鍵盤
    [_inputTextField resignFirstResponder];
    [comm sendTextMessage:_inputTextField.text completion:^(NSError *error, id result) {
        if(error){
            NSLog(@"* Error occur: %@",error);
            //Show Error Message to User...
        }else{
            // Download and Refresh
            [self doRefresh];
        }
        
    }];
    
}
- (IBAction)sendPhotoBtnPressed:(UIButton *)sender {
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Choose Image Source " message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];

    UIAlertAction * cancel=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
   
}
-(void) launchImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourcetype{
    
    if ([UIImagePickerController isSourceTypeAvailable:sourcetype]==false) {
        NSLog(@"Invalid Type.");
        return;
    }
    UIImagePickerController *imagePicker=[UIImagePickerController new];
    //指定sourceType
    imagePicker.sourceType=sourcetype;
    //指定mediaTypes 在Array裡public.image表示只能使用照片相關功能
    //@[@"public.image",@"public.movie"]可以使用照片及影片相關功能
    imagePicker.mediaTypes=@[(NSString*)kUTTypeImage];//,(NSString*)kUTTypeMovie
    imagePicker.delegate=self;
    [self presentViewController:imagePicker animated:true completion:nil];
}
//此Delegate是使用者在APP選擇拍照完成按下Use Phot後會跑來這裡處理
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
       NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *originalImage =info[UIImagePickerControllerOriginalImage];
        
        UIImage *resizedImage = [self resizeWithImage:originalImage];
        
        NSData *imageData=UIImageJPEGRepresentation(originalImage, 0.7);
        
        NSLog(@"Image Size: %f x %f,File Size: %ld",resizedImage.size.width,resizedImage.size.height,(unsigned long)imageData.length);
        
        [comm sendPhotoMessageWithData:imageData completion:^(NSError *error, id result) {
            if (error) {
                // Show Error Message to User...
                NSLog(@"* Error occur: %@",error);
            }else{
                // Download and Refresh
                [self doRefresh];
           }
        }];
    }
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

-(UIImage*)resizeWithImage:(UIImage*) srcImage{
    
    CGFloat maxLength = 1024.0;
    CGSize targetSize;
    //No need to resiz. Use original image.
    if (srcImage.size.width <= maxLength &&srcImage.size.height <= maxLength ) {
        
        targetSize=srcImage.size;
        
    }else{
        //Adjust the size
        if (srcImage.size.width >= srcImage.size.height) {
            
            CGFloat ratio = srcImage.size.width / maxLength;
            targetSize = CGSizeMake(maxLength, srcImage.size.height / ratio);
        }else{
            CGFloat ratio = srcImage.size.height / maxLength;
            targetSize = CGSizeMake(srcImage.size.width/ratio, maxLength);
        }
    }
    
    
    
    
    
    
    // Resize the srcimage as targetSize
    //C語言底層API
    //BeginImageContext 在記憶體建立一塊虛擬畫布
    UIGraphicsBeginImageContext(targetSize);
    
    //虛擬畫布上的(0,0)開始用srcImage照片畫寬為targetSize.width,長為targetSize.height照片
    //drawInRect為縮放的方法
    [srcImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    //Draw Frame
    UIImage *frameImage = [UIImage imageNamed:@"frame_01.png"];
    [frameImage drawInRect:CGRectMake(0,0,targetSize.width, targetSize.height)];
    
    //把畫好的虛擬畫布指定給resultImage
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //重要! 使用完ImageContext須關閉,不然會留在記憶體內佔用
    UIGraphicsEndImageContext();
    
    return resultImage;
    
}

-(void) doRefresh{
    
    if (isRefreshing == false) {
        isRefreshing=true;
    }else{
        shouldRefreshAgain =true;
        return;
    }
    
    
    
    [comm retriveMessagesWithLastMessageID:lastMessageID completion:^(NSError *error, id result) {
        if(error){
            NSLog(@"* Error occur: %@",error);
            // Show Error Message to User....
            //假如失敗把isRefreshing設成false
            isRefreshing=false;
        }else {
            
            //Handle incoming messages.
            NSArray *messages = result[MESSAGES_KEY];
            
            if (messages.count == 0 ) {
                NSLog(@"No new message,then do nothing.");
                isRefreshing = false;
                return ;
            }
            
            // Keep lastMessageID
            NSDictionary *lastMessage = messages.lastObject;
            lastMessageID = [lastMessage[ID_KEY] integerValue];
            
            //Save lastMessageID to NSUserDefault
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:lastMessageID forKey:LAST_MESSAGE_ID_KEY];
            [defaults synchronize];
            
            [incomingMessages addObjectsFromArray:messages];
            
            [self handleIncomingMessages:true];
            
        }
    }];
}

-(void) handleIncomingMessages:(BOOL)shouldSaveToLog
{
    if (incomingMessages.count == 0) {
        isRefreshing = false;
        
        if (shouldRefreshAgain) {
            shouldRefreshAgain=false;
            [self doRefresh];
        }
        
        return;
    }
    
    NSDictionary *tmpMessage = incomingMessages.firstObject;
    [incomingMessages removeObjectAtIndex:0];
    
    // Add to logManager
    if (shouldSaveToLog) {
        [logManager addChatLog:tmpMessage];
    }
    
    
    NSInteger messageID = [tmpMessage[ID_KEY] integerValue];
    NSInteger messageType = [tmpMessage[TYPE_KEY] integerValue];
    NSString *senderName = tmpMessage[USER_NAME_KEY];
    NSString *message = tmpMessage[MESSAGE_KEY];
    if (messageType == 0) {
        // Text
        NSString *displayMessage = [NSString stringWithFormat:@"%@: %@ (%ld)",senderName,message,(long)messageID];
        
        //Decide it is fromOthers ot fromMe
        ChattingItem *item=[ChattingItem new];
        item.text=displayMessage;
        if ([senderName isEqualToString:MY_NAME]) {
            item.type=fromMe;
        }else {
            item.type=fromOthers;
        }
        [_ChattingView addChattingItem:item];
        // Move to next message
        [self handleIncomingMessages:shouldSaveToLog];
    }else{
        // Image
        
        UIImage *image = [ChatLogManager loadPhotoWithFileName:message];
        
        if (image != nil) {
            //Photo is cached,use it directly.
            //假如圖片已在cached暫存區就不用重新下載
             NSString *displayMessage = [NSString stringWithFormat:@"%@: %@ (%ld)",senderName,message,(long)messageID];
            
            [self addChatItemWithMessage:displayMessage
                                   image:image
                                  sender:senderName];
            
            [self handleIncomingMessages:shouldSaveToLog];
        }else{
            // Need to load from server
            //假如圖片在cached暫存區找不到該圖片就不用重新下載
            [comm downloadPhotoWithFileName:message completion:^(NSError *error, id result) {
                
                if (error) {
                    NSLog(@"* Error occur: %@",error);
                    // Show Error Message to User....
                }else{
                    
                    NSString *displayMessage = [NSString stringWithFormat:@"%@: %@ (%ld)",senderName,message,(long)messageID];
                    
                    [self addChatItemWithMessage:displayMessage
                                           image:[UIImage imageWithData:result]
                                          sender:senderName];
                    
                    // Save Image as a cached file
                    [ChatLogManager savePhotoWithFileName:message data:result];
                }
                //Move to next message
                //須等待圖片下載完成後在做下一部份
                [self handleIncomingMessages:shouldSaveToLog];
            }];
        }
    }
}

- (void) addChatItemWithMessage:(NSString*) message image:(UIImage*)
        image sender:(NSString*) senderName{
    
    //Decide it is fromOthers ot fromMe
    ChattingItem *item=[ChattingItem new];
    item.text=message;
    
    if ([senderName isEqualToString:MY_NAME]) {
        item.type=fromMe;
    }else {
        item.type=fromOthers;
    }
    
    item.image = image;
    [_ChattingView addChattingItem:item];
    
}

@end
