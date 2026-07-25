//
//  MockPopularTripsService.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

final class MockPopularTripsService: PopularTripsServiceProtocol {

    private static let trips: [PopularTrip] = [
        PopularTrip(
            id: "kapadokya",
            title: "Kapadokya Balon Turu",
            imageURL: URL(string: "https://picsum.photos/seed/kapadokya/800/600"),
            rating: 4.9,
            reviewCount: 1284,
            description: "Gün doğumunda yüzlerce sıcak hava balonuyla süslenen gökyüzü eşliğinde peri bacalarının üzerinde unutulmaz bir uçuş deneyimi yaşayın. Kahvaltı ve konaklama dahildir.",
            price: 6850,
            currency: "TL",
            popularityScore: 2400,
            isFavorite: false
        ),
        PopularTrip(
            id: "antalya",
            title: "Antalya Sahil Tatili",
            imageURL: URL(string: "https://picsum.photos/seed/antalya/800/600"),
            rating: 4.6,
            reviewCount: 932,
            description: "Turkuaz kıyılar, her şey dahil oteller ve bol güneşli günler sizi bekliyor.",
            price: 4200,
            currency: "TL",
            popularityScore: 1980,
            isFavorite: false
        ),
        PopularTrip(
            id: "bodrum",
            title: "Bodrum Marina Kaçamağı",
            imageURL: URL(string: "https://picsum.photos/seed/bodrum/800/600"),
            rating: 4.5,
            reviewCount: 611,
            description: "Beyaz badanalı sokaklar, canlı marina hayatı ve tekne turlarıyla dolu bir hafta sonu kaçamağı. Akşamları gün batımını izleyebileceğiniz teraslar mevcuttur.",
            price: 5100,
            currency: "TL",
            popularityScore: 1540,
            isFavorite: false
        ),
        PopularTrip(
            id: "pamukkale",
            title: "Pamukkale Termal Tatili",
            imageURL: URL(string: "https://picsum.photos/seed/pamukkale/800/600"),
            rating: 4.7,
            reviewCount: 745,
            description: "Beyaz travertenler ve şifalı termal sularla dinlenmenin tadını çıkarın.",
            price: 3450,
            currency: "TL",
            popularityScore: 1320,
            isFavorite: false
        ),
        PopularTrip(
            id: "istanbul",
            title: "İstanbul Boğaz Turu",
            imageURL: URL(string: "https://picsum.photos/seed/istanbul/800/600"),
            rating: 4.8,
            reviewCount: 2031,
            description: "İki kıtayı birbirine bağlayan Boğaz'da tekneyle tarihi yarımadayı, Beylerbeyi Sarayı'nı ve Rumeli Hisarı'nı keşfedin. Akşam yemeği seçenekleri mevcuttur.",
            price: 2100,
            currency: "TL",
            popularityScore: 2650,
            isFavorite: false
        ),
        PopularTrip(
            id: "fethiye",
            title: "Fethiye Yamaç Paraşütü",
            imageURL: URL(string: "https://picsum.photos/seed/fethiye/800/600"),
            rating: 4.9,
            reviewCount: 1567,
            description: "Ölüdeniz'in eşsiz manzarası eşliğinde Babadağ'dan tandem yamaç paraşütü deneyimi.",
            price: 3900,
            currency: "TL",
            popularityScore: 2100,
            isFavorite: false
        ),
        PopularTrip(
            id: "cesme",
            title: "Çeşme Rüzgar Sörfü Kampı",
            imageURL: URL(string: "https://picsum.photos/seed/cesme/800/600"),
            rating: 4.3,
            reviewCount: 288,
            description: "Alaçatı'nın rüzgarlı koylarında başlangıç ve orta seviye rüzgar sörfü eğitimi alın, akşamları koydaki restoranlarda deniz ürünleri tadın.",
            price: 4750,
            currency: "TL",
            popularityScore: 860,
            isFavorite: false
        ),
        PopularTrip(
            id: "trabzon",
            title: "Trabzon Yayla Turu",
            imageURL: URL(string: "https://picsum.photos/seed/trabzon/800/600"),
            rating: 4.4,
            reviewCount: 402,
            description: "Sümela Manastırı, Uzungöl ve yeşilin binbir tonuna bürünen yaylalarda serinleyen bir doğa kaçamağı.",
            price: 3600,
            currency: "TL",
            popularityScore: 1080,
            isFavorite: false
        ),
        PopularTrip(
            id: "sirince",
            title: "Şirince Şarap Turu",
            imageURL: URL(string: "https://picsum.photos/seed/sirince/800/600"),
            rating: 4.2,
            reviewCount: 176,
            description: "Tarihi Rum köyünde şarap tadımı ve el yapımı ürün pazarları arasında keyifli bir gün.",
            price: 1750,
            currency: "TL",
            popularityScore: 540,
            isFavorite: false
        ),
        PopularTrip(
            id: "oludeniz",
            title: "Ölüdeniz Mavi Tur",
            imageURL: URL(string: "https://picsum.photos/seed/oludeniz/800/600"),
            rating: 4.6,
            reviewCount: 519,
            description: "Gizli koylarda yüzme molaları veren tam günlük tekne turuyla Ölüdeniz'in berrak sularını keşfedin. Öğle yemeği tekne üzerinde servis edilir.",
            price: 2450,
            currency: "TL",
            popularityScore: 1210,
            isFavorite: false
        )
    ]

    func fetchTrips(query: String?, sortOption: PopularTripSortOption) async throws -> [PopularTrip] {
        try await Task.sleep(nanoseconds: 500_000_000)

        var results = Self.trips

        if let query, !query.isEmpty {
            results = results.filter { $0.title.localizedStandardContains(query) }
        }

        switch sortOption {
        case .popularity:
            results.sort { $0.popularityScore > $1.popularityScore }
        case .price:
            results.sort { $0.price < $1.price }
        case .rating:
            results.sort { $0.rating > $1.rating }
        }

        return results
    }
}
