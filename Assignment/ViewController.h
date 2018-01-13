//
//  ViewController.h
//  Assignment
//
//  Created by WeiTing Juan on 2018/1/10.
//  Copyright © 2018年 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define CAPTURE_FPS 30

@interface ViewController : UIViewController <AVCaptureFileOutputRecordingDelegate> {
    BOOL isRecording;
    AVCaptureSession *captureSession;
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureDeviceInput *deviceInput;
    NSURL *currentURL;
    PHAsset *videoAsset;
    UIView *cameraView;
    UIView *playerView;
    AVPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIButton *btn_record;
@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;

- (void) CameraSetOutputProperties;
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;
- (IBAction)StartStopButtonPressed:(id)sender;
- (IBAction)CameraToggleButtonPressed:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)seletcVideo:(id)sender;
- (IBAction)closeReplay:(id)sender;

@end



