//
//  XmlReader.swift
//  XmlReader
//
//  Created by 丁燕军 on 2020/9/19.
//

import Foundation

class XmlReader: NSObject {
    
    private var dictionaryStack = Array<Dictionary<String, AnyObject>>()
    
    public static func dictionaryForXMLData(data: Data) -> Dictionary<String, AnyObject>? {
        let reader = XmlReader()
        let rootDictionary = reader.object(with: data)
        return rootDictionary
    }
    
    private func object(with data: Data) -> Dictionary<String, AnyObject>? {
        
        dictionaryStack.append(Dictionary<String, AnyObject>())
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()
        
        if success, let result = dictionaryStack.first {
            return result
        }
        return nil
    }
    
    
}

extension XmlReader: XMLParserDelegate {
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        var parentDict = dictionaryStack.last
        
        if parentDict != nil {
            
            var childDict = Dictionary<String, AnyObject>()
            
            for (key, value) in attributeDict {
                childDict[key] = value as AnyObject
            }
            
            if let existingValue = parentDict![elementName] {
                var array: Array<Dictionary<String, AnyObject>>
                
                if let existingValue = existingValue as? Array<Dictionary<String, AnyObject>> {
                    array = existingValue
                } else {
                    array = Array<Dictionary<String, AnyObject>>()
                    array.append(existingValue as! Dictionary<String, AnyObject>)
                    
                    parentDict![elementName] = array as AnyObject
                }
                
                array.append(childDict)
            } else {
                parentDict![elementName] = childDict as AnyObject
            }
            
            dictionaryStack.append(childDict)
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        dictionaryStack.removeLast()
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !string.isEmpty else {
            return
        }
        
        var dictInProgress = dictionaryStack.last
        
        if dictInProgress != nil {
            if let textInprogress = dictInProgress!["text"] as? String {
                dictInProgress!["text"] = (textInprogress + string) as AnyObject
            } else {
                dictInProgress!["text"] = string as AnyObject
            }
        }
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("\(#file)---\(#function)---\(parseError)")
    }
    
}
