//
//  ViewController.m
//  Assignment
//
//  Created by WeiTing Juan on 2018/1/10.
//  Copyright © 2018年 none. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize PreviewLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Create AVCaptureSession instance
    captureSession = [[AVCaptureSession alloc] init];
    
    //Add video device input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if(device){
        NSError *error;
        deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error: &error];
        if(!error){
            if([captureSession canAddInput:deviceInput]){
                [captureSession addInput:deviceInput];
            }
        }
    }
    
    //Add audio device input
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = NULL;
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if(audioDeviceInput){
        [captureSession addInput:audioDeviceInput];
    }
    
    //Add video preview layer
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession]];
    [[self PreviewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //Add movie file output
    movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    Float64 totalSecond = 60;
    int32_t preferredTimeScale = 30;
    CMTime maxDuration = CMTimeMakeWithSeconds(totalSecond, preferredTimeScale);
    movieFileOutput.maxRecordedDuration = maxDuration;
    
    movieFileOutput.minFreeDiskSpaceLimit = 1024*1024;
    
    if([captureSession canAddOutput:movieFileOutput]){
        [captureSession addOutput:movieFileOutput];
    }
    
    [self CameraSetOutputProperties];
    
    //Set image quality
    [captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    if([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]){
        [captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    //Display the preview layer
    CGRect layerRect = [[[self view] layer] bounds];
    [PreviewLayer setBounds: layerRect];
    [PreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    UIView *cameraView = [[UIView alloc] init];
    [[self view] addSubview:cameraView];
    [self.view sendSubviewToBack:cameraView];
    [[cameraView layer] addSublayer:PreviewLayer];

    [captureSession startRunning];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isRecording = NO;
}

- (void)CameraSetOutputProperties{
    [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
}
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition)Position{
    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession init];
    NSArray *devices =  [session devices];
    for (AVCaptureDevice *Device in devices)
    {
        if ([Device position] == Position)
        {
            return Device;
        }
    }
    return nil;
}

- (IBAction)CameraToggleButtonPressed:(id)sender{
    
    if ([[[AVCaptureDeviceDiscoverySession init] devices] count] > 1){
        NSError *error;
        //AVCaptureDeviceInput *videoInput = [self videoInput];
        AVCaptureDeviceInput *NewVideoInput;
        AVCaptureDevicePosition position = [[deviceInput device] position];
        if (position == AVCaptureDevicePositionBack)
        {
            NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
        }
        else if (position == AVCaptureDevicePositionFront)
        {
            NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
        }
        
        if (NewVideoInput != nil)
        {
            [captureSession beginConfiguration];
            
            [captureSession removeInput:deviceInput];
            if ([captureSession canAddInput:NewVideoInput])
            {
                [captureSession addInput:NewVideoInput];
                deviceInput = NewVideoInput;
            }
            else
            {
                [captureSession addInput:deviceInput];
            }
            
            //Set the connection properties again
            [self CameraSetOutputProperties];
            
            
            [captureSession commitConfiguration];
            
        }
    }
}
- (IBAction)StartStopButtonPressed:(id)sender{
    if (!isRecording){
        isRecording = YES;
        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        currentURL = outputURL;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outputPath])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
            {
                //Error - handle if requried
            }
        }
        //Start recording
        [movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        
    }else{
        isRecording = NO;
        [movieFileOutput stopRecording];
    }
}


- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if(RecordedSuccessfully){
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if ( status == PHAuthorizationStatusAuthorized ) {
                // Save the movie file to the photo library and cleanup.
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                    options.shouldMoveFile = YES;
                    PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                    PHObjectPlaceholder *assetPlaceholder = creationRequest.placeholderForCreatedAsset;
                    [creationRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                    PHFetchResult<PHAsset *> *newAssets = [PHAsset fetchAssetsWithLocalIdentifiers: @[assetPlaceholder.localIdentifier] options:nil];
                    PHAsset *videoAsset = [newAssets firstObject];
                    [videoAsset requestContentEditingInputWithOptions:[PHContentEditingInputRequestOptions new] completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                        currentURL = contentEditingInput.fullSizeImageURL;
                    }];
                } completionHandler:^( BOOL success, NSError *error ) {
                    if ( ! success ) {
                        NSLog( @"Could not save movie to photo library: %@", error );
                    }
                }];
            }
            else {
            }
        }];
        
        AVPlayer *player = [AVPlayer playerWithURL: currentURL];
        AVPlayerLayer *layer = [AVPlayerLayer layer];
        [layer setPlayer:player];
        [layer setFrame: [[[self view] layer] bounds]];
        [layer setBackgroundColor:[UIColor blackColor].CGColor];
        [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        UIView *playerView = [[UIView alloc] init];
        [[self view] addSubview:playerView];
        [self.view bringSubviewToFront:playerView];
        [[playerView layer] addSublayer:layer];
        [player play];
    }
    
}

- (IBAction)playVideo:(id)sender{
    
    [captureSession stopRunning];
    
    AVPlayer *player = [AVPlayer playerWithURL: currentURL];
    AVPlayerLayer *layer = [AVPlayerLayer layer];
    [layer setPlayer:player];
    [layer setFrame: [[[self view] layer] bounds]];
    [layer setBackgroundColor:[UIColor blackColor].CGColor];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    UIView *playerView = [[UIView alloc] init];
    [[self view] addSubview:playerView];
    [self.view bringSubviewToFront:playerView];
    [[playerView layer] addSublayer:layer];
    [player play];
    
//    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
//    controller.player = player;
//
//    [self addChildViewController:controller];
//    [self.view addSubview:controller.view];
//    controller.view.frame = self.view.frame;
    
    

}

@end
