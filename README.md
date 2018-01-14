# Assignment

## Framework
* UIKit
* AVKit
* AVFoundation
* Photos
* MobileCoreServices

## Function
* viewDidLoad() - Initialization
    * Create AVCaptureSession instance
    * Add video device input
    * Add audio device input
    * Add video preview layer
    * Add movie file output
    * Initialize the video player
    * Display the preview layer
* cameraSetOutputProperties() - Connect the movieFileOutput
* captureOutput() - Save the video to photo library after finish recording
* cameraWithPosition() - Get the camera devices
* imagePickerController() - Store the URL of the video picked by user
* cameraToggleButtonPressed() - Switch between front and back camera
* startStopButtonPressed() - Create the path to save the video and start to record
* seletcVideo() - Select the video through image picker controller
* playVideo() - Play the video just recorded or selected
* closeReplay() - Move back to the recording layer


## Reference
* AVFoundation Programming Guide
* Stack Overflow
