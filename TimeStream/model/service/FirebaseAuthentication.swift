//
//  FirebaseAuthentication.swift
//  TimeStream
//
//  Created by appssemble on 03.07.2021.
//

import Foundation
import FirebaseAuth

typealias StringErrorClosure = (_ success: Bool, _ value: String?, _ error: Error?) -> Void
typealias AuthenticationClosure = (_ result: Result<String>) -> Void
typealias ValidationTokenClosure = (_ result: Result<String>) -> Void
typealias VoidClosure = (_ result: Result<Void>) -> Void


class FirebaseAuthentication {
    
    // MARK: Methods
    
    func validatePhoneNumber(number: String, completion: @escaping StringErrorClosure) {
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in

            if let error = error as NSError? {
                AlertHelper.displayMessageOnTopOfEverything(error.localizedDescription, title: "oops".localized)
                completion(false, nil, error)

                return
            }

            guard let id = verificationID else {
                AlertHelper.displayMessageOnTopOfEverything("no verification ID", title: "error2")
                completion(false, nil, error)
                return
            }
            
            completion(true, id, nil)
        }
    }
    
    func validateCode(verificationID: String, code: String, completion: @escaping AuthenticationClosure) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            guard let _ = authResult, error == nil else {
//                AlertHelper.displayMessageOnTopOfEverything(error?.localizedDescription ?? "no error", title: "oops".localized)
                completion(.error(error))
                
                return
            }
            
            self.fetchAccessToken(completion: completion)
        }
    }
    
    func reauthenticate(verificationID: String, code: String, completion: @escaping AuthenticationClosure) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            guard let _ = authResult, error == nil else {
                completion(.error(error))
                
                return
            }
            
            self.fetchAccessToken(completion: completion)
        }
    }
    
    func changePhoneNumber(verificationID: String, verificationCode: String, completion: @escaping VoidClosure) {
        guard let user = Auth.auth().currentUser else {
            completion(.error(nil))
            return
        }
        
        let phoneAuthCredentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        user.updatePhoneNumber(phoneAuthCredentials) { (error) in
            if let error = error {
                completion(.error(error))
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    func refreshAccessToken(completion: @escaping AuthenticationClosure) {
        fetchAccessToken(completion: completion)
    }
    
    func signOut(completion: @escaping EmptyClosure) {
        do {
            try Auth.auth().signOut()
        } catch {}
        
        completion()
    }
    
    // MARK: Private methods
    
    private func fetchAccessToken(completion: @escaping AuthenticationClosure) {
        guard let user = Auth.auth().currentUser else {
            completion(.error(nil))
            
            return
        }
        
        user.getIDTokenForcingRefresh(true) { (token, error) in
            guard let token = token, error == nil else {
                completion(.error(error))
                return
            }
            
            completion(.success(token))
        }
    }
    
}
