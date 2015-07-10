//
//  LocationsViewController.swift
//  MyLocation
//
//  Created by Anthony Camara on 09/07/2015.
//  Copyright (c) 2015 Anthony Camara. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
// MARK: - Property
    
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchedRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchedRequest.entity = entity
        let sortDescription1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescription2 = NSSortDescriptor(key: "date", ascending: true)
        fetchedRequest.sortDescriptors = [sortDescription1, sortDescription2]
        
        fetchedRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
// MARK: - DeInit Object
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
// MARK: - View Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        NSFetchedResultsController.deleteCacheWithName("Locations")
        performFetch()
    }
    
// MARK: - Fetch
    
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            fatalCoreDataError(error)
        }
    }
    
// MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationCell
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        cell.configureForLocation(location)
        
        return cell
    }
  
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            managedObjectContext.deleteObject(location)
            
            var error: NSError?
            if !managedObjectContext.save(&error) {
                fatalCoreDataError(error)
            }
        }
    }
    
// MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                controller.locationToEdit = location
            }
        }
    }
    
}

// MARK: - Delegate NSFetchedResultsControllerDelegate

extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                println("NSFetchedResultsChangeInsert (object)")
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            case .Delete:
                println("NSFetchedResultsChangeDelete (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            case .Update:
                println("NSFetchedResultsChangeUpdate (object)")
                if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell {
                    let location = controller.objectAtIndexPath(indexPath!) as! Location
                    cell.configureForLocation(location)
            }
            
            case .Move:
                println("NSFetchedResultsChangeMove (object)")
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                println("NSFetchedResultsChangeInsert (section)")
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
           
            case .Delete:
                println("NSFetchedResultsChangeDelete (section)")
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            case .Update:
                println("NSFetchedResultsChangeUpdate (section)")
            
            case .Move:
                println("NSFetchedResultsChangeMove (section)")
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
    
}
