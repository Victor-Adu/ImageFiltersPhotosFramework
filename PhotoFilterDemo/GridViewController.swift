//
//  GridViewController.swift
//  PhotoFilterDemo
//
//  Created by Victor  Adu on 8/10/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import Photos

class GridViewController: UIViewController, UICollectionViewDataSource, PhotoSelectedDelegate {
    
    var assetsFetchResult : PHFetchResult!
    var imageManager : PHCachingImageManager!
    var assetGridThumbnailSize : CGSize!
    
    var delegate : PhotoSelectedDelegate?
   
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self   //I have connected this link in SB so this is redundant
        
        //create a PHCachingImageManager
        self.imageManager = PHCachingImageManager()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //grab the cell size from our collectionview
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var cellSize = flowLayout.itemSize
        self.assetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    }
    
    //MARK: Segue to Photo VC
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowPhoto" {
            var cell = sender as CellForPhoto //??
            var indexPath = self.collectionView.indexPathForCell(cell)
            
            let photoVC = segue.destinationViewController as PhotoViewController
            photoVC.asset = self.assetsFetchResult[indexPath.item] as PHAsset
            photoVC.delegate = self   //Setting 'GridViewController' to be the delegate for 'PhotoViewController'
        }
    }
    
    
    
    //MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResult.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as CellForPhoto
        
        var currentTag = cell.tag + 1  //Every image is tagged by default. Adding '+1' auto-correct pictures to show with the right tags.
        println("cell has been used \(currentTag) times")
        cell.tag = currentTag
        
        var asset = self.assetsFetchResult[indexPath.item] as PHAsset
        //requesting the image for asset for each cell
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (result : UIImage!, [NSObject : AnyObject]!) -> Void in
            if cell.tag == currentTag{
                cell.imageView.image = result
            }
        }
        
        return cell
    }
    
    
    //MARK: - PhotoSelectedDelegate
    
    func photoSelected(asset : PHAsset) -> Void {
        println("doing something for the delegate")
        self.delegate!.photoSelected(asset)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


