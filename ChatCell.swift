//
//  Copyright (c) 2016 Daniel Rhodes <rhodes.daniel@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
//  USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class ChatCell: UITableViewCell {
    
    static var Inset:CGFloat = 25.0
    
    let headerMsg = UILabel()
    let textMsg = UILabel()
    
//    var message: ChatMessage? {
//        didSet {
////            self.textMsg.attributedText = message?.attributedString()
////            self.textMsg.sizeToFit()
//            self.headerMsg.text = message?.name
//            self.headerMsg.sizeToFit()
//            
//            self.textMsg.text = message?.message
//            self.textMsg.sizeToFit()
//        }
//    }
    
    var message: ChatMessage?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        headerMsg.frame = CGRect(x: 10, y: 5, width: self.frame.width, height: 20)
        headerMsg.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerMsg.numberOfLines = 1
        headerMsg.font = UIFont.boldSystemFont(ofSize: 10.0)
        
        textMsg.lineBreakMode = NSLineBreakMode.byWordWrapping
        textMsg.numberOfLines = 0
        
        self.addSubview(headerMsg)
        self.addSubview(textMsg)
        
        headerMsg.snp.remakeConstraints({ (make) -> Void in
            make.top.equalTo(5)
            make.left.equalTo(ChatCell.Inset)
            make.right.equalTo(-ChatCell.Inset)
            make.height.equalTo(20)
        })
        
        self.layoutMargins = UIEdgeInsets.zero        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func chatCell(name: String) {
        if message?.name == name {
            self.headerMsg.text = "You@"
            self.textMsg.text = message?.message
            self.headerMsg.sizeToFit()
            self.textMsg.sizeToFit()
            headerMsg.textAlignment = .right
            textMsg.snp.remakeConstraints({ (make) -> Void in
                make.top.equalTo(ChatCell.Inset)
                make.right.equalTo(-ChatCell.Inset)
                make.width.equalTo(280)
                make.bottom.equalTo(0)
            })
            textMsg.customLabel(color: UIColor(red: 74/255, green: 160/255, blue: 154/255, alpha: 1), textColor: UIColor.white)
        } else {
            self.headerMsg.text = message?.name
            self.textMsg.text = message?.message
            self.headerMsg.sizeToFit()
            self.textMsg.sizeToFit()
            headerMsg.textAlignment = .left
            textMsg.snp.remakeConstraints({ (make) -> Void in
                make.top.left.equalTo(ChatCell.Inset)
                make.width.equalTo(280)
                make.bottom.equalTo(0)
            })
            textMsg.customLabel(color: UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1), textColor: UIColor.black)
        }
    }
}

extension UILabel {
    func customLabel(color: UIColor, textColor: UIColor) {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = color
        self.textColor = textColor
    }
}
