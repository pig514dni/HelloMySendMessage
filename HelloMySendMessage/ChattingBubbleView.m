//
//  ChattingBubbleView.m
//  HelloMySendMessage
//
//  Created by 張峻綸 on 2016/6/23.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

#import "ChattingBubbleView.h"

// Constants of UI layout
//泡泡聊天室跟螢幕最邊邊的距離為螢幕的2%
#define SIDE_PADDING_RATE       0.02
//泡泡聊天室的最長寬度為螢幕的70%
#define MAX_BUBBLE_WIDTH_RATE   0.7
//文字的UILabel跟泡泡框的距離為10PX
#define CONTENT_MARGIN          10.0
//泡泡尾巴寬為10PX
#define BUBBLE_TALE_WIDTH       10.0
//文字字體大小為16
#define TEXT_FONR_SIZE          16.0

@interface ChattingBubbleView ()
{
    //Subviews
    UIImageView * chattingImageView;
    UILabel * chattingLabel;
    UIImageView *backgroundImagView;
}

@end

@implementation ChattingBubbleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype) initWithItem:(ChattingItem*)item offsetY:(CGFloat) offsetY
{
    // Step1: Calculate a basic frame
    self=[super initWithFrame:CGRectZero];
    self.frame=[self calculateBasicFrame:item.type offsetY:offsetY];
    // Step2: Calculate with Image
    CGFloat currentY = 0.0;
    
    UIImage *image= item.image;
    
    //x,y起始點為泡泡外框
    if (image != nil) {
        CGFloat x=CONTENT_MARGIN;
        CGFloat y=CONTENT_MARGIN;
        
        if (item.type == fromOthers) {
            x += BUBBLE_TALE_WIDTH;
        }
        
        //比較圖片及(70%寬度框-2*2* CONTENT_MARGIN-BUBBLE_TALE_WIDTH)取最小值
        //假如圖片寬100PX 最大寬為300PX這樣就秀出圖片100PX就好
        CGFloat displayWidth = MIN(image.size.width,
                    self.frame.size.width- 2* CONTENT_MARGIN-BUBBLE_TALE_WIDTH);
        //把實際顯示的寬/實際的照片寬能得到比例
        CGFloat displayRatio = displayWidth/image.size.width;
        //因要把照片維持等比例,所以把高也*剛剛算出來的寬度比例,就能維持等比例照片
        CGFloat displayHeight = image.size.height * displayRatio;
        
        //x,y起始點為泡泡外框
        CGRect displayFrame = CGRectMake(x, y, displayWidth, displayHeight);
        //Prepare chattingImageView
        //創造一個chattingImageView
        chattingImageView = [[UIImageView alloc]initWithFrame:displayFrame];
        //把上傳的照片給chattingImageView
        chattingImageView.image=image;
        //讓底層的layer幫忙做出圓角弧度
        chattingImageView.layer.cornerRadius=5.0;
        //讓底層的layer幫忙把做成圓角弧度後超出的部分切掉
        chattingImageView.layer.masksToBounds=true;
        
        [self addSubview:chattingImageView];
        //計算把泡泡框加上照片後的Y值,好讓使用者輸入的文字加上
        currentY=CGRectGetMaxY(displayFrame);
    }
    
    // Step3: Calculate with Text
    NSString *text = item.text;
    if(text != nil){
        CGFloat x = CONTENT_MARGIN;
        CGFloat y = currentY + TEXT_FONR_SIZE/2;
        if (item.type == fromOthers) {
            x +=BUBBLE_TALE_WIDTH;
        }
        
        CGRect displayFrame = CGRectMake(x, y,
            self.frame.size.width - 2 * CONTENT_MARGIN -BUBBLE_TALE_WIDTH,
            TEXT_FONR_SIZE);
        
        //Creat Label
        chattingLabel = [[UILabel alloc] initWithFrame:displayFrame];
        chattingLabel.font = [UIFont systemFontOfSize:TEXT_FONR_SIZE];
        //numberOfLines 指定Label的高度 0為不限高度
        chattingLabel.numberOfLines = 0;
        chattingLabel.text=text;
        //sizeToFit 自動調整寬跟高以配合文字數量
        [chattingLabel sizeToFit];
        
        [self addSubview:chattingLabel];
        
        currentY = CGRectGetMaxY(chattingLabel.frame);
    }
    
    // Step4: Calculate bubble view size
    CGFloat finalHeight = currentY + CONTENT_MARGIN;
    CGFloat finalWidth = 0.0;
    //先計算最終Image的寬
    if (chattingImageView != nil) {
        if (item.type == fromMe) {
            finalWidth = CGRectGetMaxX(chattingImageView.frame) +
            CONTENT_MARGIN + BUBBLE_TALE_WIDTH;
        }else{
            //fromOther
            finalWidth = CGRectGetMaxX(chattingImageView.frame) +
            CONTENT_MARGIN;
        }
    }
    
    if (chattingLabel != nil) {
        
        CGFloat labelWidth = 0;
        if (item.type == fromMe) {
            labelWidth = CGRectGetMaxX(chattingLabel.frame) +
            CONTENT_MARGIN + BUBBLE_TALE_WIDTH;
        }else{
            //fromOther
            labelWidth = CGRectGetMaxX(chattingLabel.frame) +
            CONTENT_MARGIN;
        }
        //比較照片以及文字取最長的
        finalWidth =MAX(finalWidth,labelWidth);
    }
    
    CGRect selfFrame = self.frame;
    if (item.type==fromMe && chattingImageView == nil) {
        selfFrame.origin.x +=selfFrame.size.width-finalWidth;
    }
    selfFrame.size.width=finalWidth;
    selfFrame.size.height=finalHeight;
    self.frame=selfFrame;
    
    // Step5: Handle background display
    [self prepareBackgroundImageView:item.type];
    
    return self;
}

