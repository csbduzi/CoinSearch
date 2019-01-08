//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Empire on 2019-01-06.
//  Copyright © 2019 Empire. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbol = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var finalURL = ""
    var currencySelected = ""
    

    @IBOutlet weak var cryptoName: UILabel!
    @IBOutlet weak var cryptoPrice: UILabel!
    @IBOutlet weak var changePercentage: UILabel!
    @IBOutlet weak var volumeNb: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    let cryptoDataModel  = CryptoDataModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    // number of title for the rows
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
  
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        finalURL = baseURL + currencyArray[row]
        currencySelected = currencySymbol[row]
        getCryptoData(url: finalURL)
        
    

        
    }
    
    // MARK: - Network
    /***************************************************************/
    
    //the getCryptoData() method
    
    // using AlamoFire for out http request -> request method
    
    func getCryptoData (url: String){
        Alamofire.request(url, method: .get).responseJSON{
        response in
        if(response.result.isSuccess){
            print ("Success! Got the crypto data")
            
            // passing the JSON value into our JSON object
            let cryptoJSON : JSON = JSON (response.result.value!)
            // updating our crypto data
            self.updateCryptoData(json: cryptoJSON )
            
            
            
        }else{
            print("Error: \(response.result.error)")
            self.cryptoPrice.text = "Connection Issues"
           
            
        }
    }
    }
    
    // MARK: - JSON Parsing
    /***************************************************************/
    
    func updateCryptoData (json: JSON){
        
        // condition to make sure the values are not nil
        if let priceResult = json["averages"]["day"].double{
            cryptoDataModel.cryptoPrice = priceResult
            cryptoDataModel.changePercentage = json["changes"]["percent"]["day"].doubleValue
            //cryptoDataModel.marketCap = json[""]
            // rounding the Double value to a precision of 2 digits
            let volume_nb = json ["volume"].doubleValue
            let rounded_volume_nb = Double(round(100 * volume_nb)/100)
            cryptoDataModel.volume = rounded_volume_nb
            let symbolName =  json ["display_symbol"].stringValue
            cryptoDataModel.cryptoName = symbolName
            updateUICryptoData()
            print("Success! The crypto model has been updated!")
            
        }
        else{
            cryptoName.text = "Coin Unavailable"
            cryptoPrice.text = "Price Unavailable"
            marketCap.text = "Unavailable"
            volumeNb.text = "Unavailable"
            changePercentage.text = "Unavailable"
            
            
        }
    }

    
    // MARK: -  UI Updates
    /***************************************************************/

    func updateUICryptoData (){
        
        //cryptoName.text = cryptoDataModel.cryptoName
        cryptoPrice.text = "\(currencySelected)\(cryptoDataModel.cryptoPrice)"
        //marketCap.text = "\(currencySelected)\(cryptoDataModel.marketCap)"
        volumeNb.text = "\(currencySelected)\(cryptoDataModel.volume)"
        changePercentage.text = "\(currencySelected)\(cryptoDataModel.changePercentage)"
        print("Success! The UI got successfully updated!")
    }
    
    // MARK: -  Search Entered Crypto Name
    /***************************************************************/
    
    /*func enteredCryptoName(name : String) -> String{
        let finalURL = baseURL + name + curr_symbol
        return finalURL
    }
    
    // action of the search button pressed
    
    @IBAction func btnPressed(_ sender: Any) {
        let entered_name = searchBar.text
        if(entered_name != nil){
        finalURL = enteredCryptoName(name: entered_name!)
        }
    }*/
}

