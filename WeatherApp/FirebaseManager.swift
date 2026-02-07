import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine // Fixes: Initializer 'init(wrappedValue:)' is not available

class FirebaseManager: ObservableObject {
    @Published var favorites: [FavoriteCity] = []
    @Published var userId: String?
    
    private let db = Database.database().reference()
    
    init() {
        signIn()
    }
    
    // Auth Requirement: Anonymous Authentication [cite: 22]
    func signIn() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Auth Error: \(error.localizedDescription)")
                return
            }
            
            if let user = result?.user {
                print("Auth Success! User ID: \(user.uid)")
                DispatchQueue.main.async {
                    self.userId = user.uid
                    self.startListening() // Start real-time sync once authed
                }
            }
        }
    }
    
    // CRUD: Create city with note [cite: 23, 28]
    func addFavorite(cityName: String, note: String) {
        guard let uid = userId else {
            print("Firebase Error: User not authenticated") // [cite: 22]
            return
        }
        print("Attempting to save city: \(cityName) for user: \(uid)")
        
        let ref = db.child("favorites").child(uid).childByAutoId()
        let data: [String: Any] = [
            "id": ref.key ?? UUID().uuidString,
            "cityName": cityName,
            "note": note,
            "createdAt": ServerValue.timestamp(),
            "createdBy": uid
        ]
        ref.setValue(data) { error, _ in
            if let error = error {
                print("Database Error: \(error.localizedDescription)") // [cite: 26]
            } else {
                print("Successfully saved to Cloud!")
            }
        }
    }
    
    // CRUD: Read with Real-time Updates [cite: 23, 33]
    func startListening() {
        guard let uid = userId else { return }
        
        // Swift Requirement: Use Realtime Database with observers [cite: 33, 38]
        db.child("favorites").child(uid).observe(.value) { snapshot in
            var tempItems: [FavoriteCity] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                   let favorite = try? JSONDecoder().decode(FavoriteCity.self, from: jsonData) {
                    tempItems.append(favorite)
                }
            }
            DispatchQueue.main.async {
                self.favorites = tempItems
            }
        }
    }
    
    // CRUD: Delete [cite: 23]
    func deleteFavorite(id: String) {
        guard let uid = userId else { return }
        db.child("favorites").child(uid).child(id).removeValue()
    }
}
