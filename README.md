# FileSaveHelper #
A Swift class to help save and retrieve files from iOS devices. To use, import FileSaveHelper.swift to your project.


## Initialization ##

There are three init methods provided. The default directory is the Document directory and the default sub directory is empty.

If you don't want to specify the directory or sub directory for the file use:
   
```swift
let file = JJJFile(fileName: "myTextFile", fileExtension: .txt)
```

To specify a sub directory use:

```swift
let file = JJJFile(fileName: "myTextFile", fileExtension: .txt, subDirectory: "files")
```

To specify the sub directory and the directory use: 

```swift
let file = JJJFile(fileName: "myTextFile", fileExtension: .txt, subDirectory: "files", directory: .documentDirectory)
```


## Saving a File ##

If you want to save a text file, you have to give it content to save and the save method throws.

```swift
let textToSave = "Saved a file in Swift!"  

do {  
	try file.save(textToSave)
}
catch {
	print("There was an error saving the file: \(error)")
}
```

## Checking if a File Exists ##

To check if a file exists, you use the `fileExists` property

## Reading a File ##

To get the contents of a file use the `getContentsOfFile` like so:

```swift
do {
  let contents = try file.getContents()
}
catch {
  print("There was an error getting the contents: \(error)")
}
```
