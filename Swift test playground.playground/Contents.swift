import Cocoa
import Foundation



struct Client: Equatable {
  let  name: String
  let  age: Int
  let  height: Float
}


struct Reservation {
    let id: String
    let name:String
    let clientsList: [Client]
    let time: Int
    let price: Float
    let hasBreakfast : Bool
}

enum ReservationError: Error {
    case sameIDReservationFound
    case reservationFoundForCustomer
    case reservationNotFound
}


class HotelReservationManager {
    
    private var reservations: [Reservation] = []
    private let basePrice: Int = 20
    
    
    func addReservation(clientList: [Client], time: Int, breakfast: Bool = false) {
        
        let finalPrice = calculatePrice(clientsNumber: clientList.count, time: time, hasBreakfast: breakfast)
        let id = UUID().uuidString
        
        do{
            try checkReservationId(id)
            try checkClients(clientList)
            
            let newReservation = Reservation(id: id, name: "Kame House", clientsList: clientList, time: time, price: finalPrice, hasBreakfast: breakfast )
            reservations.append(newReservation)
            
            
        }catch ReservationError.sameIDReservationFound{
            print("El id ya existe en la lista de reservas")
        } catch ReservationError.reservationFoundForCustomer{
            print("Uno de los usuarios ya está en una reserva")
        } catch {
            print("Unexpected error")
        }

    }
    
    func cancelReservation(_ id: String) throws {
        if(checksId(id)){
            reservations.removeAll{$0.id == id}
            print("Reserva eliminada")
        }else{
            throw ReservationError.reservationNotFound
        }
        
    }
    
    
    private func checkReservationId(_ id: String) throws{
        let containsId = checksId(id)
        if containsId  {throw ReservationError.sameIDReservationFound}
    }
    
    private func checksId(_ id: String) -> Bool{
        let containsId = reservations.contains{reservation in return reservation.id == id}
        return containsId
    }
    
    private func checkClients(_ clientsList: [Client]) throws {
        for reservation in reservations {
                let containsTheClient = clientsList.contains { client in
                    reservation.clientsList.contains { existingClient in
                        client == existingClient
                    }
                }
                if containsTheClient {
                    throw ReservationError.reservationFoundForCustomer
                }
            }
        
    }
    
    private func calculatePrice(clientsNumber: Int, time: Int, hasBreakfast: Bool ) -> Float {
        
        let finalPrice: Float = Float(clientsNumber * time * basePrice) * (hasBreakfast ? Float(1.25) : Float(1.0))
        return finalPrice
    }
    
    
    func getReservations() -> [Reservation]{
        return reservations
    }
    
    
}


let hotel = HotelReservationManager()

/// TEST  ADD RESERVATIOS
///
/// We are gonna test, that we can add a reservation
/// that we cant add two reservations with the same id (We put the id with uuid so never should repeat and we put it in the function so we cant force it out of the function)
/// and that we can´t add 2 reservations with the same client
func testAddReservation() {
    
    //Creating the firs clientList
    let clientList : [Client] = [Client(name: "Marcos", age: 28, height: 12),Client(name: "Marcos2", age: 24, height: 12)]
    
    hotel.addReservation(clientList: clientList, time: 5, breakfast: true)
    assert(hotel.getReservations().count > 0, "No se ha añadido bien la reserva")
    //Test the reservation was saved
    print("Reservas añadidas -> ",hotel.getReservations().count)
    
    //checks the client validation
    hotel.addReservation(clientList: clientList, time: 5, breakfast: true)
    print("Reservas añadidas -> ",hotel.getReservations().count)

}

testAddReservation()



/// TEST  CANCEL RESERVATION
///
/// We are gonna test, that we can remove a reservation
/// and when you try to delete a not saved reservation shows an error

func testCancelReservation(){
    
    if(hotel.getReservations().isEmpty){
        let clientList : [Client] = [Client(name: "Marcos", age: 28, height: 12),Client(name: "Marcos2", age: 24, height: 12)]
        hotel.addReservation(clientList: clientList, time: 5, breakfast: true)
    }
    
    do{
        let toRemoveId = hotel.getReservations()[0].id
        try hotel.cancelReservation(toRemoveId)
        print("Eliminado correctamente la primera vez")
        try hotel.cancelReservation(toRemoveId)
        print("Este print no debería salir nunca")
    }catch ReservationError.reservationNotFound {
        print("No se ha encontrado la reserva a cancelar")
    }catch {
        print("Unexpected error")
    }
    
    
}

testCancelReservation()


/// TEST  RESERVATION PRICE
///
/// We are gonna test the price calculator writing three reservations
/// two with the same parameters (excluding clients, same price)
/// and one with diferents parameters (diferent price)

func testReservationPrice(){
    
    let clientList : [Client] = [Client(name: "Marcos", age: 28, height: 12)]
    let clientList2: [Client] = [Client(name: "Marcos2", age: 24, height: 12)]

    //Change time or breakfast value to break the test
    hotel.addReservation(clientList: clientList, time: 5, breakfast: true)
    hotel.addReservation(clientList: clientList2, time: 5, breakfast: true)

    
    let reservations = hotel.getReservations()
    
    assert(reservations[0].price == reservations[1].price, "Las reservas no tienen en mismo precio")
    
    for (index, reservation) in reservations.enumerated() {
        print("Test precio reserva \(index) ->  ",reservation.price)
    }

}

testReservationPrice()
