//
//  LocationDetailsViewController.swift
//  MyLocation
//
//  Created by Anthony Camara on 08/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
// MARK: - Property
    
    var coordinate =            CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:              CLPlacemark?
    var descriptionText =       ""
    var categoryName =          "No Category"
    var managedObjectContext:   NSManagedObjectContext!
    var date =                  NSDate()
    var locationToEdit:         Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var image:                  UIImage?
    var observer:               AnyObject!
    
//MARK: - IBOutlet
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel:       UILabel!
    @IBOutlet weak var latitudeLabel:       UILabel!
    @IBOutlet weak var longitudeLabel:      UILabel!
    @IBOutlet weak var addressLabel:        UILabel!
    @IBOutlet weak var dateLabel:           UILabel!
    @IBOutlet weak var imageView:           UIImageView!
    @IBOutlet weak var addPhotoLabel:       UILabel!
    
    
//MARK: - IBAction
    
    @IBAction func done() {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        var location: Location
        if let temp = locationToEdit {
            hudView.text = "Update"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
            location.photoID = nil
        }
        
        location.locationDescription = descriptionText
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            
            let data = UIImageJPEGRepresentation(image, 0.5)
            
            var error: NSError?
            if !data.writeToFile(location.photoPath, options: .DataWritingAtomic, error: &error) {
                println("Error printing file: \(error)")
            }
        }
        
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
       let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
//MARK: - Init and DeInit
    
    deinit {
        println("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
// MARK: - View Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForBackgroundNotification()
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let image = location.photoImage {
                    showImage(image)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = ""
        }
        
        dateLabel.text = formatDate(date)
        let gestureReconizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureReconizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureReconizer)
        
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
        descriptionTextView.textColor = UIColor.whiteColor()
        descriptionTextView.backgroundColor = UIColor.blackColor()
        
        addPhotoLabel.textColor = UIColor.whiteColor()
        addPhotoLabel.highlightedTextColor = addPhotoLabel.textColor
        
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
    }
   
    
// MARK: - Convert in String

    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line = ""
        line.addText(placemark.subThoroughfare)
        line.addText(placemark.thoroughfare, withSeparator: ", ")
        line.addText(placemark.locality, withSeparator: ", ")
        line.addText(placemark.administrativeArea, withSeparator: ", ")
        line.addText(placemark.postalCode, withSeparator: ", ")
        line.addText(placemark.country, withSeparator: ", ")
        return line
    }
    
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    
// MARK: Show
    
    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }
    
    
// MARK: Notification
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] notification in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
// MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
            case (0, 0):
                return 88
            case (1, _):
                return imageView.hidden ? 44 : 280
            case (2, 2):
                addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
                addressLabel.sizeToFit()
                addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
                return addressLabel.frame.size.height + 20
            default:
                return 44
        }
    }
   
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
        
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        
        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }
        
        let selectView = UIView(frame: CGRect.zeroRect)
        selectView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectView
        
        if indexPath.row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor.whiteColor()
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
    }
    
// MARK: - PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
}


// MARK: - Extension UITextViewDelagate

extension LocationDetailsViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) ->Bool {
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
   
    
//MARK: - Keyboard
    
    func hideKeyboard(gestureReconizer: UIGestureRecognizer) {
        let point = gestureReconizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
}


// MARK: - delegate UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
    
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if let image = image {
            showImage(image)
        }
        
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
