//
//  MasterViewController.swift
//  Formation Builder
//
//  Created by Parker Wightman on 10/23/14.
//  Copyright (c) 2014 Alora Studios. All rights reserved.
//

import UIKit
import CloudKit

class Q {
    class func main(block: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var formations = [Formation]()
    var db: CKDatabase!


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.db = CKContainer.defaultContainer().publicCloudDatabase

        self.loadFormationsFromCloud()

        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sync", style: .Plain, target: self, action: "syncTapped")

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    func syncTapped() {
        self.syncAllFormations()
    }

    func loadFormationsFromCloud() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")

        let hud = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow ?? self.view, animated: true)
        db.performQuery(CKQuery(recordType: "Formation", predicate: predicate), inZoneWithID: nil) { (objs, error) -> Void in
            Q.main { hud.hide(true) }
            if error != nil {
                println("Oh noes! Error fetching records: \(error.localizedDescription)")
            } else {
                self.formations = (objs as [CKRecord]).map { Formation(record: $0) }
                Q.main { self.tableView.reloadData() }
            }
        }
    }

    func insertNewObject(sender: AnyObject) {
        let controller = UIAlertController(title: "New Formation", message: "Enter the name for your new formation", preferredStyle: .Alert)

        let createAction = UIAlertAction(title: "Create", style: .Default) { action in
            let record = CKRecord(recordType: "Formation")
            record.setValue((controller.textFields![0] as UITextField).text, forKey: "Name")
            record.setValue([], forKey: "Points")
            self.db.saveRecord(record) { (record, error) -> Void in
                if error != nil {
                    println("Oh noes! \(error.localizedDescription)")
                } else {
                    Q.main {
                        self.formations.insert(Formation(record: record), atIndex: 0)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                }
                
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in }

        controller.addAction(createAction)
        controller.addAction(cancelAction)

        controller.addTextFieldWithConfigurationHandler { field in }

        self.presentViewController(controller, animated: true, completion: nil)
    }

    func syncAllFormations() {
        let operation = CKModifyRecordsOperation(recordsToSave: self.formations.map { $0.record }, recordIDsToDelete: [])
        
        operation.savePolicy = .ChangedKeys

        operation.modifyRecordsCompletionBlock = { savedRecords, deletedIDs, error in
            if error != nil {
                println("Oh noes! \(error.code) - \(error.localizedDescription)")
            } else {
                println("Successfully saved \(savedRecords.count) records!")
            }
        }

        db.addOperation(operation)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let formation = formations[indexPath.row]
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.detailItem = formation
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                self.syncAllFormations()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let formation = formations[indexPath.row] as Formation
        cell.textLabel.text = formation.name
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            db.deleteRecordWithID(self.formations[indexPath.row].record.recordID) {
                (recordID, error) -> Void in
                if error != nil {
                    println("Oh noes! \(error.localizedDescription)")
                } else {
                    Q.main {
                        self.formations.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

