import ComposableArchitecture
import FavoritePrimes
import PrimeModal
import SwiftUI
import PlaygroundSupport






//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: PrimeModalView(
//        store: Store<PrimeModalState, PrimeModalAction>(
//            initialValue: PrimeModalState(count: 3, favoritePrimes: [3]),
//            reducer: primeModalReducer
//        )
//    )
//)

//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: FavoritePrimesView(
//        store: Store<[Int], FavoritePrimesAction>(
//            initialValue: [2,3,5],
//            reducer: favoritePrimesReducer
//        )
//    )
//)

//let store = Store<Int, ()>(initialValue: 0) { count, _ in
//    count += 1
//}
//
//store.value
//store.send(())
//store.send(())
//store.send(())
//store.value
//
//let newStore = store.view { $0 }
//newStore.value
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.send(())
//
//newStore.value //7
//store.value // 7
//
//// новое хранилище имеет ссылку на старое и изменияет его каждый раз
//
//// но если мы меняет store.send() то меняется value только этого глобального а локально не меняется
//store.send(())
//store.send(())
//
//newStore.value
//store.value
