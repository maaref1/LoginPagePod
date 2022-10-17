//
//  LoginWebView.swift
//  FBSnapshotTestCase
//
//  Created by khalil on 17/10/2022.
//

import UIKit
import WebKit

@IBDesignable
class LoginWebView: UIView {
    
    @IBInspectable
    var pathWebView: String = "www.google.com"
    
    private var webView: WKWebView!
    
    let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
    
    open override func draw(_ rect: CGRect) {
        self.loadPageToContainer()
    }
    
    func loadPageToContainer() {
        self.clearSubViews()
        if let url = URL(string: self.pathWebView) {
            
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.allowsInlineMediaPlayback = true
            webConfiguration.mediaTypesRequiringUserActionForPlayback = []
            
            let wd = self.bounds.width
            let ht = self.bounds.height
            webView = WKWebView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: wd,
                                              height: ht),
                                configuration: webConfiguration)
            
            webView!.tag = 1
            webView!.navigationDelegate = self
            
            let urlRequest = URLRequest(url: url)
            //webViewVideoPlayer.fixInView(self.newsMediaContainerView)
            self.addSubview(webView)
            webView.frame(forAlignmentRect: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.bounds.width,
                                                   height: self.bounds.height))
            webView.load(urlRequest)
        } else {
            self.loadFailedMessage()
        }
    }
    
    func loadFailedMessage() {
        let lbEmpty = UILabel()
        lbEmpty.text = "Could not load path url"
        self.addSubview(lbEmpty)
        lbEmpty.addConstraints([
            .init(item: lbEmpty, attribute: .top,
                  relatedBy: .equal,
                  toItem: self,
                  attribute: .top,
                  multiplier: 1,
                  constant: 0),
            .init(item: lbEmpty, attribute: .bottom,
                  relatedBy: .equal,
                  toItem: self,
                  attribute: .bottom,
                  multiplier: 1,
                  constant: 0),
            .init(item: lbEmpty, attribute: .left,
                  relatedBy: .equal,
                  toItem: self,
                  attribute: .left,
                  multiplier: 1,
                  constant: 0),
            .init(item: lbEmpty, attribute: .right,
                  relatedBy: .equal,
                  toItem: self,
                  attribute: .right,
                  multiplier: 1,
                  constant: 0),
        ])
    }
    
    func clearSubViews() {
        self.subviews.forEach { mView in
            mView.removeFromSuperview()
        }
    }
}

extension LoginWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let idTag: Int = webView.tag
        switch idTag {
        case 1:
            self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                if complete != nil {
                    self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                        if let h = height as? CGFloat {
                            // self.heightConstrantWebViewcontainer.constant = h
                            print("height of document is: \(h)")
                        }
                    })
                }
                
            })
            break
        default:
            print("UnHandled webView[\(idTag)]")
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let idTag = webView.tag
        if idTag == 1 {
            self.clearSubViews()
            self.loadFailedMessage()
        }
    }
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
                // This is not HTTP link - can be a local file or a mailto
                decisionHandler(.allow)
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
