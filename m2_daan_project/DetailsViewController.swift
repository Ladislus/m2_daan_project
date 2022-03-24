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
    
    @IBAction func addTimer() {
        let alert = UIAlertController(title: "Ajouter un timer", message: "Veuillez entrer le nom du timer que vous voulez ajouter", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Ajouter", style: . default) { (action) in
            // Code qui dit ce qui se passe qd on clique sur le bouton Add
            if textField.text != .some("") && textField.text != .none {
                let newTimer = Timer(context: self._context)
                newTimer.name = textField.text
                newTimer.category = self.category
            
                do {
                    try self._context.save()
                    print("Saved timer: '" + newTimer.name! + "'")
                } catch {
                    print("Can't save: \(error)")
                }
            } else {
                let errorAlert = UIAlertController(title: "Erreur de sauvegarde", message: "Il faut renseigner un nom pour le nouveau timer", preferredStyle: .alert)
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
        return self.category.timers?.count ?? 0
    }
    
    // Fonction appelée pour créer une case et la remplir
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timer = self.category.timers![indexPath.row] as! Timer
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCellIdentifier", for: indexPath) as! TimerCell
        cell._title?.text = timer.name
        cell._time?.text = "\(String(format: "%.2f", timer.time))s"
        
        return cell
    }
    
    // Suppression d'une cellule
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let timer = self.category.timers![indexPath.row] as! Timer
            timer.category = nil
            
            print("Timer '\(timer.name!)' supprimée !")
            
            self._context.delete(timer)
            self._tableview.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
