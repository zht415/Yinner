//
//  YKWorkViewController.h
//  Yinner
//
//  Created by Maru on 15/5/27.
//  Copyright (c) 2015年 Alloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import <KRVideoPlayer/KRVideoPlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "YKLocationMediaModel.h"
#import "YKCoreDataManager.h"
#import "NSDate+Current.h"
#import "NSFileManager+Repeat.h"
#import "NSString+FileName.h"
#import "NSString+File.h"
#import "ReuseFrame.h"
#import "YKMatterModel.h"

@interface YKWorkViewController : UIViewController <AVAudioRecorderDelegate,UITableViewDataSource,UITableViewDelegate>
/** 是否已经合成 */
@property (nonatomic) BOOL alreadyMrege;
/** 素材模型 */
@property (nonatomic,strong,readonly) YKMatterModel *matter;

- (instancetype)initWithModel:(YKMatterModel *)model;

@end
