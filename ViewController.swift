//  Created on 02.09.2018.

import UIKit
import FirebaseCore
import Firebase
import FirebaseStorage
import Foundation
import WebKit

class ViewController: UIViewController, XMLParserDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textFieldWithJson: UITextField!
    @IBOutlet weak var textFieldWithReceivedXml: UITextView!
    @IBOutlet weak var webView: WKWebView!
    
    var jsonstring: String = ""
    var path: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("start download")
        
        let dataStorage = Storage.storage().reference()
        let file = dataStorage.child("main.xml")
        
        //Получаем файл из базы firebase
        file.getData(maxSize: 1000) { (content, error) in
            if error == nil {
                print("XML: \(String(describing: content)) \n" as Any)
                
                //Переводим xml data to string
                let filecontent = String(data: content!, encoding: .utf8)
                print("XML data as string: \(String(describing: filecontent)) \n" as Any)
                
                //Записываем filecontent в текстовое поле
                self.textFieldWithReceivedXml.text = filecontent
                
            } else {
                print("Cant download with: \(String(describing: error))")
            }
        }
        
        //Вывод metadata файла в консоль
        file.getMetadata { metadata, error in
            if error != nil {
                print("Error while trying to load metadata")
            } else {
                print(metadata as Any)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Показывает страницу в webView
        let url = URL(string: "https://convert.town/xml-to-json")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    @IBAction func clickOnBtn(_ sender: Any) {
        //Помещаем из текстового поля json в строку
        jsonstring = textFieldWithJson.text!
        
        //Создаем файл
        _ = "file.json"
        let documentUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = documentUrl.appendingPathComponent("file").appendingPathExtension("json")
        
        do{
            try jsonstring.write(to: url, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            print ("Failed writing to URL: \(url), Error:" + error.localizedDescription)
        }
        
        //Записываем json в файл
        let localFile = URL(string: ("\(url)"))
        let storageRef = Storage.storage().reference()
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("file.json")
        
        // Отправляем файл в firebase storage
        _ = riversRef.putFile(from: localFile!, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // error
                return
            }
            
            _ = metadata.size
            storageRef.downloadURL { (url, error) in
                guard url != nil else {
                    return
                }
            }
        }
    }
}

