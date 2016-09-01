//
//  ChatLogManager.m
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/24.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "ChatLogManager.h"
#import <FMDatabase.h>
#import "Communicator.h"
#define MID_FIELD @"mid"
@interface  ChatLogManager ()
{
    NSString *dbFileNamePath;
    FMDatabase *db;
    NSMutableArray *midsArray;
}

@end

@implementation ChatLogManager

#pragma Photo Cache Support
+ (void) savePhotoWithFileName:(NSString*) originalFileName data:(NSData*)data
{
    
    NSURL * fullFilePathURL = [ChatLogManager getFullURLWithFileName:originalFileName];
    
    // Save File
    //atomically:把這檔案暫時存到別暫存區,等百分百確定儲存沒問題會把暫存區的檔名改成正確檔名
    [data writeToURL:fullFilePathURL atomically:true];
}

+ (UIImage*) loadPhotoWithFileName:(NSString*) originalFileName
{
    NSURL * fullFilePathURL = [ChatLogManager getFullURLWithFileName:originalFileName];
    
    // Save File
    NSData *data = [NSData dataWithContentsOfURL:fullFilePathURL];
    
    return [UIImage imageWithData:data];
}

+(NSURL*) getFullURLWithFileName:(NSString*)originalFileName{
    
    // Find Cache Dircetory
    NSArray *cachesURLs = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    
    NSURL *targetCacheURL = cachesURLs.firstObject;
    
    // Decide File Name
    //存進硬碟的檔名為下載下來照片的名字用hash砸臭函數去命名
    NSString *filename = [NSString stringWithFormat:@"%lu,jpg",
                          (unsigned long)originalFileName.hash];
    
    NSURL *fullFilePathURL = [targetCacheURL URLByAppendingPathComponent:filename];
    
    return fullFilePathURL;
}
#pragma -Chat Log Support

-(instancetype) init{
    self=[super init];
    
    midsArray = [NSMutableArray new];
    
    //Prepare dbFileNamePath
    //抓取沙盒裡的NSDocumentDirectory目錄
    NSArray *results=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    
    NSString *documentsPath=results.firstObject;
    //將documentsPath抓到的目錄附加chatlog.sqlite檔名,這樣sqlite會命名為chatlog
    dbFileNamePath=[documentsPath stringByAppendingPathComponent:@"chatlog.sqlite"];
    
    //Prepare or Create db
    //[FMDatabase databaseWithPath:dbFileNamePath]open DB,當DB不存在 創立他
    db= [FMDatabase databaseWithPath:dbFileNamePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbFileNamePath]==false) {
        //Create db
        if ([db open]) {
            
            //設立欄位mid 型態是integer 主鍵 自動增加
            NSString *sqlCmd = @"CREATE TABLE IF NOT EXISTS chatlog_table(mid integer primary key autoincrement,id integer,UserName text,Message text,Type integer);";
            //FMDB寫入資料庫須使用[db executeUpdate:欲使用sql語法]
            BOOL success = [db executeUpdate:sqlCmd];
            NSLog(@"Create DB Table: %@",(success?@"OK":@"NG"));
            [db close];
        }
        
        
    }else{
        //Prepare and load the id index first
        
        if ([db open]) {
            FMResultSet *result=[db executeQuery:@"SELECT * from chatlog_table;"];
            
            //假設result撈到10筆,第一個while從第0筆開始,跑完第一次,[result next]如還有值會回傳true
            //並持續寫到midsArray,直到沒有值為止
            while ([result next]) {
                NSInteger mid = [result intForColumn:MID_FIELD];
                
                [midsArray addObject:@(mid)];
            }
            [db close];
        }
    }
    return self;
}

-(void)addChatLog:(NSDictionary*)messageDictionary{
    if ([db open]) {
        //先行創建插入語法,但還沒給值
        NSString *sqlCmd = [NSString stringWithFormat:@"INSERT INTO chatlog_table(%@,%@,%@,%@) VALUES(?,?,?,?)",ID_KEY,USER_NAME_KEY,MESSAGE_KEY,TYPE_KEY];
        
        //存入DB,並代剛剛沒給的值
        BOOL success = [db executeUpdate:sqlCmd
                        ,messageDictionary[ID_KEY]
                        ,messageDictionary[USER_NAME_KEY ]
                        ,messageDictionary[MESSAGE_KEY]
                        ,messageDictionary[TYPE_KEY]];
        
        [db close];
        
        if (success) {
            NSInteger lastMID = [self getLastItemMID];
            [midsArray addObject:@(lastMID)];
            
        }else{
            NSLog(@"addChatLog fail.");
        }
        
        
    }
}

- (NSInteger)getLastItemMID{
    
    NSInteger resultMID;
    
    if ([db open]) {
        //chatlog_table用ORDER BY排序mid ,排序方式為DESC,並只取1筆資料
        FMResultSet *result = [db executeQuery:@"SELECT * FROM chatlog_table ORDER BY mid DESC LIMIT 1;"];
        
        while ([result next]) {
            resultMID = [result intForColumn:MID_FIELD];
        }
        [db close];
    }
    return resultMID;
}

-(NSInteger) getTotleCount{
    return midsArray.count;
    //"SELECT COUNT(*) FROM chatlog_table;"
}
-(NSDictionary*) getMessageByIndex:(NSInteger)index{
    
    NSInteger targetMID = [midsArray[index] integerValue];
    NSDictionary *message;
    
    if ([db open]) {
        
        NSString *sqlCmd = [NSString stringWithFormat:@"SELECT * FROM chatlog_table WHERE %@ = %ld;",MID_FIELD,(long)targetMID];
        FMResultSet *result = [db executeQuery:sqlCmd];
        
        while ([result next]) {
            
            message = @{ID_KEY:@([result intForColumn:ID_KEY]),
                        USER_NAME_KEY:[result stringForColumn:USER_NAME_KEY],
                        MESSAGE_KEY:[result stringForColumn:MESSAGE_KEY],
                        TYPE_KEY:@([result intForColumn:TYPE_KEY])};
        }
        
        [db close];
    }
    return message;
}


@end
