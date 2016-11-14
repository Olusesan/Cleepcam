//
//  ViewController.swift
//  serverTest2
//
//  Created by Olusesan Ajina on 10/28/16.
//  Copyright © 2016 Sesan Ajina. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var myImageView: UIImageView!
    
    //let imagepicker = UIImagePickerController ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imagepicker.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func uploadPhoto(sender: AnyObject) {
        
        myImageUploadRequest()
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = .photoLibrary
        
        
        
        present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            
            myImageView.image = image
        } else {print("wetin happen")
        }
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
        
    }
    
    func myImageUploadRequest() {
        
        let myUrl = NSURL(string: "http://52.36.157.26:80/upload")
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        let param = ["name" : "sesan"]
        
        
        let boundry = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundry)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(myImageView.image!, 0.5)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters:param,filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundry) as Data
        
        print("Request: = \(request)")

        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            
            
            
            
            if error != nil {
                print("error=\(error)")
                return
            }
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            let httpResponse = response as! HTTPURLResponse
            let statusCode =  httpResponse.statusCode
            
            if (statusCode == 200){
                
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                if let content = json!["content"] as?  [[String: AnyObject]] {
                
                    for content in content {
                     
                        if let userid = content ["userid"] {
                            
                            print(userid)
                        }
                    }
                
                }
                
   //             print(json!)
                
                DispatchQueue.main.async(execute: {
                    self.myActivityIndicator.stopAnimating()
                    self.myImageView.image = nil;
                });
                
            }catch
            {
                print(error)
            }
            
            }
                
        }
        
        task.resume()
    }
    
  
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
       if parameters != nil {
           for (key) in parameters! {
               body.appendString(string: "--\(boundary)\r\n")
               body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
             // body.appendString(string: "\(value)\r\n")
           }
       }
        
        let filename = "file"
    //    let mimetype = "image/jpeg"
        
        body.appendString(string: "--\(boundary)\r\n")
       body.appendString(string: "Content-Disposition: form-data; name=\"\(filename)\"\r\n")
   //     body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
        
        
    }
    
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
    
    
}


