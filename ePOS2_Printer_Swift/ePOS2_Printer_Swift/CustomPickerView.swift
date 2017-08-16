import UIKit

public protocol CustomPickerViewDelegate {
    func customPickerView(_ pickerView: CustomPickerView, didSelectItem text: String, itemValue value: Any) -> Void
}

open class CustomPickerDataSource {
    fileprivate var textItems: [String] = []
    fileprivate var valueItems: [Any] = []
    
    var count: Int {
        return textItems.count
    }
    open func addItem(_ text: String, value: Any) {
        textItems.append(text)
        valueItems.append(value)
    }
    func textItem(_ index: Int) -> String {
        return textItems[index]
    }
    func valueItem(_ index: Int) -> Any {
        return valueItems[index]
    }
}

open class CustomPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    fileprivate var backView:UIView!
    fileprivate var baseView:UIView!
    fileprivate var pickerView: UIPickerView!
    fileprivate var toolBar: UIToolbar!
    fileprivate var toolBarItems: [UIBarButtonItem]!
    
    open var dataSource: CustomPickerDataSource? {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    open var delegate: CustomPickerViewDelegate!
    
    convenience public init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializePicker()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializePicker()
    }
    
    fileprivate func initializePicker() {
        pickerView = UIPickerView()
        toolBar = UIToolbar()
        baseView = UIView()
        backView = UIView()
        toolBarItems = []
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        toolBar.isTranslucent = true
        
        let screenSize = UIScreen.main.bounds.size
        let pickerHeight = screenSize.height / 3
        let toolbarHeight:CGFloat = 44
        
        baseView.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: pickerHeight)
        baseView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: pickerHeight)
        pickerView.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: pickerHeight - toolbarHeight)
        pickerView.frame = CGRect(x: 0, y: 44, width: screenSize.width, height: pickerHeight - toolbarHeight)
        toolBar.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: toolbarHeight)
        toolBar.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: toolbarHeight)
        toolBar.sizeToFit()
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target:self, action:#selector(CustomPickerView.didTouchDone))
        toolBarItems! += [space, doneButtonItem]
        
        baseView.backgroundColor = UIColor.white
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.setItems(toolBarItems, animated: true)
        baseView.addSubview(toolBar)
        baseView.addSubview(pickerView)
        
        self.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        self.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        backView.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        backView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        backView.backgroundColor = UIColor.gray
        backView.alpha = 0.5
        
        self.addSubview(backView)
        self.addSubview(baseView)
    }
    open func showPicker() {
        let screenSize = UIScreen.main.bounds.size
        let pickerSize = self.baseView.frame.size

        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        UIView.animate(withDuration: 0.2, animations: {
            self.baseView.frame = CGRect(x: 0, y: screenSize.height - pickerSize.height, width: screenSize.width, height: pickerSize.height)
        }) 
    }
    func didTouchDone() {
        let screenSize = UIScreen.main.bounds.size
        let pickerSize = self.baseView.frame.size
        
        UIView.animate(withDuration: 0.2, delay:0.0, options: UIViewAnimationOptions(), animations:{() -> Void in
                self.baseView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: pickerSize.height)
            }, completion:{(finished: Bool) -> Void in
                self.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
            })
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if dataSource == nil {
            return 0
        }
        return 1
    }
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if dataSource == nil {
            return 0
        }
        return dataSource!.count
    }
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource?.textItem(row)
    }
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dataSource == nil {
            return
        }
        
        delegate?.customPickerView(self, didSelectItem: dataSource!.textItem(row), itemValue: dataSource!.valueItem(row))
    }
    
}
