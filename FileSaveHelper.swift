//
//  FileSaveHelper.swift
//  SavingFiles
//
//  Created by Jeremiah Jessel on 9/14/15.
//  Copyright © 2015 JCubedApps. All rights reserved.
//

import Foundation
import UIKit

class FileSaveHelper {
  
  // MARK:- Error Types
  
  private enum FileErrors:ErrorType {
    case JsonNotSerialized
    case FileNotSaved
    case ImageNotConvertedToData
    case FileNotRead
    case FileNotFound
  }
  
  // MARK:- File Extension Types
  enum FileExtension:String {
    case TXT = ".txt"
    case JPG = ".jpg"
    case JSON = ".json"
  }
  
  // MARK:- Private Properties
  private let directory:NSSearchPathDirectory
  private let directoryPath: String
  private let fileManager = NSFileManager.defaultManager()
  private let fileName:String
  private let filePath:String
  private let fullyQualifiedPath:String
  private let subDirectory:String
  
  // MARK:- Public Properties
  var fileExists:Bool {
    get {
      return fileManager.fileExistsAtPath(fullyQualifiedPath)
    }
  }
  
  var directoryExists:Bool {
    get {
      var isDir = ObjCBool(true)
      return fileManager.fileExistsAtPath(filePath, isDirectory: &isDir )
    }
  }
  
  // MARK:- Initializers
  convenience init(fileName:String, fileExtension:FileExtension){
    self.init(fileName:fileName, fileExtension:fileExtension, subDirectory:"", directory:.DocumentDirectory)
  }
  
  convenience init(fileName:String, fileExtension:FileExtension, subDirectory:String){
    self.init(fileName:fileName, fileExtension:fileExtension, subDirectory:subDirectory, directory:.DocumentDirectory)
  }
  
  /**
  Initialize the FileSaveHelper Object with parameters
  
  :param: fileName      The name of the file
  :param: fileExtension The file Extension
  :param: directory     The desired sub directory
  :param: saveDirectory Specify the NSSearchPathDirectory to save the file to
  
  */
  init(fileName:String, fileExtension:FileExtension, subDirectory:String, directory:NSSearchPathDirectory){
    self.fileName = fileName + fileExtension.rawValue
    self.subDirectory = "/\(subDirectory)"
    self.directory = directory
    self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)[0]
    self.filePath = directoryPath + self.subDirectory
    self.fullyQualifiedPath = "\(filePath)/\(self.fileName)"
    createDirectory()
  }
  
  /**
  If the desired directory does not exist, then create it.
  */
  private func createDirectory(){
    if !directoryExists {
      do {
        try fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil)
      }
      catch {
        print("An Error was generated creating directory")
      }
    }
  }
  
  // MARK:- File saving methods
  
  /**
  Save the contents to file
  
  :param: fileContents A String that will be saved in the file
  */
  func saveFile(string fileContents:String) throws{

    do {
      try fileContents.writeToFile(fullyQualifiedPath, atomically: true, encoding: NSUTF8StringEncoding)
    }
    catch  {
      throw error
    }
  }
  
  /**
  Save the image to file.
  
  :param: image UIImage
  */
  func saveFile(image image:UIImage) throws {
    guard let data = UIImageJPEGRepresentation(image, 1.0) else {
      throw FileErrors.ImageNotConvertedToData
    }
    if !fileManager.createFileAtPath(fullyQualifiedPath, contents: data, attributes: nil){
      throw FileErrors.FileNotSaved
    }
  }
  
  /**
  Save a JSON file
  
  :param: dataForJson NSData
  */
  func saveFile(dataForJson dataForJson:AnyObject) throws{
    do {
    let jsonData = try convertObjectToData(dataForJson)
      if !fileManager.createFileAtPath(fullyQualifiedPath, contents: jsonData, attributes: nil){
        throw FileErrors.FileNotSaved
      }
    } catch {
      print(error)
      throw FileErrors.FileNotSaved
    }
    
  }
  
  func getContentsOfFile() throws -> String {
    guard fileExists else {
      throw FileErrors.FileNotFound
    }
    
    var returnString:String
    do {
       returnString = try String(contentsOfFile: fullyQualifiedPath, encoding: NSUTF8StringEncoding)
    } catch {
      throw FileErrors.FileNotRead
    }
    return returnString
  }
  
  func getImage() throws -> UIImage {
    guard fileExists else {
      throw FileErrors.FileNotFound
    }
    
    guard let image = UIImage(contentsOfFile: fullyQualifiedPath) else {
      throw FileErrors.FileNotRead
    }
    
    return image
    
  }
  
  func getJSONData() throws -> NSDictionary {
    guard fileExists else {
      throw FileErrors.FileNotFound
    }
    do {
      let data = try NSData(contentsOfFile: fullyQualifiedPath, options: NSDataReadingOptions.DataReadingMappedIfSafe)
      let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
      return jsonData
    } catch {
      throw FileErrors.FileNotRead
    }
    
  }

  // MARK:- Json Converting
  
  /**
  Convert the NSData to Json Data
  
  :param: data NSData
  
  :returns: Json Serialized NSData
  */
  private func convertObjectToData(data:AnyObject) throws -> NSData {
    
    do {
      let newData = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
      return newData
    }
    catch {
      print("Error writing data: \(error)")
    }
    throw FileErrors.JsonNotSerialized
  }
  
  
}
