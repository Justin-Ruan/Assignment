//
//  ViewController.h
//  Assignment
//
//  Created by WeiTing Juan on 2018/1/10.
//  Copyright © 2018年 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define CAPTURE_FPS 30

@interface ViewController : UIViewController <AVCaptureFileOutputRecordingDelegate> {
    BOOL isRecording;
    AVCaptureSession *captureSession;
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureDeviceInput *deviceInput;
    NSURL *currentURL;
    PHAsset *videoAsset;
    
}

@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;

- (void) CameraSetOutputProperties;
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;
- (IBAction)StartStopButtonPressed:(id)sender;
- (IBAction)CameraToggleButtonPressed:(id)sender;
- (IBAction)playVideo:(id)sender;

@end



