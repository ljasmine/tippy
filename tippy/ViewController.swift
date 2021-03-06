//
//  ViewController.swift
//  tippy
//
//  Created by jasmine_lee on 10/11/16.
//  Copyright © 2016 jasmine_lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipSlider: UISlider!
    @IBOutlet weak var timeControl: UISegmentedControl!
    
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var billText: UILabel!
    @IBOutlet weak var percentTipText: UILabel!
    @IBOutlet weak var suggestedText: UILabel!
    @IBOutlet weak var totalText: UILabel!
    @IBOutlet weak var tipText: UILabel!
    
    let step: Float = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make bill field the focus and bring up keyboard
        billField.becomeFirstResponder()
        
        let defaults = UserDefaults.standard
        let defaultTipPercentage = defaults.float(forKey: "tipPercentage")
        let darkOn = defaults.bool(forKey: "darkDefault")
        
        if darkOn {
            darkTheme()
        } else {
            lightTheme()
        }
        
        // check if there is a saved bill amount
        billField.text = getBillAmount()

        tipSlider.value = defaultTipPercentage
        percentageLabel.text = String(format:"%.0f", tipSlider.value * 100) + "%"
        timeControl.selectedSegmentIndex = -1
        
        // update calculation based on stored values
        calculateTip(self)
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        
        // Set the label text to the value of the slider as it changes
        let roundedValue = round(tipSlider.value / step) * step
        tipSlider.value = roundedValue
        percentageLabel.text = String(format:"%.0f", roundedValue * 100) + "%"
        
        // update tip and total
        calculateTip(self)
    }
    
    @IBAction func calculateTip(_ sender: AnyObject) {
        
        let bill = Double(billField.text!) ?? 0
        let tip = bill * Double(tipSlider.value)
        let total = bill + tip
        
        let tipLocale = tip as NSNumber
        let totalLocale = total as NSNumber
        
        // display the tip and total bill amount in current locale
        // using the thousands separator
        tipLabel.text = convertToLocale(price: tipLocale)
        totalLabel.text = convertToLocale(price: totalLocale)
        
        // write the updated bill amount and new timestamp to database
        let defaults = UserDefaults.standard
        defaults.set(billField.text! as String, forKey: "billAmount")
        defaults.set(NSDate(), forKey: "billSavedTimeStamp")
        
        addTipAnimation()
        addTotalAnimation()
    }
    
    func addTipAnimation() {
        self.totalLabel.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.totalLabel.alpha = 1
            }, completion: nil)
    }
    
    func addTotalAnimation() {
        self.tipLabel.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.tipLabel.alpha = 1
            }, completion: nil)
    }
    
    @IBAction func calculateMealSpecificTip(_ sender: AnyObject) {
        
        let defaults = UserDefaults.standard
        
        // retrieve lunch and dinner tip percentages
        // from database
        let lunchTip = defaults.float(forKey: "lunchTip")
        let dinnerTip = defaults.float(forKey: "dinnerTip")
        
        let percentagesArray = [lunchTip, dinnerTip]
        let index = timeControl.selectedSegmentIndex
        var tipPercent = tipSlider.value
        if index >= 0 {
            tipPercent = Float(percentagesArray[index])
            tipSlider.value = tipPercent
            percentageLabel.text = String(format:"%.0f", tipPercent * 100) + "%"
            calculateTip(self)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    func lightTheme() {
        self.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        tipLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        percentageLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        totalLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        billText.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        percentTipText.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        suggestedText.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tipText.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        totalText.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
    }
    
    func darkTheme() {
        self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        tipLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        percentageLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        totalLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        billText.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        percentTipText.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        suggestedText.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tipText.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        totalText.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func convertToLocale(price: NSNumber) -> String {
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: price)!
    }
    
    func getBillAmount() -> String {
        
        let defaults = UserDefaults.standard
        let currentTime = NSDate()
        let billAmount = defaults.string(forKey: "billAmount")
        let timestamp = defaults.object(forKey: "billSavedTimeStamp") as! Date?
        
        // check if it's been more than 10 min since the last timestamp
        if (timestamp == nil || currentTime.timeIntervalSince(timestamp!) > TimeInterval(600)) {
            return ""
        } else {
            return billAmount!
        }
    }

}

