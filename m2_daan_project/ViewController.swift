import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var _tableview: UITableView!
    let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._tableview.dataSource = self
        self._tableview.delegate = self
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
        cell._time?.text = secondsToString(TimeInSeconds: 0)
        cell._category = cat
        cell.start()
        
        return cell
    }
    
    // Suppression d'une cellule
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
            cell._timer.invalidate()
    
            let cat = cell._category!
            
            print("Categorie '\(cat.name!)' supprimée !")
            
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
        // Sélectionner le Main Storyboard
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cat = self.getAllCategories()[indexPath.row]
        print("Catégorie \(cat.name!) cliquée")
        // Sélectionner dedans le controleur DetailViewController à l'aide de son identifiant DetailCV telqu'installé dans l'inspecteur des propriétés (rubrique Identity, Storyboard ID)
        let DvC = Storyboard.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        // Retirer le visuel de sélection de la cellule (désactiver zone grise)
        tableView.deselectRow(at: indexPath, animated: true)
        // Remplir les données de l'objet DetailViewController
        DvC.category = cat
        // Empiler le DetailViewController sur le NavigationController qui englobe la vue qui contient la TableView
        self.navigationController?.pushViewController(DvC, animated: true)
    }
}
