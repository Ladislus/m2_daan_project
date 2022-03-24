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
            
            print("Timer '\(timer.name!)' supprimée !")
            
            self._context.delete(timer)
            self._tableview.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}
