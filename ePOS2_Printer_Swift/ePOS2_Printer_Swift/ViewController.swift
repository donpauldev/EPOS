//
//  ViewController.swift
//  ViewController
//
//  Created by DON PAUL PM  on 16/08/17.
//  Copyright © 2017 DonPaulPM. All rights reserved.
//

// EPOS Epson printer

import UIKit

class ViewController: UIViewController, DiscoveryViewDelegate, CustomPickerViewDelegate, Epos2PtrReceiveDelegate {
    let PAGE_AREA_HEIGHT: Int = 500
    let PAGE_AREA_WIDTH: Int = 500
    let FONT_A_HEIGHT: Int = 24
    let FONT_A_WIDTH: Int = 12
    let BARCODE_HEIGHT_POS: Int = 70
    let BARCODE_WIDTH_POS: Int = 110
    
    @IBOutlet weak var buttonDiscovery: UIButton!
    @IBOutlet weak var buttonLang: UIButton!
    @IBOutlet weak var buttonPrinterSeries: UIButton!
    @IBOutlet weak var buttonReceipt: UIButton!
    @IBOutlet weak var buttonCoupon: UIButton!
    @IBOutlet weak var textWarnings: UITextView!
    @IBOutlet weak var textTarget: UITextField!

    var printerList: CustomPickerDataSource?
    var langList: CustomPickerDataSource?
    
    var printerPicker: CustomPickerView?
    var langPicker: CustomPickerView?
    
    var printer: Epos2Printer?
    
    var valuePrinterSeries: Epos2PrinterSeries = EPOS2_TM_M10
    var valuePrinterModel: Epos2ModelLang = EPOS2_MODEL_ANK
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        printerList = CustomPickerDataSource()
        printerList!.addItem(NSLocalizedString("printerseries_m10", comment:""), value: EPOS2_TM_M10)
        printerList!.addItem(NSLocalizedString("printerseries_m30", comment:""), value: EPOS2_TM_M30)
        printerList!.addItem(NSLocalizedString("printerseries_p20", comment:""), value: EPOS2_TM_P20)
        printerList!.addItem(NSLocalizedString("printerseries_p60", comment:""), value: EPOS2_TM_P60)
        printerList!.addItem(NSLocalizedString("printerseries_p60ii", comment:""), value: EPOS2_TM_P60II)
        printerList!.addItem(NSLocalizedString("printerseries_P80", comment:""), value: EPOS2_TM_P80)
        printerList!.addItem(NSLocalizedString("printerseries_t20", comment:""), value: EPOS2_TM_T20)
        printerList!.addItem(NSLocalizedString("printerseries_t60", comment:""), value: EPOS2_TM_T60)
        printerList!.addItem(NSLocalizedString("printerseries_t70", comment:""), value: EPOS2_TM_T70)
        printerList!.addItem(NSLocalizedString("printerseries_t81", comment:""), value: EPOS2_TM_T81)
        printerList!.addItem(NSLocalizedString("printerseries_t82", comment:""), value: EPOS2_TM_T82)
        printerList!.addItem(NSLocalizedString("printerseries_t83", comment:""), value: EPOS2_TM_T83)
        printerList!.addItem(NSLocalizedString("printerseries_t88", comment:""), value: EPOS2_TM_T88)
        printerList!.addItem(NSLocalizedString("printerseries_t90", comment:""), value: EPOS2_TM_T90)
        printerList!.addItem(NSLocalizedString("printerseries_t90kp", comment:""), value: EPOS2_TM_T90KP)
        printerList!.addItem(NSLocalizedString("printerseries_u220", comment:""), value: EPOS2_TM_U220)
        printerList!.addItem(NSLocalizedString("printerseries_u330", comment:""), value: EPOS2_TM_U330)
        printerList!.addItem(NSLocalizedString("printerseries_l90", comment:""), value: EPOS2_TM_L90)
        printerList!.addItem(NSLocalizedString("printerseries_h6000", comment:""), value: EPOS2_TM_H6000)

        langList = CustomPickerDataSource()
        langList!.addItem(NSLocalizedString("language_ank", comment:""), value: EPOS2_MODEL_ANK)
        langList!.addItem(NSLocalizedString("language_japanese", comment:""), value: EPOS2_MODEL_JAPANESE)
        langList!.addItem(NSLocalizedString("language_chinese", comment:""), value: EPOS2_MODEL_CHINESE)
        langList!.addItem(NSLocalizedString("language_taiwan", comment:""), value: EPOS2_MODEL_TAIWAN)
        langList!.addItem(NSLocalizedString("language_korean", comment:""), value: EPOS2_MODEL_KOREAN)
        langList!.addItem(NSLocalizedString("language_thai", comment:""), value: EPOS2_MODEL_THAI)
        langList!.addItem(NSLocalizedString("language_southasia", comment:""), value: EPOS2_MODEL_SOUTHASIA)
        
