//
//  ViewController.swift
//  PhotoFilterDemo
//
//  Created by Victor  Adu on 8/10/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PHPhotoLibraryChangeObserver, PhotoSelectedDelegate, UICollectionViewDelegate {
    
    var filters = ["CISepiaTone", "CIPhotoEffectMono", "CIVignette","CIColorMonochrome", "CIPhotoEffectProcess"]
                            

    @IBOutlet weak var imageView: UIImageView!
  
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellSize: CGSize!
    
    var filterThumbnail : UIImage?
    
    let photoPicker = UIImagePickerController()
    
    var imageViewSize : CGSize!
    
    var selectedAsset : PHAsset?
    
    var myfilters = [Filter]()
    
    let adjustmentFormatterIndentifier = "com.ImageFilterDemo1.victoradu"
    
    var context = CIContext(options: nil)
    
    //Setup ActionController
    let actionController = UIAlertController(title: "Source Type", message: "Choose a source type", preferredStyle: UIAlertControllerStyle.ActionSheet)
    //Create AlertView
    let alertView = UIAlertController(title: "Alert!", message: "Requesting permission to access your Photos", preferredStyle: UIAlertControllerStyle.Alert)
    
    
    //    //Placed a button over my UIImageView to allow user to add photo by clicking the image.
    //    @IBAction func getPhotoImage(sender: AnyObject) {
    //
    //        if (self.actionController.popoverPresentationController != nil) {
    //
    //            self.actionController.popoverPresentationController.sourceView = self.imageView
    //
    //             //This will handle the the popup to show properly on the respective button in iPad
    //            self.actionController.popoverPresentationController.sourceRect = CGRect(x: self.imageView.frame.width/2, y: self.imageView.frame.height, width: 0, height: 0)
    //
    //        }
    //        self.presentViewController(self.actionController, animated: true, completion: nil)
    //    } 
    


    @IBAction func photoHandlePressedBtn(sender: AnyObject) {
        
        //This will handle the the popup to show properly on the respective button in iPad
        if (self.actionController.popoverPresentationController != nil) {
            self.actionController.popoverPresentationController.sourceView = sender as UIButton
            
        }
        // The NSUserDefaults checks whether it's the first time user is using the app feature and presents 'ActionController' or 'AlertView' afterwards.
        if NSUserDefaults.standardUserDefaults().boolForKey("Requesting Initial Permission") {
            self.presentViewController(actionController, animated: true, completion: nil)
            
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Requesting Initial Permission")
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    //Setting and adding the 'Okay' button to 'UIAlertView'
    func setupAlertView() {
        let ActionOkay = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.presentViewController(self.actionController, animated: true, completion: nil)
            
        })
        
        self.alertView.addAction(ActionOkay)
    }
    
    //Setting up a function to add 'UIActionSheet' to present 'Camera' or 'PhotoLibrary' to user
    func setupAlertController() {
        let optionForCamera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            self.photoPicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(self.photoPicker, animated: true, completion: nil)
            
        })
        
        let optionForPhotoLib = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            //            self.photoPicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            //            self.presentViewController(self.photoPicker, animated: true, completion: nil)
            
            //Segue to Collection View
            self.performSegueWithIdentifier("ShowGrid", sender: self)
            
        })
        
        //Add VidCam
        let optionForVideo = UIAlertAction(title: "Record Video", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            let videoVC = self.storyboard.instantiateViewControllerWithIdentifier("RecordVideoVC") as RecordVideoViewController
            
            self.presentViewController(videoVC, animated: true, completion: { () -> Void in
              println("Showing Record Video View Controller")
            })
        })
        
        let optionToCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
            
            //Cancel
            
        })
        
        self.actionController.addAction(optionForCamera)
        self.actionController.addAction(optionForPhotoLib)
        self.actionController.addAction(optionForVideo)
        self.actionController.addAction(optionToCancel)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.photoPicker.allowsEditing = true
        self.photoPicker.delegate = self
        
        self.setupFiltersArray()
        self.setupAlertController()
        self.setupAlertView()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    func setupFiltersArray() {
        for filterString in self.filters {
            let filter = Filter(name: filterString)
            self.myfilters.append(filter)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var flowlayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var itemSize = flowlayout.itemSize
        self.cellSize = itemSize
        
        //Hides collection
        if self.selectedAsset == nil {
        self.collectionView.hidden = true
        }else{
            self.collectionView.hidden = false
        }
        self.collectionView.reloadData()
    }
    
    
    //MARK: -UIImagePickerControllerDelegate Method
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage  //Specifies an image edited by user.
        self.imageView.image = editedImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Segue Method
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowGrid" {
            let gridVC = segue.destinationViewController as GridViewController
            gridVC.assetsFetchResult = PHAsset.fetchAssetsWithOptions(nil)
            gridVC.delegate = self  //Here we are setting ViewController to be the delegate for 'GridViewController'
        }
    }
    
    //MARK:  Photo Selected Delegate
    func photoSelected(asset: PHAsset) {
        println("Final step to put fetched image back to main screen")
        self.selectedAsset = asset
        
        self.fetchThumbnailImage()
        self.updateImage()
        
    }
    
    //MARK: Filters On Display
    
    func applyFilter(filterName : String) {
        
        var options = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(data : PHAdjustmentData!) -> Bool in
            
            return data.formatIdentifier == self.adjustmentFormatterIndentifier && data.formatVersion == "1.0"
            
        }
        
        self.selectedAsset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput : PHContentEditingInput!, info : [NSObject : AnyObject]!) -> Void in
            
            //Grabbing Image and converting to CIImage
            var url = contentEditingInput.fullSizeImageURL
            var orientation = contentEditingInput.fullSizeImageOrientation
            var inputImage = CIImage(contentsOfURL: url)
            inputImage = inputImage.imageByApplyingOrientation(orientation)
            
            //Creating Filter
            var filter = CIFilter(name: filterName)
            filter.setDefaults()
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            //filter.setValue(1.0, forKey: kCIAttributeTypeDistance)
            var outputImage = filter.outputImage
            
            var cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
            var finalImage = UIImage(CGImage: cgImage)
            var jpegData = UIImageJPEGRepresentation(finalImage, 0.9)
            
            //Create our adjustmentData
            var adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIndentifier, formatVersion: "1.0", data: jpegData)
            var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
            jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
            contentEditingOutput.adjustmentData = adjustmentData
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                
                var request = PHAssetChangeRequest(forAsset: self.selectedAsset)
                request.contentEditingOutput = contentEditingOutput
                
                }, completionHandler: { (success : Bool, error : NSError!) -> Void in
                    
                    if !success {
                        println(error.localizedDescription)
                    }
                    
            })
            
            
        })
        
    }
    
    func updateImage() {
        
        var targetSize = self.imageView.frame.size
        PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, info : [NSObject : AnyObject]!) -> Void in
            self.imageView.image = result
        }
        
    }
    
    func fetchThumbnailImage() {
        
        if self.selectedAsset != nil{
            PHImageManager.defaultManager().requestImageForAsset(self.selectedAsset, targetSize: self.cellSize, contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (result, info) -> Void in
                //cell.filterImageView.image = result
                
                self.filterThumbnail = result
                
                self.collectionView.reloadData()
            })
        }
        
    }
    
    func photoLibraryDidChange(changeInstance: PHChange!) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            if self.selectedAsset != nil {
                var changeDetails = changeInstance.changeDetailsForObject(self.selectedAsset)
                if changeDetails != nil {
                    self.selectedAsset = changeDetails.objectAfterChanges as? PHAsset
                    
                    if changeDetails.assetContentChanged {
                        
                        self.updateImage()
                        
                    }
                    
                }
            }
        }
    }
    
    //MARK: UICollectionView Data Source Methods
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellFilter", forIndexPath: indexPath) as FilterCell
        
        let filter = myfilters[indexPath.item]
        
        if self.filterThumbnail != nil {
            cell.filterImageView.image = self.filterThumbnail
            if filter.thumbnailImage != nil {
                cell.filterImageView.image = filter.thumbnailImage
            }else {
                filter.createFilterThumbnailFromImage(self.filterThumbnail!, completionHandler: { (image) -> Void in
                    cell.filterImageView.image = image
                })
            }
            
        }
        cell.filterLabel.text = filter.name

        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        
        
        return self.filters.count
    }
    
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        //let cell = collectionView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as CellForQuestion
        //let question = self.questions![indexPath.row] as Question
        let requestedFilterName = self.filters[indexPath.row]
        
        self.applyFilter(requestedFilterName)
        
        
    }
    
}

