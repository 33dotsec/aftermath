//
//  BashProfiles.swift
//  aftermath
//
//

import Foundation


class BashProfiles: ArtifactsModule {
    let profilesDir: URL
    
    init(profilesDir: URL) {
        self.profilesDir = profilesDir
    }
    
    
    override func run() {
        self.log("Collecting shell history and profile information...")
        
        let userFiles = [ ".bash_history", ".bash_profile", ".bashrc", ".bash_logout",
                          ".zsh_history", ".zshenv", ".zprofile", ".zshrc", ".zlogin", ".zlogout",
                          ".sh_history"
        ]
        
        let globalFiles = ["/etc/profile", "/etc/zshenv", "/etc/zprofile", "/etc/zshrc", "/etc/zlogin", "/etc/zlogout"]
        
        // for each user, copy the shell historys and profiles
        if let users = self.users {
            for user in users {
                for filename in userFiles {
                    let path = URL(fileURLWithPath: "\(user.homedir)/\(filename)")
                    let newFileName = "\(user.username)_\(filename)"
                    self.copyFileToCase(fileToCopy: path, toLocation: self.profilesDir, newFileName: newFileName)
                }
            }
        }
        
        // Copy all the global files
        for file in globalFiles {
            let fileUrl = URL(fileURLWithPath: file)
            let filename = fileUrl.lastPathComponent
            let newFileName = "etc_\(filename)"
            self.copyFileToCase(fileToCopy: fileUrl, toLocation: self.profilesDir, newFileName: newFileName)
        }
        
        self.log("Finished collecting shell history and profile information...")
    }
}