        printerPicker = CustomPickerView()
        langPicker = CustomPickerView()
        let window = UIApplication.shared.keyWindow
        if (window != nil) {
            window!.addSubview(printerPicker!)
            window!.addSubview(langPicker!)
        }
        else{
            self.view.addSubview(printerPicker!)
            self.view.addSubview(langPicker!)
        }
        printerPicker!.delegate = self
        langPicker!.delegate = self
        
        printerPicker!.dataSource = printerList
        langPicker!.dataSource = langList
        
        valuePrinterSeries = printerList!.valueItem(0) as! Epos2PrinterSeries
        buttonPrinterSeries.setTitle(printerList!.textItem(0), for:UIControlState())
        valuePrinterModel = langList!.valueItem(0) as! Epos2ModelLang
        buttonLang.setTitle(langList!.textItem(0), for:UIControlState())
        
        setDoneToolbar()
        
        let result = Epos2Log.setLogSettings(EPOS2_PERIOD_TEMPORARY.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:nil, port:0, logSize:1, logLevel:EPOS2_LOGLEVEL_LOW.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method: "setLogSettings")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDoneToolbar() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        doneToolbar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.flexibleSpace, target:self, action:nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.done, target:self, action:#selector(ViewController.doneKeyboard(_:)))
        
        doneToolbar.setItems([space, doneButton], animated:true)
        textTarget.inputAccessoryView = doneToolbar
    }
    
    func doneKeyboard(_ sender: AnyObject) {
        textTarget.resignFirstResponder()
    }

    @IBAction func didTouchUpInside(_ sender: AnyObject) {
        textTarget.resignFirstResponder()
        
        switch sender.tag {
        case 1:
            printerPicker!.showPicker()
        case 2:
            langPicker!.showPicker()
        case 3:
            updateButtonState(false)
            if !runPrinterReceiptSequence() {
                updateButtonState(true)
            }
            break
        case 4:
            updateButtonState(false)
            if !runPrinterCouponSequence() {
                updateButtonState(true)
            }
            break
        default:
            break
        }
    }
    
    func customPickerView(_ pickerView: CustomPickerView, didSelectItem text: String, itemValue value: Any) {
        if pickerView == printerPicker {
            self.buttonPrinterSeries.setTitle(text, for:UIControlState())
            self.valuePrinterSeries = value as! Epos2PrinterSeries
        }
        if pickerView == langPicker {
            self.buttonLang.setTitle(text, for:UIControlState())
            self.valuePrinterModel = value as! Epos2ModelLang
        }
    }
    
    func updateButtonState(_ state: Bool) {
        buttonDiscovery.isEnabled = state
        buttonLang.isEnabled = state
        buttonPrinterSeries.isEnabled = state
        buttonReceipt.isEnabled = state
        buttonCoupon.isEnabled = state
        
    }
    
    func runPrinterReceiptSequence() -> Bool {
        textWarnings.text = ""
        
        if !initializePrinterObject() {
            return false
        }
        
        if !createReceiptData() {
            finalizePrinterObject()
            return false
        }
        
        if !printData() {
            finalizePrinterObject()
            return false
        }
        
        return true
    }
    
    func runPrinterCouponSequence() -> Bool {
        textWarnings.text = ""
        
        if !initializePrinterObject() {
            return false
        }
        
        if !createCouponData() {
            finalizePrinterObject()
            return false
        }
        
        if !printData() {
            finalizePrinterObject()
            return false
        }
        
        return true
    }
    
    func createReceiptData() -> Bool {
        let barcodeWidth = 2
        let barcodeHeight = 100
        
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
        let logoData = UIImage(named: "store")
        
        if logoData == nil {
            return false
        }

        result = printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        
        result = printer!.add(logoData, x: 0, y:0,
            width:Int(logoData!.size.width),
            height:Int(logoData!.size.height),
            color:EPOS2_COLOR_1.rawValue,
            mode:EPOS2_MODE_MONO.rawValue,
            halftone:EPOS2_HALFTONE_DITHER.rawValue,
            brightness:Double(EPOS2_PARAM_DEFAULT),
            compress:EPOS2_COMPRESS_AUTO.rawValue)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }

        // Section 1 : Store information
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        textData.append("THE STORE 123 (555) 555 – 5555\n")
        textData.append("STORE DIRECTOR – John Smith\n")
        textData.append("\n")
        textData.append("7/01/07 16:58 6153 05 0191 134\n")
        textData.append("ST# 21 OP# 001 TE# 01 TR# 747\n")
        textData.append("------------------------------\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append("400 OHEIDA 3PK SPRINGF  9.99 R\n")
        textData.append("410 3 CUP BLK TEAPOT    9.99 R\n")
        textData.append("445 EMERIL GRIDDLE/PAN 17.99 R\n")
        textData.append("438 CANDYMAKER ASSORT   4.99 R\n")
        textData.append("474 TRIPOD              8.99 R\n")
        textData.append("433 BLK LOGO PRNTED ZO  7.99 R\n")
        textData.append("458 AQUA MICROTERRY SC  6.99 R\n")
        textData.append("493 30L BLK FF DRESS   16.99 R\n")
        textData.append("407 LEVITATING DESKTOP  7.99 R\n")
        textData.append("441 **Blue Overprint P  2.99 R\n")
        textData.append("476 REPOSE 4PCPM CHOC   5.49 R\n")
        textData.append("461 WESTGATE BLACK 25  59.99 R\n")
        textData.append("------------------------------\n")
        
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")

        
        // Section 3 : Payment infomation
        textData.append("SUBTOTAL                160.38\n");
        textData.append("TAX                      14.43\n");
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        result = printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = printer!.addText("TOTAL    174.81\n")
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        
        result = printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false;
        }
        
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        
        textData.append("CASH                    200.00\n")
        textData.append("CHANGE                   25.19\n")
        textData.append("------------------------------\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append("Purchased item total number\n")
        textData.append("Sign Up and Save !\n")
        textData.append("With Preferred Saving Card\n")
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        result = printer!.addBarcode("01209457",
            type:EPOS2_BARCODE_CODE39.rawValue,
            hri:EPOS2_HRI_BELOW.rawValue,
            font:EPOS2_FONT_A.rawValue,
            width:barcodeWidth,
            height:barcodeHeight)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addBarcode")
            return false
        }
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    func createCouponData() -> Bool {
        let barcodeWidth = 2
        let barcodeHeight = 64
        
        var result = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return false
        }
        
        let coffeeData = UIImage(named: "coffee")
        let wmarkData = UIImage(named: "wmark")
        
        if coffeeData == nil || wmarkData == nil {
            return false
        }
        
        result = printer!.addPageBegin()
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPageBegin")
            return false
        }
        
        result = printer!.addPageArea(0, y:0, width:PAGE_AREA_WIDTH, height:PAGE_AREA_HEIGHT)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPageArea")
            return false
        }
        
        result = printer!.addPageDirection(EPOS2_DIRECTION_TOP_TO_BOTTOM.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPageDirection")
            return false
        }
        
        result = printer!.addPagePosition(0, y:Int(coffeeData!.size.height))
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPagePosition")
            return false
        }
        
        result = printer!.add(coffeeData, x:0, y:0,
            width:Int(coffeeData!.size.width),
            height:Int(coffeeData!.size.height),
            color:EPOS2_PARAM_DEFAULT,
            mode:EPOS2_PARAM_DEFAULT,
            halftone:EPOS2_PARAM_DEFAULT,
            brightness:3,
            compress:EPOS2_PARAM_DEFAULT)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }
        
        result = printer!.addPagePosition(0, y:Int(wmarkData!.size.height))
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPagePosition")
            return false
        }
        
        result = printer!.add(wmarkData, x:0, y:0,
            width:Int(wmarkData!.size.width),
            height:Int(wmarkData!.size.height),
            color:EPOS2_PARAM_DEFAULT,
            mode:EPOS2_PARAM_DEFAULT,
            halftone:EPOS2_PARAM_DEFAULT,
            brightness:Double(EPOS2_PARAM_DEFAULT),
            compress:EPOS2_PARAM_DEFAULT)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }
        
        result = printer!.addPagePosition(FONT_A_WIDTH * 4, y:(PAGE_AREA_HEIGHT / 2) - (FONT_A_HEIGHT * 2))
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPagePosition")
            return false
        }
        
        result = printer!.addTextSize(3, height:3)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = printer!.addTextStyle(EPOS2_PARAM_DEFAULT, ul:EPOS2_PARAM_DEFAULT, em:EPOS2_TRUE, color:EPOS2_PARAM_DEFAULT)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextStyle")
            return false
        }
        
        result = printer!.addTextSmooth(EPOS2_TRUE)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSmooth")
            return false
        }
        
        result = printer!.addText("FREE Coffee\n")
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        
        result = printer!.addPagePosition((PAGE_AREA_WIDTH / barcodeWidth) - BARCODE_WIDTH_POS, y:Int(coffeeData!.size.height) + BARCODE_HEIGHT_POS)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPagePosition")
            return false
        }
        
        result = printer!.addBarcode("01234567890", type:EPOS2_BARCODE_UPC_A.rawValue, hri:EPOS2_PARAM_DEFAULT, font: EPOS2_PARAM_DEFAULT, width:barcodeWidth, height:barcodeHeight)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addBarcode")
            return false
        }
        
        result = printer!.addPageEnd()
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPageEnd")
            return false
        }
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    func printData() -> Bool {
        var status: Epos2PrinterStatusInfo?

        if printer == nil {
            return false
        }
        
        if !connectPrinter() {
            return false
        }
        
        status = printer!.getStatus()
        dispPrinterWarnings(status)
        
        if !isPrintable(status) {
            MessageView.show(makeErrorMessage(status))
            printer!.disconnect()
            return false
        }
        
        let result = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"sendData")
            printer!.disconnect()
            return false
        }
        
        return true
    }

    func initializePrinterObject() -> Bool {
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue, lang: valuePrinterModel.rawValue)
        
        if printer == nil {
            return false
        }
        printer!.setReceiveEventDelegate(self)
        
        return true
    }
    
    func finalizePrinterObject() {
        if printer == nil {
            return
        }
        
        printer!.clearCommandBuffer()
        printer!.setReceiveEventDelegate(nil)
        printer = nil
    }
    
    func connectPrinter() -> Bool {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return false
        }
        
        result = printer!.connect(textTarget.text, timeout:Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"connect")
            return false
        }
        
        result = printer!.beginTransaction()
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"beginTransaction")
            printer!.disconnect()
            return false

        }
        return true
    }
    
    func disconnectPrinter() {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return
        }
        
        result = printer!.endTransaction()
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                MessageView.showErrorEpos(result, method:"endTransaction")
            })
        }
        
        result = printer!.disconnect()
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                MessageView.showErrorEpos(result, method:"disconnect")
            })
        }
        
        finalizePrinterObject()
    }
    func isPrintable(_ status: Epos2PrinterStatusInfo?) -> Bool {
        if status == nil {
            return false
        }
        
        if status!.connection == EPOS2_FALSE {
            return false
        }
        else if status!.online == EPOS2_FALSE {
            return false
        }
        else {
            // print available
        }
        return true
    }
    
    func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        MessageView.showResult(code, errMessage: makeErrorMessage(status))
        
        dispPrinterWarnings(status)
        updateButtonState(true)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.disconnectPrinter()
            })
    }
    
    func dispPrinterWarnings(_ status: Epos2PrinterStatusInfo?) {
        if status == nil {
            return
        }
        
        textWarnings.text = ""
        
        if status!.paper == EPOS2_PAPER_NEAR_END.rawValue {
            textWarnings.text = NSLocalizedString("warn_receipt_near_end", comment:"")
        }
        
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_1.rawValue {
            textWarnings.text = NSLocalizedString("warn_battery_near_end", comment:"")
        }
    }

    func makeErrorMessage(_ status: Epos2PrinterStatusInfo?) -> String {
        let errMsg = NSMutableString()
        if status == nil {
            return ""
        }
    
        if status!.online == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_offline", comment:""))
        }
        if status!.connection == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_no_response", comment:""))
        }
        if status!.coverOpen == EPOS2_TRUE {
            errMsg.append(NSLocalizedString("err_cover_open", comment:""))
        }
        if status!.paper == EPOS2_PAPER_EMPTY.rawValue {
            errMsg.append(NSLocalizedString("err_receipt_end", comment:""))
        }
        if status!.paperFeed == EPOS2_TRUE || status!.panelSwitch == EPOS2_SWITCH_ON.rawValue {
            errMsg.append(NSLocalizedString("err_paper_feed", comment:""))
        }
        if status!.errorStatus == EPOS2_MECHANICAL_ERR.rawValue || status!.errorStatus == EPOS2_AUTOCUTTER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_autocutter", comment:""))
            errMsg.append(NSLocalizedString("err_need_recover", comment:""))
        }
        if status!.errorStatus == EPOS2_UNRECOVER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_unrecover", comment:""))
        }
    
        if status!.errorStatus == EPOS2_AUTORECOVER_ERR.rawValue {
            if status!.autoRecoverError == EPOS2_HEAD_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_head", comment:""))
            }
            if status!.autoRecoverError == EPOS2_MOTOR_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_motor", comment:""))
            }
            if status!.autoRecoverError == EPOS2_BATTERY_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_battery", comment:""))
            }
            if status!.autoRecoverError == EPOS2_WRONG_PAPER.rawValue {
                errMsg.append(NSLocalizedString("err_wrong_paper", comment:""))
            }
        }
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_0.rawValue {
            errMsg.append(NSLocalizedString("err_battery_real_end", comment:""))
        }
    
        return errMsg as String
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DiscoveryView" {
            let view: DiscoveryViewController? = segue.destination as? DiscoveryViewController
            view?.delegate = self
        }
    }
    func discoveryView(_ sendor: DiscoveryViewController, onSelectPrinterTarget target: String) {
        textTarget.text = target
    }
}

