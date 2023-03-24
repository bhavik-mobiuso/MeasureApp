//
//  SettingViewController.swift
//  MeasureDemo
//
//  Created by Bhavik on 22/03/23.
//

import UIKit


enum userSettings: String {
    case unit
    case isAngleMeasurement
    case noOfAngle
}

protocol Setting: AnyObject {
    func settings(measurementUnit: DistanceUnit, isAngleMeasurement: Bool, noOfAngles: Int)
}

class SettingViewController: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var unitPicker: UIPickerView!
    @IBOutlet weak var angleEnable: UISwitch!
    @IBOutlet weak var plusAngleBtn: UIButton!
    @IBOutlet weak var minusAngleBtn: UIButton!
    @IBOutlet weak var noOfAngleLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    weak var  settigDelegate: Setting? = nil
    let unitPickerData: [DistanceUnit] = [.centimeter, .meter,.inch,.foot]
    var measureInUnit: DistanceUnit = .meter
    var enableAngle: Bool = false
    var noOfAngle: Int = 1
    let userDefault = UserDefaults.standard
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
}
extension SettingViewController {
    func setUp() {
        
        //centerview
        
        popupView.layer.cornerRadius = 10
        
        // set button target
        
        closeBtn.addTarget(self, action: #selector(closeBtnTap), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelBtnTap), for: .touchUpInside)
        applyBtn.addTarget(self, action: #selector(applyBtnTap), for: .touchUpInside)
        
        
        applyBtn.isEnabled = false
        applyBtn.isHighlighted = true
        
        
        // set unit picker
        
        
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        // MARK: - Angle measurements settings
        
        angleEnable.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        plusAngleBtn.addTarget(self, action: #selector(plusAngleBtnTap), for: .touchUpInside)
        minusAngleBtn.addTarget(self, action: #selector(minusAngleBtnTap), for: .touchUpInside)
        plusAngleBtn.layer.cornerRadius = 5
        minusAngleBtn.layer.cornerRadius = 5
     
        initiateSettings()
    }
}

//MARK: - Setting - Actions

extension SettingViewController {
    
    @objc func closeBtnTap() {
        self.dismiss(animated: true)
    }
    
    @objc func cancelBtnTap() {
        self.dismiss(animated: true)
    }
    
    @objc func applyBtnTap() {

        self.updateSettings()
        self.dismiss(animated: true)
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        self.applyBtn.isEnabled = true
        self.applyBtn.isHighlighted = false
        enableAngle = value
        buttonMode(value: value)
    }
    
    @objc func plusAngleBtnTap() {
        
        if noOfAngle < 10 {
            noOfAngle += 1
            DispatchQueue.main.async {
                self.noOfAngleLbl.text = "\(self.noOfAngle)"
                self.applyBtn.isEnabled = true
                self.applyBtn.isHighlighted = false
            }
            
        }
        else {
            print("Angle Maximum limit exceeds")
        }
        
    }
    
    @objc func minusAngleBtnTap() {
        if noOfAngle > 1 {
            noOfAngle -= 1
            DispatchQueue.main.async {
                self.noOfAngleLbl.text = "\(self.noOfAngle)"
                self.applyBtn.isEnabled = true
                self.applyBtn.isHighlighted = false
            }
        }
    }
    
    func buttonMode(value: Bool = false) {
        noOfAngleLbl.isHighlighted = !value
        plusAngleBtn.isHighlighted = !value
        plusAngleBtn.isEnabled = value
        minusAngleBtn.isHighlighted = !value
        minusAngleBtn.isEnabled = value
    }
    
    func setDefaultValue(item: DistanceUnit, inComponent: Int){
        if let indexPosition = unitPickerData.firstIndex(of: item){
            unitPicker.selectRow(indexPosition, inComponent: inComponent, animated: true)
        }
    }
    
    func updateSettings() {
        
       self.userDefault.set(self.enableAngle, forKey: userSettings.isAngleMeasurement.rawValue)
       self.userDefault.set(measureInUnit.unit, forKey: userSettings.unit.rawValue)
       self.userDefault.set(self.noOfAngle, forKey: userSettings.noOfAngle.rawValue)
        
        
       settigDelegate?.settings(measurementUnit: self.measureInUnit, isAngleMeasurement: self.enableAngle, noOfAngles: noOfAngle)
        
    }
    
    func initiateSettings() {
        let units = userDefault.value(forKey: userSettings.unit.rawValue)
        let isAngleMeasurement = userDefault.value(forKey: userSettings.isAngleMeasurement.rawValue)
        
        let noOfAngles = userDefault.value(forKey: userSettings.noOfAngle.rawValue)
        
        for unit in unitPickerData {
            if unit.unit == units as! String {
                setDefaultValue(item: unit, inComponent: 0)
                self.measureInUnit = unit
             
            }
        }
        angleEnable.isOn = (isAngleMeasurement as! Bool)
        buttonMode(value: (isAngleMeasurement as! Bool)) // set plus minus button default value
        noOfAngleLbl.text = "\(noOfAngles as! Int)"
        
        self.enableAngle = isAngleMeasurement as! Bool
        self.noOfAngle = noOfAngles as! Int
    }
}

// PickerView Delegate methods

extension SettingViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitPickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(unitPickerData[row])"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.measureInUnit = unitPickerData[row]
        self.applyBtn.isEnabled = true
        self.applyBtn.isHighlighted = false
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 14)
            pickerLabel?.font = .boldSystemFont(ofSize: 14.0)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = "\(unitPickerData[row])"
        pickerLabel?.textColor = UIColor.systemBlue

        return pickerLabel!
    }
}
