import UIKit
import CoreBluetooth

class BLECell: UITableViewCell {
    // MARK: - VariablesA
    private var leftColorIndicator: UIView!
    
    var peripheral: Peripheral? {
        didSet{
            self.BLEName.text = peripheral?.peripheral.name
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var BLEImage: UIImageView!
    @IBOutlet weak var BLEName: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    //setup user interface
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor.clear
        self.containerView.backgroundColor = UIColor.lightBlue()
        self.containerView.layer.cornerRadius = 5
        self.containerView.clipsToBounds = true
        self.BLEImage.image = #imageLiteral(resourceName: "robot")
    }
}
