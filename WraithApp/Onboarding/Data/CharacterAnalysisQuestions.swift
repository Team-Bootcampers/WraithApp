//
//  CharacterAnalysisQuestions.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

enum CharacterAnalysisQuestions {

    static let all: [QuizQuestion] = [
        QuizQuestion(
            iconName: "QuestionIcon1",
            title: "Yeni bir seyahat planladığında asıl amacın hangisi olur?",
            options: [
                QuizOption(title: "Gündelik stresten uzaklaşıp tamamen dinlenmek", value: "relax"),
                QuizOption(title: "Yeni kültürler, müzeler ve tarihi yerler keşfetmek", value: "culture"),
                QuizOption(title: "Adrenalin, doğa ve yeni maceralar yaşamak", value: "adventure"),
                QuizOption(title: "İyi yemek, eğlence ve gece hayatının tadını çıkarmak", value: "nightlife")
            ],
            insight: "Kullanıcının temel rotasını belirler. Önerilecek destinasyonun \"Deniz/Kum/Güneş\", \"Kültür Turu\" veya \"Macera\" olup olmayacağına karar verir."
        ),
        QuizQuestion(
            iconName: "QuestionIcon2",
            title: "Tatil planlarını ne kadar detaylı yaparsın?",
            options: [
                QuizOption(title: "Uçak ve oteli alırım, gerisi tamamen doğaçlama gelişir.", value: "spontaneous"),
                QuizOption(title: "Görülecek ana yerleri belirlerim ama esnek bir programım olur.", value: "flexible"),
                QuizOption(title: "Saat saat nerede olacağım, nerede yemek yiyeceğim önceden bellidir.", value: "detailed")
            ],
            insight: "Yapay zekanın kullanıcıya sunacağı planın detay seviyesini ayarlar. Doğaçlama kişiye sadece \"Gidilebilecek 5 yer\" listesi verilirken, detaycı kişiye dakik bir takvim sunulmalıdır."
        ),
        QuizQuestion(
            iconName: "QuestionIcon3",
            title: "Seyahat bütçeni en çok hangi kaleme harcamaktan keyif alırsın?",
            options: [
                QuizOption(title: "Konforlu ve lüks bir konaklama", value: "luxury_stay"),
                QuizOption(title: "Michelin yıldızlı restoranlar veya popüler yerel lezzetler", value: "food"),
                QuizOption(title: "Müze girişleri, turlar ve özel aktiviteler", value: "activities"),
                QuizOption(title: "Alışveriş ve hediyelik eşyalar", value: "shopping")
            ],
            insight: "Kullanıcının harcama alışkanlıklarını profiller. \"Ucuz bilet\" arayan biri mi yoksa \"Kalite için para harcamaktan çekinmeyen\" biri mi olduğunu anlar."
        ),
        QuizQuestion(
            iconName: "QuestionIcon4",
            title: "Bir şehri gezerken hangisi seni daha çok heyecanlandırır?",
            options: [
                QuizOption(title: "Eyfel Kulesi, Kolezyum gibi herkesin bildiği ikonik yapıları görmek", value: "iconic"),
                QuizOption(title: "Turistlerin bilmediği, yerel halkın takıldığı gizli sokakları ve kafeleri bulmak", value: "hidden_gem")
            ],
            insight: "\"Mainstream\" (popüler) mekanlar ile \"Niche/Hidden Gem\" (gizli kalmış) mekanların öneri algoritmasındaki ağırlığını belirler."
        ),
        QuizQuestion(
            iconName: "QuestionIcon5",
            title: "Senin için ideal konaklama deneyimi hangisidir?",
            options: [
                QuizOption(title: "Her şey dahil, dışarı çıkmama gerek kalmayan büyük bir resort", value: "resort"),
                QuizOption(title: "Şehrin merkezinde, şık tasarımlı bir butik otel", value: "boutique_hotel"),
                QuizOption(title: "Yerel biri gibi hissedebileceğim bir Airbnb / Ev", value: "airbnb"),
                QuizOption(title: "Doğayla iç içe bir kamp çadırı, karavan veya glamping", value: "camping")
            ],
            insight: "Konaklama API'lerinden çekilecek verilerin filtrelenmesi için doğrudan parametre sağlar."
        ),
        QuizQuestion(
            iconName: "QuestionIcon6",
            title: "Seyahatlerindeki günlük tempon nasıldır?",
            options: [
                QuizOption(title: "Sabah erkenden kalkar, güne en az 4-5 lokasyon sığdırırım. (Hızlı)", value: "fast"),
                QuizOption(title: "Acele etmem, bir kafede oturup etrafı izleyerek yavaşça gezerim. (Yavaş)", value: "slow"),
                QuizOption(title: "Gündüzleri dinlenir, geceleri dışarı çıkarım. (Gececi)", value: "night_owl")
            ],
            insight: "Yapay zekanın günlük plana ekleyeceği durak sayısını belirler. Hızlı tempo için yoğun bir rota, yavaş tempo için daha az duraklı, aralıklı bir rota çizilir."
        ),
        QuizQuestion(
            iconName: "QuestionIcon7",
            title: "Seyahatlerinde yemek konusu senin için ne ifade ediyor?",
            options: [
                QuizOption(title: "Seyahatin kendisi! Sokak lezzetlerinden lüks restoranlara her şeyi denerim.", value: "foodie"),
                QuizOption(title: "Sadece doymak için yerim, bildiğim ve güvenli lezzetleri (pizza, burger vb.) tercih ederim.", value: "familiar"),
                QuizOption(title: "Sağlıklı, vegan/vejetaryen veya belirli diyetlere uygun yerler ararım.", value: "diet_specific")
            ],
            insight: "Mekan önerilerinde \"Yerel Mutfak\", \"Uluslararası Zincirler\" veya \"Özel Diyet\" filtrelerini aktif hale getirir."
        ),
        QuizQuestion(
            iconName: "QuestionIcon8",
            title: "Gittiğin yerde nasıl seyahat etmeyi seversin?",
            options: [
                QuizOption(title: "Toplu taşıma ve yürüyüş (Şehrin içine karışmak)", value: "public_transport"),
                QuizOption(title: "Araç kiralama veya taksi/Uber (Konfor ve bağımsızlık)", value: "private_transport"),
                QuizOption(title: "Rehberli grup turlarına katılmak (Bilgi almak ve sosyalleşmek)", value: "guided_tours")
            ],
            insight: "Rota oluştururken yürüme mesafelerini ve ulaşım aracı önerilerini optimize eder."
        ),
        QuizQuestion(
            iconName: "QuestionIcon9",
            title: "Uçağın rötar yaptı veya planladığın tur iptal oldu. Tepkin ne olur?",
            options: [
                QuizOption(title: "Çok stres olurum, hemen alternatif bir plan yapmaya çalışırım.", value: "stressed"),
                QuizOption(title: "Fırsat bu fırsat der, havalimanında veya çevrede yeni bir şeyler keşfederim.", value: "adaptable")
            ],
            insight: "Kullanıcının risk ve stres toleransını ölçer. Stresli kişi için yapay zeka planlara her zaman \"Yedek (B) Planı\" eklemeli ve garanti rotalar çizmelidir."
        ),
        QuizQuestion(
            iconName: "QuestionIcon10",
            title: "Hayalindeki tatili tek bir kelimeyle özetlemen gerekseydi, bu ne olurdu?",
            options: [
                QuizOption(title: "Huzur", value: "peace"),
                QuizOption(title: "Heyecan", value: "excitement"),
                QuizOption(title: "Lüks", value: "luxury"),
                QuizOption(title: "Kültür", value: "culture_word")
            ],
            insight: "Kullanıcının tatil algısını tek kelimede özetleyen özet profil etiketini belirler."
        )
    ]
}
