# SwiftCommon
SwiftCommon project includes something that can be reused in the future.

## ViewControllers

### SCImageCropperViewController

#### Usage
It's easy to use this cropper, you implement the protocol `SAPIImageCropperDelegate` first step and then push or present the cropper view controller.

Implement SCImageCropperDelegate to handle the result:

	protocol SCImageCropperDelegate {
    
    	func imageCropper(cropper: SCImageCropperViewController, didFinishCroppedWithImage resultImage: UIImage)
    	func imageCropperDidCancel(cropper: SCImageCropperViewController)
    
	}
	
Push or present the cropper view controller after getting a image:
	
	let cropperVC = SCImageCropperViewController(image: image, cropSize: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.width))
   	cropperVC.delegate = self
    self.navigationController?.pushViewController(cropperVC, animated: true)

## Views

## Utilities
