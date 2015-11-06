//
//  SAPIImageCropperViewController.swift
//  SAPISwiftStandardDemo
//
//  Created by jiangzhenjie on 15/10/28.
//  Copyright © 2015年 passport. All rights reserved.
//

import UIKit

protocol SCImageCropperDelegate {
    
    func imageCropper(cropper: SCImageCropperViewController, didFinishCroppedWithImage resultImage: UIImage)
    func imageCropperDidCancel(cropper: SCImageCropperViewController)
    
}

class SCImageCropperViewController: UIViewController, UIScrollViewDelegate {

    var originalImage: UIImage!
    var cropSize: CGSize = CGSizeZero
    var maxZoomScale: CGFloat = 0.0
    
    var scrollView: UIScrollView!
    var showImageView: UIImageView!
    var overlayView: UIView!
    
    var delegate: SCImageCropperDelegate?
    
    convenience init(image: UIImage, cropSize: CGSize, maxZoomScale: CGFloat = 3.0) {
        self.init()
        originalImage = image
        self.cropSize = cropSize
        self.maxZoomScale = maxZoomScale
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureControlButton()
        configureRecognizer()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Private Methods
    
    func configureView() {
    
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false
        
        scrollView = UIScrollView(frame: CGRect(origin: CGPointZero, size: cropSize))
        scrollView.center = self.view.center
        scrollView.userInteractionEnabled = true
        scrollView.multipleTouchEnabled = true
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.layer.borderColor = UIColor.whiteColor().CGColor
        scrollView.layer.borderWidth = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        overlayView = UIView(frame: self.view.bounds)
        overlayView.alpha = 0.5
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.userInteractionEnabled = false
        self.view.addSubview(overlayView)

        clipOverlay()
        
        let widthScale = cropSize.width / originalImage.size.width
        let heightScale = cropSize.height / originalImage.size.height
        let maxScale = max(widthScale, heightScale)
        let width = originalImage.size.width * maxScale
        let height = originalImage.size.height * maxScale
        showImageView = UIImageView(image: originalImage)
        showImageView.userInteractionEnabled = true
        showImageView.multipleTouchEnabled = true
        showImageView.backgroundColor = UIColor.whiteColor()
        showImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        scrollView.contentSize = CGSize(width: width, height: height)
        scrollView.addSubview(showImageView)
        
        let originX = (width - scrollView.bounds.size.width) / 2
        let originY = (height - scrollView.bounds.size.height) / 2
        scrollView.contentOffset = CGPoint(x: originX, y: originY)
    }
    
    func configureControlButton() {
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 50.0, width: 100, height: 50))
        cancelButton.backgroundColor = UIColor.clearColor()
        cancelButton.titleLabel?.textColor = UIColor.whiteColor()
        cancelButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        cancelButton.titleLabel?.textAlignment = NSTextAlignment.Center
        cancelButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cancelButton.titleLabel?.numberOfLines = 0
        cancelButton.setTitle("取消", forState: UIControlState.Normal)
        cancelButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton)
        
        let confirmButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: self.view.frame.size.height - 50.0, width: 100, height: 50))
        confirmButton.backgroundColor = UIColor.clearColor()
        confirmButton.titleLabel?.textColor = UIColor.whiteColor()
        confirmButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        confirmButton.titleLabel?.textAlignment = NSTextAlignment.Center
        confirmButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        confirmButton.titleLabel?.numberOfLines = 0
        confirmButton.setTitle("选择", forState: UIControlState.Normal)
        confirmButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        confirmButton.addTarget(self, action: "confirm", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(confirmButton)
        
    }
    
    func configureRecognizer() {
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func clipOverlay() {
        let maskLayer = CAShapeLayer()
        let path = CGPathCreateMutable()
        
        let ratioOrigin = scrollView.frame.origin
        let ratioSize = scrollView.frame.size
        let overlaySize = overlayView.frame.size
        
        let leftRect = CGRect(x: 0, y: 0, width: ratioOrigin.x, height: overlaySize.height)
        
        let rightRect = CGRect(x: ratioOrigin.x + ratioSize.width, y: 0, width: overlaySize.width - ratioOrigin.x - ratioSize.width, height: overlaySize.height)
        
        let topRect = CGRect(x: 0, y: 0, width: overlaySize.width, height: ratioOrigin.y)
        
        let bottomRect = CGRect(x: 0, y: ratioOrigin.y + ratioSize.height, width: overlaySize.width, height: overlaySize.height - ratioOrigin.y + ratioSize.height)
        
        CGPathAddRect(path, nil, leftRect)
        CGPathAddRect(path, nil, rightRect)
        CGPathAddRect(path, nil, topRect)
        CGPathAddRect(path, nil, bottomRect)
        
        maskLayer.path = path
        self.overlayView.layer.mask = maskLayer
    }
    
    func getCropImage() -> UIImage {
    
        self.scrollView.layer.borderColor = UIColor.clearColor().CGColor
        self.scrollView.layer.borderWidth = 0.0

        UIGraphicsBeginImageContextWithOptions(cropSize, false, UIScreen.mainScreen().scale)
        self.scrollView.drawViewHierarchyInRect(CGRect(origin: CGPointZero, size: cropSize), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return showImageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
    }
    
    // MARK: Action
    
    func cancel() {
        delegate?.imageCropperDidCancel(self)
    }
    
    func confirm() {
        delegate?.imageCropper(self, didFinishCroppedWithImage: getCropImage())
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(showImageView)
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        
        let x = pointInView.x - (width / 2.0)
        let y = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, width, height)
        
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    // MARK: Memory Manage
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        scrollView = nil
        showImageView = nil
        originalImage = nil
    }

}
