import UIKit

protocol DiscoveryViewDelegate {
    func discoveryView(_ sendor:DiscoveryViewController, onSelectPrinterTarget target:String)
}

class DiscoveryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Epos2DiscoveryDelegate {
    
    
    @IBOutlet weak var printerView: UITableView!
    
    fileprivate var printerList: [Epos2DeviceInfo] = []
    fileprivate var filterOption: Epos2FilterOption = Epos2FilterOption()
    
    var delegate: DiscoveryViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        
        printerView.delegate = self
        printerView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let result = Epos2Discovery.start(filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            //ShowMsg showErrorEpos(result, method: "start")
        }
        printerView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
            // retry stop function
        }
        
        printerList.removeAll()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowNumber: Int = 0
        if section == 0 {
            rowNumber = printerList.count
        }
        else {
            rowNumber = 1
        }
        return rowNumber
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basis-cell"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
        }
        
        if indexPath.section == 0 {
            if indexPath.row >= 0 && indexPath.row < printerList.count {
                cell!.textLabel?.text = printerList[indexPath.row].deviceName
                cell!.detailTextLabel?.text = printerList[indexPath.row].target
            }
        }
        else {
            cell!.textLabel?.text = "other..."
            cell!.detailTextLabel?.text = ""
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if delegate != nil {
                delegate!.discoveryView(self, onSelectPrinterTarget: printerList[indexPath.row].target)
                delegate = nil
                navigationController?.popToRootViewController(animated: true)
            }
        }
        else {
            performSelector(onMainThread: #selector(DiscoveryViewController.connectDevice), with:self, waitUntilDone:false)
        }

    }
    func connectDevice() {
        Epos2Discovery.stop()
        printerList.removeAll()
        
        let btConnection = Epos2BluetoothConnection()
        let BDAddress = NSMutableString()
        let result = btConnection?.connectDevice(BDAddress)
        if result == EPOS2_SUCCESS.rawValue {
            delegate?.discoveryView(self, onSelectPrinterTarget: BDAddress as String)
            delegate = nil
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            Epos2Discovery.start(filterOption, delegate:self)
            printerView.reloadData()
        }
    }
    @IBAction func restartDiscovery(_ sender: AnyObject) {
        var result = EPOS2_SUCCESS.rawValue;
        
        while true {
            result = Epos2Discovery.stop()
            
            if result != EPOS2_ERR_PROCESSING.rawValue {
                if (result == EPOS2_SUCCESS.rawValue) {
                    break;
                }
                else {
                    MessageView.showErrorEpos(result, method:"stop")
                    return;
                }
            }
        }
        
        printerList.removeAll()
        printerView.reloadData()

        result = Epos2Discovery.start(filterOption, delegate:self)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"start")
        }
    }
    func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        printerList.append(deviceInfo)
        printerView.reloadData()
    }
}
