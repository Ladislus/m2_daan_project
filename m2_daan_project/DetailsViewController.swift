import UIKit
import CoreData

class DetailsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var _tableview: UITableView!
    @IBOutlet weak var _title: UILabel!
    var category: Category!
    let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._tableview.dataSource = self
        self._title.text = self.category.name
    }
    
    @IBAction func addChrono() {
        let alert = UIAlertController(title: "Ajouter un chrono", message: "Veuillez entrer le nom du chrono que vous voulez ajouter", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Ajouter", style: . default) { (action) in
            // Code qui dit ce qui se passe qd on clique sur le bouton Add
            if textField.text != .some("") && textField.text != .none {
                let newChrono = Chrono(context: self._context)
                newChrono.name = textField.text
                newChrono.category = self.category
            
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
        
        present(alert, animated: true, completion: nil)
    }
    
    // Method to close the alert
    @objc func dismissOnTapOutside() {
       self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.category.chronos?.count ?? 0
    }
    
    // Fonction appelée pour créer une case et la remplir
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
    
    // Suppression d'une cellule
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let cell = tableView.cellForRow(at: indexPath) as! ChronoCell
            cell._timer.invalidate()
            
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
