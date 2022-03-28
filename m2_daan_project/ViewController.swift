import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var _tableview: UITableView!
    let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UITable settings
        self._tableview.dataSource = self
        self._tableview.delegate = self
    }
    
    @IBAction func GoToMap() {
        // Select "Main" storyboard
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        print("Goto Map")
        // Select the MapViewController
        let MvC = Storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapViewController
        // Add the context to the map, in order to get the Chronos
        // Prevent fetching it again from main thread
        MvC._context = self._context
        // Launch navigation
        self.navigationController?.pushViewController(MvC, animated: true)
    }
    
    @IBAction func addCategory() {
        // Create the aloert
        let alert = UIAlertController(title: "Ajouter une catégorie", message: "Veuillez entrer le nom de la catégorie que vous voulez ajouter", preferredStyle: .alert)
        // Create a textfield to link it with the one inside the actions
        var textField = UITextField()
        // Default action (create the category)
        let action = UIAlertAction(title: "Ajouter", style: . default) { (action) in
            // Check if the textfield is empty
            if textField.text != .some("") && textField.text != .none {
                // Create the new category
                let newCategory = Category(context: self._context)
                newCategory.name = textField.text
            
                // Try saving it
                do {
                    try self._context.save()
                    print("Saved category: '" + newCategory.name! + "'")
                } catch {
                    print("Can't save: \(error)")
                }
                // Textfield is empty
            } else {
                // Popup error
                let errorAlert = UIAlertController(title: "Erreur de sauvegarde", message: "Il faut renseigner un nom pour la nouvelle catégorie", preferredStyle: .alert)
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
            textField = alertTextField
        }
        alert.addAction(action)
        // Prensent the pop-up
        present(alert, animated: true, completion: nil)
    }
    
    // Method to close the alert
    @objc func dismissOnTapOutside() {
       self.dismiss(animated: true, completion: nil)
    }
    
    // Utility function exit with an error message
    private func exitWithMsg(Message msg: String?) {
        if let msg = msg {
            print("[Error] " + msg)
        }
        exit(1)
    }
    
    // Fetch all categories from CoreData
    private func getAllCategories() -> [Category] {
        let rqst = Category.fetchRequest()
        do {
            return try self._context.fetch(rqst)
        } catch {
            print(error)
            self.exitWithMsg(Message: "Couldn't fetch all categories")
            // Unreachable
            return []
        }
    }
        
    // Function returning the number of row in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            let count: Int = try self._context.count(for: Category.fetchRequest())
            return count
        } catch {
            print(error)
            self.exitWithMsg(Message: "Couldn't fetch category count")
            // Unreachable
            return -1
        }
    }

    // Function which create a new cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cat = self.getAllCategories()[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategoryCell
        cell._title?.text = cat.name
        cell._time?.text = secondsToString(TimeInSeconds: 0)
        cell._category = cat
        cell.start()
        
        return cell
    }
    
    // Cell deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // If the action is a deletion
        if editingStyle == .delete {
            
            // Fetch the cell
            let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
            cell._timer.invalidate()
    
            let cat = cell._category!
            
            print("Categorie '\(cat.name!)' supprimée !")
            
            // Delete category from CoreData
            self._context.delete(cat)
            do {
                try self._context.save()
                print("Category suppression commit")
            } catch {
                print("Can't commit: \(error)")
            }
            self._tableview.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Select "Main" storyboard
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Fetch the clicked category
        let cat = self.getAllCategories()[indexPath.row]
        print("Catégorie \(cat.name!) cliquée")
        // Select the MapViewController
        let DvC = Storyboard.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        // Unselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        // Transfert the category to the next page
        DvC.category = cat
        // Launch the navigation
        self.navigationController?.pushViewController(DvC, animated: true)
    }
}
