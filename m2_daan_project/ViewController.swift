import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var _tableview: UITableView!
    var _context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self._tableview.dataSource = self
    }
    
    @IBAction func addCategory() {
        
        let alert = UIAlertController(title: "Ajouter une catégorie", message: "Veuillez entrer le nom de la catégorie que vous voulez ajouter", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Ajouter", style: . default) { (action) in
            // Code qui dit ce qui se passe qd on clique sur le bouton Add
            
            if textField.text != .some("") && textField.text != .none {
                let newCategory = Category(context: self._context)
                newCategory.name = textField.text
            
                do {
                    try self._context.save()
                    print("Saved category: '" + newCategory.name! + "'")
                } catch {
                    print("Can't save: \(error)")
                }
            } else {
                let errorAlert = UIAlertController(title: "Erreur de sauvegarde", message: "Il faut renseigner un nom pour la nouvelle catégorie", preferredStyle: .alert)
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
        
        present(alert, animated: true, completion: nil)
    }
    
    // Method to close the alert
    @objc func dismissOnTapOutside() {
       self.dismiss(animated: true, completion: nil)
    }
    
    private func exitWithMsg(Message msg: String?) {
        if let msg = msg {
            print("[Error] " + msg)
        }
        exit(1)
    }
    
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
        
    // Fonction qui retourne le nombre d'éléments à afficher par section
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

    // Fonction appelée pour créer une case et la remplir
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cat = self.getAllCategories()[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCellIdentifier", for: indexPath) as! CategoryCell
        cell._title?.text = cat.name
        cell._time?.text = "\(String(format: "%.2f", 0))s"
        
        return cell
    }
    
    
}