-(void) prepareBackgroundImageView:(ChattingItemType) type {

    CGRect bgImageViewFrame = CGRectMake(0, 0, self.frame.size.width,
                                         self.frame.size.height);
    backgroundImagView = [[UIImageView alloc]initWithFrame:bgImageViewFrame];
    
    if (type == fromMe) {
        UIImage * image = [UIImage imageNamed:@"fromMe.png"];
        //因照片長度寬度有限,要符合USER輸入的長度,需把照片延長或增高
        //resizableImageWithCapInsets蘋果的把照片縮放的函式,已連續圖方式呈現
        //UIEdgeInsetsMake(上,左,下,右)規定不可縮放的地方,其他地方進行縮放
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 17, 28)];
        backgroundImagView.image=image;
    }else {
        //fromOthers
        //resizableImageWithCapInsets蘋果的把照片縮放的函式,已連續圖方式呈現
        //UIEdgeInsetsMake(上,左,下,右)規定不可縮放的地方
        UIImage *image = [UIImage imageNamed:@"fromOthers.png"];
        image= [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 22, 17, 20)];
        backgroundImagView.image=image;
    }
    //把背景泡泡貼上去
    [self addSubview:backgroundImagView];
    //因後貼的會顯示在前面,所以要把背景泡泡貼到背景
    [self sendSubviewToBack:backgroundImagView];
}

-(CGRect) calculateBasicFrame:(ChattingItemType)type offsetY:(CGFloat)offsetY{
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat sidePadding = screenWidth * SIDE_PADDING_RATE;
    CGFloat maxWidth = screenWidth * MAX_BUBBLE_WIDTH_RATE;
    
    CGFloat offsetX;
    
    if (type == fromMe) {
        offsetX = screenWidth - sidePadding - maxWidth;
    }else{
        //fromOthers
        offsetX = sidePadding;
    }
    
    return CGRectMake(offsetX, offsetY, maxWidth, 10);
}

@end
