//
//  ViewController.swift
//  native_ios_new1
//
//  Created by Tanakorn Chauekid on 10/4/2566 BE.
//
//LN Caller
import Flutter
import FlutterPluginRegistrant

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var btnCheck : UIButton!
    @IBOutlet var fieldMobile : UITextField!
    @IBOutlet var autocompleteMobile : UITableView!
    var _searching = false
    var _mobileList = [String]()
    var _filterMobile = [String]()
    
    var _status : Bool = false
    var _token : String = ""
    var _loadingIndicator = UIActivityIndicatorView(style: .large)
    
    var _tapGesture: UITapGestureRecognizer!
    
    var _defaults = UserDefaults.standard
    lazy var flutterEngine = FlutterEngine(name: "flutter_engine")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fieldMobile.delegate = self
        fieldMobile.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
        
        autocompleteMobile.delegate = self
        autocompleteMobile.dataSource = self
        autocompleteMobile.allowsSelection = true
        autocompleteMobile.isHidden = true
        
        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(_tapGesture)
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)
    }
    
    
    func textField(_ fieldMobile: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = fieldMobile.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func btnCheckClicked () {
        print("Btn check clicked")
        self.loadingCaller(show: true)
        let mobile : String? = fieldMobile.text
        if(mobile != nil){
            print("Input : \(mobile)")
            if(isMobileNumberFormat(mobile: mobile)) {
                print("Validate input success")
                updateRecord(isInsert: true, value: mobile)
                apiGetWhiteList(mobile: mobile)
            } else {
                print("Validate input fail")
                if (mobile == "0909") {
                    print("Clear cache process")
                    _defaults.removeObject(forKey: "mobileList")
                    _mobileList = [String]()
                    autocompleteMobile.reloadData()
                    modalCaller(error: true, title: "Operation", message: "Clear cache success")
                } else {
                    modalCaller(error: true, title: "Mobile number", message: "Input was not correct")
                }
            }
        } else {
            print("Validate input fail")
            modalCaller(error: true, title: "Mobile number", message: "Input was empty")
        }
        
    }
    
    
    //section private function
    func isMobileNumberFormat(mobile: String?) -> Bool {
        if let mobile = mobile {
            let mobileNumberRegex = #"^\d{10}$"#
            let mobileNumberPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberRegex)
            return mobileNumberPredicate.evaluate(with: mobile)
        } else {
            return false
        }
    }

    func modalCaller(error: Bool, title: String, message: String) {
        DispatchQueue.main.async {
            //error not use in ios
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert) //.actionSheet
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                if(error) {
                    self.clearState()
                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func loadingCaller(show: Bool) {
        print(_loadingIndicator)
        DispatchQueue.main.async {
            self._loadingIndicator.color = UIColor.red
            self._loadingIndicator.center = self.view.center
            if(show) {
                print("open loading")
                self.view.addSubview(self._loadingIndicator)
                self._loadingIndicator.startAnimating()
            } else {
                print("close loading")
                self._loadingIndicator.stopAnimating()
                self._loadingIndicator.removeFromSuperview()
            }
        }
    }

    func apiGetWhiteList(mobile:String?) {
        if let mobile = mobile {
            print("API-GetWhiteList : Start")
            //prod
            guard let url = URL(string:"https://api.adldigitalservice.com/anticorrupt-api/api/v1/whitelist/\(mobile)") else {
            //iot
//          guard let url = URL(string:"https://api-stg.adldigitalservice.com/anticorrupt-api/api/v1/whitelist/\(mobile)") else {
                return
            }
            var request = URLRequest(url: url)
            
            //method body headersOcp-Apim-Subscription-Key: d58f71d880f548139576670d7f7eb37f
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //prod
            request.setValue("d58f71d880f548139576670d7f7eb37f", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let httpUrlResponse = response as? HTTPURLResponse {
                    let statusCode = httpUrlResponse.statusCode
                    print("API-GetWhiteList : \(statusCode)")
                    if(statusCode == 200) {
                        print("API-GetWhiteList : success")
                        
                        guard let data = data else {
                            print("API-GetWhiteList : No data received")
                            return
                        }
                        
                        do {
                            let decoder = JSONDecoder()
                            let model = try decoder.decode(responseWhiteList.self, from: data)
                            print("API-GetWhiteList : \(model)")
                            if(model.status == "success") {
                                self._status = true
                                self.apiGetEncryptText(plainText: mobile, msisdn: self.getMsisdnFormat(msisdn:mobile), token: self.getAPIToken())
                            } else {
                                self.clearState()
                            }
                        } catch let error {
                            print("API-GetWhiteList : \(error)")
                            self.modalCaller(error: true, title: "WhiteList progress", message: "An error has been occured")
                        }
                    } else {
                        print("API-GetWhiteList : fail")
                        self.modalCaller(error: true, title: "WhiteList", message: "The whitelist doesn't containt this mobile number")
                    }
                }
                
            }
            task.resume()
        }
    }

    struct responseWhiteList: Codable {
        let status: String
        let mobile: String
    }

    func apiGetEncryptText(plainText:String?, msisdn:String, token:String) {
        if let plainText = plainText {
            print("API-GetEncryptText : Start")
            //prod
            guard let url = URL(string:"https://myais-be.cloud.ais.th/v1/utility/encryptText") else {
            //iot
//            guard let url = URL(string:"https://sit-myais-be.cdc.ais.th/v1/utility/encryptText")else {
                return
            }
            var request = URLRequest(url: url)
            
            //method body headers
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("EN", forHTTPHeaderField: "x-ssb-language")
            request.setValue("eService", forHTTPHeaderField: "x-ssb-system")
            request.setValue("MYAIS", forHTTPHeaderField: "x-ssb-client-channel")
            request.setValue("10.252.163.170", forHTTPHeaderField: "x-ssb-client-ip")
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            request.setValue("012d1566-6af6-4009-9690-ba1e84edef35", forHTTPHeaderField: "x-ssb-session-id")
            request.setValue("CPI", forHTTPHeaderField: "x-ssb-networktype")
            request.setValue(msisdn, forHTTPHeaderField: "x-ssb-msisdn")
            request.setValue(plainText, forHTTPHeaderField: "x-ssb-mobile")
            request.setValue(token, forHTTPHeaderField: "Authorization")
            
            let body : [String:String] = [
                "moduleName" : "LIVING_NETWORK",
                "plainText" : plainText
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let httpUrlResponse = response as? HTTPURLResponse {
                        let statusCode = httpUrlResponse.statusCode
                        print("API-GetEncryptText : \(statusCode)")
                    if(statusCode == 200) {
                        print("API-GetEncryptText : success")
                        
                        guard let data = data else {
                            print("Error: No data received")
                            return
                        }
                        
                        do {
                            let decoder = JSONDecoder()
                            let model = try decoder.decode(EncryptTextResponse.self, from: data)
                            print("Model: \(model)")
                            print("Token Living-Network: \(model.data.EncryptText)")
                            self._token = model.data.EncryptText
                            self.checkRedirect()
                        } catch let error {
                            print("API-GetEncryptText : \(error)")
                            self.modalCaller(error: true, title: "Encrypt progress", message: "An error has been occured")
                        }
                    } else {
                        print("API-GetEncryptText : fail")
                        self.modalCaller(error: true, title: "Encrypt progress", message: "An error has been occured")
                    }
                }
            }
            task.resume()
        }
    }

    struct EncryptTextRequest : Codable {
        let moduleName: String
        let plainText: String
    }

    struct EncryptTextResponse : Codable {
        let resultCode: String
        let resultDesc: String
        let developerMessage: String
        let data: EncryptTextData
    }

    struct EncryptTextData : Codable {
        let EncryptText: String
    }

    func checkRedirect() {
        if (_status && !_token.isEmpty) {
            print("Welcome you pass")
//            modalCaller(error: false, title: "Welcome", message: "You can access to sandbox living network")
//            loadingCaller(show: false)
            DispatchQueue.main.async {
                self.livingnetwork()
            }
            DispatchQueue.main.async {
                self.fieldMobile.text = ""
            }
            //call flutter
        } else {
            clearState()
        }
    }

    func clearState() {
        _status = false
        _token = ""
        loadingCaller(show: false)
        DispatchQueue.main.async {
            self.fieldMobile.text = ""
        }
    }

    func getTid() -> String {
        let random = abs(Int64(Date().timeIntervalSince1970)) * 1000 + Int64(arc4random_uniform(UInt32.max))
        let temp1 = "\(random)"
        return temp1
    }

    func  getMsisdnFormat(msisdn: String) -> String {
        return "66" + msisdn.prefix(1)
    }

    func getAPIToken() -> String {
        //prod
        return "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaGFubmVsIjoiTElWSU5HX05FVFdPUksiLCJpYXQiOjE2ODEyMDYwMjcsImV4cCI6MTY4Mzc5ODAyNywiaXNzIjoiaHR0cHM6Ly9teWFpcy5jbG91ZC5haXMudGgiLCJzdWIiOiJMSVZJTkdfTkVUV09SSyJ9.laeWJpzlE_UNsqtizFjcaNQ6bhu3gr_aguKjta-T2O1IUBIkVdgRtXFvhyO-ThJtar2JR301x96EIYU0KAenFNgpJUFUxhamvEYlq247axUZNnwMT-SgVz-yhEjloOPlX903A-_eY8azFx1TtyZ0AJvPossth-ozxn1mFVboCSMgyBFn3Gj5SWJr5EnlTJiKar_WW5NKwNKwbJEsTUpqqQbElz5iM_zqgdJQxVld2R-GWSBtamjg7avmDdqQHkPnN0a8Z4IT3FunBc83YK8fXZLydixzU0SWQm1woUDifKJBK_lBNJ-Lej92mCT3qK9qtJahqdSXY4ZdOgqfKM1OZg"
        //iot
//        return "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaGFubmVsIjoiTElWSU5HX05FVFdPUksiLCJpYXQiOjE2ODA4Mzg3MjYsImV4cCI6MTY4MzQzMDcyNiwiaXNzIjoiaHR0cHM6Ly9zaXQtbXlhaXMuY2RjLmFpcy50aCIsInN1YiI6IkxJVklOR19ORVRXT1JLIn0.aiURUh8PusaJ__MXH0S_Oqvk2vZ4Lz638L8YP5jzynQxGYTVdNmCLlhYcFhcxEYvdozCN6t66xKoSuph1bqXi1ZZSPZE68F8bwQAVGURxaM6ePZOcFhDYP3k6RK6yopRTbG9aYHwmVr9gzD51f2y65OxchQAAbH90MvwAz3EMLd-Vri4Sfss8oNZJgMxSaM6IHFG0kfNZMUa1yAHfHywRY61h95XgCrddpgFQIEWlXmQXxwZm7aqhi2xCOTcOs2kF-KgGx4v8izRh0CDGCdZuawyVhxab200GHagIwECmOePjBCr4lTIfOqaVx1sK-ChAZ31FKM1Txr_KDjClfscgQ"
    }
    
    //LN Caller
    func livingnetwork() {
        showFlutter()
    }
    
    //section call flutter
    //LN Caller
    
    @objc func invokeFlutter(){
         let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil);
         let channel = FlutterMethodChannel(name: "LIVING_NETWORK", binaryMessenger:flutterViewController.binaryMessenger)
        channel.setMethodCallHandler({
                    (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if(call.method == "open"){
                print(call.arguments)
            }
            if(call.method == "close"){
                print(call.arguments)
                flutterViewController.dismiss(animated: true)
                self.dismiss(animated: true, completion: nil)
                result(nil)
            }

                  })
         channel.invokeMethod("open", arguments: _token )
     }
    
     @objc func showFlutter(){
         invokeFlutter()
         let flutterViewController =
         FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
         flutterViewController.modalPresentationStyle = .fullScreen
         present(flutterViewController, animated: true, completion: nil)
     }
    
}


extension ViewController:UITableViewDelegate, UITableViewDataSource {
        
    @objc func searchRecord(sender:UITextField) {
        self._filterMobile.removeAll()
        let searchData:Int = fieldMobile.text!.count
        if (searchData > 0 && searchData <= 9) {
            _searching = true
            updateRecord(isInsert: false, value: "0")
            for mobile in _mobileList {
                if let mobileToSearch = fieldMobile.text {
                    let range = mobile.range(of: mobileToSearch, range: nil, locale: nil)
                    if (range != nil) {
                        self._filterMobile.append(mobile)
                    }
                }
            }
            if(_filterMobile.count == 0) {
                hideTableView()
            } else {
                autocompleteMobile.reloadData()
                showTableView()
            }
        } else if (searchData == 10) {
            handleTap()
            _searching = false
        } else {
            hideTableView()
            _searching = false
        }
    }
    
    func updateRecord(isInsert:Bool, value:String?) {
        if let value = value {
            if let retrievedArray = _defaults.array(forKey: "mobileList") as? [String] {
                _mobileList = retrievedArray
                if(_mobileList.count != 0) {
                    if (isInsert) {
                        if (!_mobileList.contains(value)) {
                            _mobileList.append(value)
                            _defaults.set(_mobileList, forKey: "mobileList")
                        }
                    }
                } else {
                    if (isInsert) {
                        _mobileList.append(value)
                        _defaults.set(_mobileList, forKey: "mobileList")
                    }
                }
            } else {
                if (isInsert) {
                    _mobileList.append(value)
                }
                _defaults.set(_mobileList, forKey: "mobileList")
            }
        }
    }
    
    func showTableView() {
        // Show the table view and disable the tap gesture recognizer
        autocompleteMobile.isHidden = false
        _tapGesture.isEnabled = false
    }

    func hideTableView() {
        // Hide the table view and enable the tap gesture recognizer
        autocompleteMobile.isHidden = true
        _tapGesture.isEnabled = true
    }

    @objc func handleTap() {
        // Hide both table and keyboard
        dismissKeyboard()
        hideTableView()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
//        DispatchQueue.main.async {
//            self.fieldMobile.resignFirstResponder()
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (_searching) {
            return _filterMobile.count
        } else {
            return _mobileList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = autocompleteMobile.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if (_searching) {
            cell.textLabel?.text = _filterMobile[indexPath.row]
        } else {
            cell.textLabel?.text = _mobileList[indexPath.row]
        }
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        fieldMobile.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected data from the array
        let selectedData = _mobileList[indexPath.row]
        
        // Set the text of the text field to the selected data
        fieldMobile.text = selectedData
        
        // Hide the table view after the user selects an option
        autocompleteMobile.isHidden = true
        handleTap()
        
    }
}

