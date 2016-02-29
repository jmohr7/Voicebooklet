//
//  ViewController.h
//  voicebooklet
//
//  Created by Joseph Mohr on 11/9/14.
//  Copyright (c) 2014 Joe Mohr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Slt/Slt.h>

@class PocketsphinxController;
@class FliteController;

@interface ViewController : UIViewController <OpenEarsEventsObserverDelegate, FBLoginViewDelegate>{
    Slt *slt;
    PocketsphinxController *pocketsphinxController;
    OpenEarsEventsObserver *openEarsEventsObserver;
}
-(void)startListening;

@property (nonatomic, strong) Slt *slt;

@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) FliteController *fliteController;

@end

