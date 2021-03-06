//  ShopCardCollectionViewCell.swift

import UIKit
import SwiftyJSON
import Firebase

class ShopCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var ShopName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var viewDetail: UIButton!
    @IBOutlet weak var AddToFavorite: UIButton!
    
    var shopURL: String?
    
    var popup: ItemDetailViewController?
    var controller: ShopsViewController?
    
    @IBAction func viewDetai(_ sender: UIButton) {
        popup?.shopName.text = ShopName.text
        popup?.itemPrice.text = itemPrice.text
        popup?.itemDescription.text = controller?.merchandize?.detail
        popup?.itemName.text = controller?.merchandize?.name
        popup?.shopURL = shopURL
        
        let caller = controller!
        caller.addChild(popup!)
        popup!.view.frame = caller.view.frame
        caller.view.addSubview(popup!.view)
        popup!.didMove(toParent: caller)
    }
    
    //This function stores selected favorite item in the firebase database in JSON tree format 
    @IBAction func addToFavorite(_ sender: Any) {
        
        
        // config buttom UI
        AddToFavorite.isSelected.toggle()
        let userid = Auth.auth().currentUser!.uid
        //MARK: create a tree structure of this user and insert the following data; set the rule as well
        let dataToStoreInDatabase = controller?.merchandize
        let new = controller?.ref.child("users").child(userid).child("favorites").childByAutoId()
        controller?.ref.child("users").child(userid).child("favorites")
        new!.setValue(
            ["name": dataToStoreInDatabase!.name,
             "detail": dataToStoreInDatabase!.detail])
        var array = [String: String]()
        for (index, img) in (controller?.merchandize?.ImageURLs.enumerated())! {
            array["img\(index)"] = img
        }
        new!.child("images").setValue(array)
        for (index, retailer) in (controller?.merchandize?.shops.enumerated())! {
            var store = [String: String]()
            store["name"] = retailer.name
            store["url"] = retailer.URL
            store["price"] = String(retailer.price)
            new!.child("shops/shop\(index)").setValue(store)
        }
    }
    
    func getData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImg(url: String) {
        print("Download Started")
        // show indicator
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        self.productImg.addSubview(indicator)
        indicator.color = UIColor.orange
        indicator.frame = self.productImg.frame
        indicator.center = self.productImg.center
        indicator.sizeToFit()
        indicator.startAnimating()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            guard let Url = URL(string: url) else {
                return
            }
            self.getData(url: Url) { (data, response, error) in
                if let data = data, error == nil {
                    print(response?.suggestedFilename ?? Url.lastPathComponent)
                    print("Download Finished")
                    DispatchQueue.main.async() {
                        self.productImg.image = UIImage(data: data)
                        indicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async() {
                        print("Download Failed")
                        indicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        
        self.clipsToBounds = false
    }
}

