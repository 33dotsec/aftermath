//
//  Brave.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Brave: BrowserModule {

    let braveDir: URL
    let writeFile: URL
    
    init(braveDir: URL, writeFile: URL) {
        self.braveDir = braveDir
        self.writeFile = writeFile
    }
    
    func getContents() {
        for user in getBasicUsersOnSystem() {
            let path = "\(user.homedir)/Library/Application Support/BraveSoftware/Brave-Browser/Default"
            let files = filemanager.filesInDirRecursive(path: path)
            
            for file in files {
                if file.lastPathComponent == "" {
                    dumpHistory(file: file)
                }
            }
        }
    }
    
    func dumpHistory(file: URL) {
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- Brave History -----\n")
        
            var db: OpaquePointer?
            if sqlite3_open(file.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "select datetime(vi.visit_time/1000000, 'unixepoch') as dt, urls.url FROM visits vi INNER join urls on vi.id = urls.id;"
                
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var dateTime: String = ""
                    var url: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        let col1  = sqlite3_column_text(queryStatement, 0)
                        if let col1 = col1 { dateTime = String(cString: col1) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 { url = String(cString: col2) }
                        
                        self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\n")
                    }
                }
            }
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Brave History -----\n")
    }
    
    func dumpCookies() {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Brave Cookies: -----\n")
        
        for user in getBasicUsersOnSystem() {
            let file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/BraveSoftware/Brave-Browser/Default/Cookies")
            
            var db: OpaquePointer?
            if sqlite3_open(file.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "select datetime(creation_utc/1000000-11644473600, 'unixepoch'), name,  host_key, path, datetime(expires_utc/1000000-11644473600, 'unixepoch') from cookies;"
            
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var dateTime: String = ""
                    var name: String = ""
                    var hostKey: String = ""
                    var path: String = ""
                    var expireTime: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        let col1  = sqlite3_column_text(queryStatement, 0)
                        if let col1 = col1 { dateTime = String(cString: col1) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 { name = String(cString: col2) }
                        
                        let col3 = sqlite3_column_text(queryStatement, 2)
                        if let col3 = col3 { hostKey = String(cString: col3) }
                        
                        let col4 = sqlite3_column_text(queryStatement, 3)
                        if let col4 = col4 { path = String(cString: col4) }
                        
                        let col5 = sqlite3_column_text(queryStatement, 4)
                        if let col5 = col5 { expireTime = String(cString: col5) }
                        
                        self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nName: \(name)\nHostKey: \(hostKey)\nPath:\(path)\nExpireTime: \(expireTime)\n\n")
                    }
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Brave Cookies -----\n")
    }
    
    override func run() {
        self.log("Collecting brave browser information...")
        getContents()
        dumpCookies()
    }
}
