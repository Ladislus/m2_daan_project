import UIKit
import CoreData
import MapKit

class DetailsViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var _tableview: UITableView!
    @IBOutlet weak var _title: UILabel!
    var category: Category!
    let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let _loc = CLLocationManager()
    var userPosition: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._tableview.dataSource = self
        self._title.text = self.category.name
        
        self.setupLongPressGesture()

        // Activate Geoloc'
        self._loc.requestAlwaysAuthorization()
        self._loc.desiredAccuracy = kCLLocationAccuracyBest
        self._loc.requestWhenInUseAuthorization()
        self._loc.startUpdatingLocation()
        self._loc.delegate = self
        self._loc.startUpdatingHeading()
    }
    
    // Function link to the "+" button to add a chrono
    @IBAction func addChrono() {
        // Popup to add a chrono
        let alert = UIAlertController(title: "Ajouter un chrono", message: "Veuillez entrer le nom du chrono que vous voulez ajouter", preferredStyle: .alert)
        var textField = UITextField()
        // Action to add a chrono
        let action = UIAlertAction(title: "Ajouter", style: . default) { (action) in
            // Assert textfield is not empty
            if textField.text != .some("") && textField.text != .none {
                let newChrono = Chrono(context: self._context)
                newChrono.name = textField.text
                newChrono.category = self.category
                // If the geoloc is available, add it to the task
                if let pos = self.userPosition {
                    newChrono.lat = pos.coordinate.latitude
                    newChrono.lon = pos.coordinate.longitude
                }
            
                // Save into CoreData
                do {
                    try self._context.save()
                    print("Saved chrono: '" + newChrono.name! + "'")
                } catch {
                    print("Can't save: \(error)")
                }
            } else {
                let errorAlert = UIAlertController(title: "Erreur de sauvegarde", message: "Il faut renseigner un nom pour le nouveau chrono", preferredStyle: .alert)
                self.present(errorAlert, animated: true, completion: {
                    errorAlert.view.superview?.isUserInteractionEnabled = true
                    errorAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
                })
            }
            // Update Chrono table
            self._tableview.reloadData()
        }
        // Same action but with a quickstart (Chrono already started
        let actionQuick = UIAlertAction(title: "QickStart", style: .destructive) { (action) in
            if textField.text != .some("") && textField.text != .none {
                let newChrono = Chrono(context: self._context)
                newChrono.name = textField.text
                newChrono.category = self.category
                newChrono.start = Date()
                if let pos = self.userPosition {
                    newChrono.lat = pos.coordinate.latitude
                    newChrono.lon = pos.coordinate.longitude
                }
            
                do {
                    try self._context.save()
                    print("Saved chrono: '" + newChrono.name! + "'")
                } catch {
                    print("Can't save: \(error)")
                }
            } else {
                let errorAlert = UIAlertController(title: "Erreur de sauvegarde", message: "Il faut renseigner un nom pour le nouveau chrono", preferredStyle: .alert)
                self.present(errorAlert, animated: true, completion: {
                    errorAlert.view.superview?.isUserInteractionEnabled = true
                    errorAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
                })
            }
            
            self._tableview.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Nom"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.addAction(actionQuick)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Method to close the alert
    @objc func dismissOnTapOutside() {
       self.dismiss(animated: true, completion: nil)
    }
    
    // Function called to update the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
             if let pos = locations.last {
                 self.userPosition = pos
             }
         }
    }
    
    // Function which return the amount of rows in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.category.chronos?.count ?? 0
    }
    
    // Function to create a new cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chrono = self.category.chronos![indexPath.row] as! Chrono
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChronoCellIdentifier", for: indexPath) as! ChronoCell
        cell._title?.text = chrono.name
        cell._time?.text = secondsToString(TimeInSeconds: totalTime(chrono))
        cell._chrono = chrono
        cell._context = self._context
        cell.initisialize()
        
        return cell
    }
    
    // Boilerplate Setup for gesture recognizer
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 0,5 second press
        longPressGesture.delegate = self
        self._tableview.addGestureRecognizer(longPressGesture)
    }
    
    // Function called to handle LongTouch gesture (Rename category)
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self._tableview)
        if let indexPath = self._tableview.indexPathForRow(at: touchPoint) {
            let clickedCell = self._tableview.cellForRow(at: indexPath) as! ChronoCell
            let clickedChrono = clickedCell._chrono!
            // Create the alert
            let alert = UIAlertController(title: "Editer le chrono", message: "Veuillez entrer le nouveau nom du chrono '\(clickedChrono.name ?? "")'", preferredStyle: .alert)
            // Create a textfield to link it with the one inside the actions
            var textField = UITextField()
            textField.text = clickedChrono.name
            // Default action (create the category)
            let action = UIAlertAction(title: "Editer", style: . default) { (action) in
                // Check if the textfield is empty
                if textField.text != .some("") && textField.text != .none {
                    // Create the new category
                    clickedChrono.name = textField.text
                
                    // Try saving it
                    do {
                        try self._context.save()
                        print("Updated chrono: '" + clickedChrono.name! + "'")
                    } catch {
                        print("Can't save: \(error)")
                    }
                    // Textfield is empty
                } else {
                    // Popup error
                    let errorAlert = UIAlertController(title: "Erreur de sauvegarde", message: "Il faut renseigner un nom pour le chrono", preferredStyle: .alert)
                    // Prensent the error with the possibility to tap it out
                    self.present(errorAlert, animated: true, completion: {
                        errorAlert.view.superview?.isUserInteractionEnabled = true
                        errorAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
                    })
                }
                // Update UITable to display new Category
                self._tableview.reloadData()
            }
            // Add the textfield
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Nom"
                alertTextField.text = clickedChrono.name
                textField = alertTextField
            }
            alert.addAction(action)
            // Prensent the pop-up
            present(alert, animated: true, completion: nil)
        } else {
            exitWithMsg(Message: "Couldn't convert touchpoint \(touchPoint) to IndexPath")
        }
    }
    
    // Cell deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let cell = tableView.cellForRow(at: indexPath) as! ChronoCell
            cell._timer?.invalidate()
            
            let chrono = cell._chrono!
            chrono.category = nil
            
            print("Chrono '\(chrono.name!)' supprimée !")
            
            self._context.delete(chrono)
            do {
                try self._context.save()
                print("Chrono suppression commit")
            } catch {
                print("Can't commit: \(error)")
            }
            self._tableview.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
