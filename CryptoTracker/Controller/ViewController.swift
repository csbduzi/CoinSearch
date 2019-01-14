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
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/"
    let marketCapURL = "https://apiv2.bitcoinaverage.com/metadata"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbol = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    
    var finalURL = ""
    var currencySelected = ""
    var URLWithSymbolName = ""
    var pickedCurrency : String?
    var entered_name : String?
    let numberFormat = NumberFormatter()

    @IBOutlet weak var cryptoName: UILabel!
    @IBOutlet weak var cryptoPrice: UILabel!
    @IBOutlet weak var changePercentage: UILabel!
    @IBOutlet weak var volumeNb: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var searchButton: UIButton!
    
    let cryptoDataModel  = CryptoDataModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        
        // setting the labels to default
        cryptoName.text = "Coin Symbol"
        cryptoPrice.text = "$0"
        changePercentage.text = "0%"
        volumeNb.text = "$0"
        marketCap.text = "$0"
        
        // rounding the corner of the button
        searchButton.layer.cornerRadius = 5
        
        // default selection of the UIPicker
        pickedCurrency = "AUD"
        currencySelected = "$"
        
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
        pickedCurrency = currencyArray[row]
        return currencyArray[row]
    }
    
    // selection of the row in the currencyPicker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (!(searchBar.text?.isEmpty)!){
            finalURL =  URLWithSymbolName + currencyArray[row]
            currencySelected = currencySymbol[row]
            getMarketCapData(url: marketCapURL)
            getCryptoData(url: finalURL)
        }
    }
    
    // attributes for the rows
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Avenir Medium", size: 17)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = currencyArray[row]
        pickerLabel?.textColor = UIColor.white
        
        return pickerLabel!
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
                self.updateCryptoData(json: cryptoJSON)
            }else{
                print("Error: \(String(describing: response.result.error))")
                self.cryptoPrice.text = "Oops! Try Again."
            }
        }
    }
    
    // the getMarketCapData() method
    
    // using AlamoFire once again for our http request -> request
    
    func getMarketCapData(url: String){
        Alamofire.request(url, method: .get).responseJSON{
            response in
            if (response.result.isSuccess){
                print ("Success! Got the market cap data")
                //passing the JSON value int our JSON object
                let mCapJSON : JSON = JSON (response.result.value!)
                // uddapting our market cap data
                self.updateMarketCapData(json: mCapJSON)
            }
                
            else {
                print("Error: \(String(describing: response.result.error))")
                self.marketCap.text = "Market Cap is unreachable."
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
            cryptoDataModel.volume = json["volume"].intValue
            let symbolName =  json ["display_symbol"].stringValue
            cryptoDataModel.cryptoName = symbolName
            print("Success! The crypto model has been updated!")
            updateUICryptoData()
        }
        else{
            cryptoName.text = "Coin Unavailable"
            cryptoPrice.text = "Price Unavailable"
            marketCap.text = "Unavailable"
            volumeNb.text = "Unavailable"
            changePercentage.text = "Unavailable"
        }
    }
    
    
    func updateMarketCapData (json: JSON){
        
        let marketCapResult  = json[entered_name!]["market_cap"].intValue
        cryptoDataModel.marketCap = marketCapResult
        print("Success! market cap variable of the crypto model has been updated!")
    }
    
    
    // MARK: -  UI Updates
    /***************************************************************/
    
    func updateUICryptoData (){
        
        // number formatrer
        numberFormat.usesGroupingSeparator = true
        numberFormat.numberStyle = .decimal
        
        // substring the of the variable cryptoName to get the symbol only
        var symbolInitials = cryptoDataModel.cryptoName
        symbolInitials = String(symbolInitials.prefix(3))
        cryptoName.text = symbolInitials
        let formatted_price = numberFormat.string(from: cryptoDataModel.cryptoPrice as NSNumber)!
        cryptoPrice.text = "\(currencySelected)\(formatted_price)"
        let formatted_marketCap = numberFormat.string(from: cryptoDataModel.marketCap as NSNumber)!
        marketCap.text = "\(currencySelected)\(formatted_marketCap)"
        let formatted_volumeNb = numberFormat.string(from: cryptoDataModel.volume as NSNumber)!
        volumeNb.text = "\(currencySelected)\(formatted_volumeNb)"
        changePercentage.text = "\(cryptoDataModel.changePercentage)%"
        print("Success! The UI got successfully updated!")
    }
    
    // MARK: -  Search Entered Crypto Name
    /***************************************************************/
    
    func enteredCryptoName(nameOfSymbol : String) -> String{
        let URL = baseURL + nameOfSymbol
        print("Entered in the search bar")
        return URL
    }
    
    // action of the search button
    @IBAction func btnPressed(_ sender: Any) {
        entered_name = searchBar.text
        if(entered_name != nil){
            URLWithSymbolName = enteredCryptoName(nameOfSymbol: entered_name!)
            getMarketCapData(url: marketCapURL)
            getCryptoData(url: URLWithSymbolName+pickedCurrency!)
            print("Pressed the search button")
        }
    }
}

