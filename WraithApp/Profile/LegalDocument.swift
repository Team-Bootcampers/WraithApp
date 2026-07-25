//
//  LegalDocument.swift
//  WraithApp
//
//  Created by Onur on 25.07.2026.
//

import Foundation

struct LegalSection {
    let heading: String
    let body: String
}

struct LegalDocument {
    let title: String
    let lastUpdated: String
    let intro: String
    let sections: [LegalSection]
}

extension LegalDocument {

    static let privacyPolicy = LegalDocument(
        title: "Gizlilik Politikası",
        lastUpdated: "Son güncelleme: 25 Temmuz 2026",
        intro: "Voya olarak seyahat kimliğini keşfetmen için verdiğin bilgilere değer veriyoruz. Bu politika, hangi verileri topladığımızı, bunları neden kullandığımızı ve haklarını nasıl koruduğumuzu açıklar.",
        sections: [
            LegalSection(
                heading: "1. Topladığımız Bilgiler",
                body: "Hesabını oluştururken paylaştığın ad, e-posta adresi gibi bilgileri; karakter analizi anketine verdiğin cevapları ve seyahat tercihlerini; uygulamayı nasıl kullandığına dair cihaz ve etkileşim verilerini topluyoruz."
            ),
            LegalSection(
                heading: "2. Bilgilerin Kullanım Amacı",
                body: "Topladığımız veriler; sana özel seyahat kimliği ve önerileri oluşturmak, yapay zeka analizini geliştirmek, uygulama deneyimini iyileştirmek ve hesabınla ilgili önemli bildirimleri iletmek amacıyla kullanılır."
            ),
            LegalSection(
                heading: "3. Bilgilerin Paylaşımı",
                body: "Kişisel verilerini üçüncü taraflara satmayız. Verilerin yalnızca hizmeti sağlamamıza yardımcı olan analiz ve altyapı sağlayıcılarıyla, gizlilik yükümlülüklerine bağlı kalınarak sınırlı biçimde paylaşılabilir."
            ),
            LegalSection(
                heading: "4. Veri Güvenliği",
                body: "Verilerini yetkisiz erişime, kayba veya kötüye kullanıma karşı korumak için makul teknik ve idari güvenlik önlemleri uyguluyoruz. Ancak internet üzerinden hiçbir aktarımın veya saklama yönteminin %100 güvenli olmadığını unutma."
            ),
            LegalSection(
                heading: "5. Çerezler ve Benzer Teknolojiler",
                body: "Uygulama içi tercihlerini hatırlamak ve deneyimini kişiselleştirmek için yerel depolama ve benzeri teknolojiler kullanabiliriz. Bu teknolojileri cihaz ayarların üzerinden yönetebilirsin."
            ),
            LegalSection(
                heading: "6. Haklarınız",
                body: "Verilerine erişme, düzeltme, silinmesini talep etme ve işlenmesine itiraz etme hakkına sahipsin. Bu taleplerini uygulama içinden hesabını kapatarak ya da bizimle iletişime geçerek iletebilirsin."
            ),
            LegalSection(
                heading: "7. Veri Saklama Süresi",
                body: "Kişisel verilerini, hesabın aktif olduğu sürece ve yasal yükümlülüklerimizi yerine getirmek için gerekli olan süre boyunca saklarız. Hesabını sildiğinde verilerin makul bir süre içinde kaldırılır."
            ),
            LegalSection(
                heading: "8. Politika Değişiklikleri",
                body: "Bu politikayı zaman zaman güncelleyebiliriz. Önemli değişikliklerde seni uygulama içinden bilgilendireceğiz. Güncel sürüm her zaman bu ekranda yer alır."
            ),
            LegalSection(
                heading: "9. İletişim",
                body: "Gizliliğinle ilgili sorularını uygulama içindeki destek kanallarımız üzerinden bize iletebilirsin."
            )
        ]
    )

    static let termsOfUse = LegalDocument(
        title: "Kullanım Koşulları",
        lastUpdated: "Son güncelleme: 25 Temmuz 2026",
        intro: "Voya'yı kullanarak aşağıdaki koşulları kabul etmiş olursun. Lütfen uygulamayı kullanmadan önce bu koşulları dikkatlice oku.",
        sections: [
            LegalSection(
                heading: "1. Koşulların Kabulü",
                body: "Voya'ya erişerek veya uygulamayı kullanarak bu kullanım koşullarına ve gizlilik politikamıza uymayı kabul edersin. Koşulları kabul etmiyorsan uygulamayı kullanmamalısın."
            ),
            LegalSection(
                heading: "2. Hizmetin Tanımı",
                body: "Voya, verdiğin cevapları analiz ederek sana özel bir seyahat kimliği ve kişiselleştirilmiş öneriler sunan yapay zeka destekli bir seyahat asistanıdır. Önerilerimiz bilgilendirme amaçlıdır, rezervasyon garantisi taşımaz."
            ),
            LegalSection(
                heading: "3. Hesap Oluşturma ve Sorumluluklar",
                body: "Hesap oluştururken verdiğin bilgilerin doğru ve güncel olmasından sen sorumlusun. Hesap bilgilerinin gizliliğini korumak ve hesabın altında gerçekleşen tüm etkinliklerden sorumlu olmak senin yükümlülüğündür."
            ),
            LegalSection(
                heading: "4. Kullanım Kuralları",
                body: "Uygulamayı yasa dışı amaçlarla, başkalarının haklarını ihlal edecek şekilde veya hizmetin işleyişini bozacak biçimde (tersine mühendislik, otomatik veri toplama vb.) kullanamazsın."
            ),
            LegalSection(
                heading: "5. Fikri Mülkiyet",
                body: "Voya'nın markası, tasarımı, içerikleri ve yazılımı Voya'ya aittir ve fikri mülkiyet yasalarıyla korunur. Önceden yazılı izin olmadan kopyalanamaz veya dağıtılamaz."
            ),
            LegalSection(
                heading: "6. Üçüncü Taraf Hizmetler",
                body: "Uygulama, seyahat rezervasyonu veya içerik sağlayan üçüncü taraf hizmetlere yönlendirme yapabilir. Bu hizmetlerin içeriğinden ve uygulamalarından Voya sorumlu değildir."
            ),
            LegalSection(
                heading: "7. Sorumluluğun Sınırlandırılması",
                body: "Yapay zeka tarafından üretilen seyahat önerileri, sunulan bilgilerin analizine dayanır ve kesinlik garanti etmez. Voya, önerilere dayanarak alınan kararlardan doğabilecek zararlardan sorumlu tutulamaz."
            ),
            LegalSection(
                heading: "8. Hesabın Sonlandırılması",
                body: "Kullanım koşullarını ihlal etmen durumunda hesabını askıya alma veya sonlandırma hakkımızı saklı tutarız. Hesabını istediğin zaman ayarlar üzerinden kendin de kapatabilirsin."
            ),
            LegalSection(
                heading: "9. Koşullardaki Değişiklikler",
                body: "Bu koşulları zaman zaman güncelleyebiliriz. Güncellenmiş koşullar uygulama üzerinden yayımlandığı andan itibaren geçerli olur; uygulamayı kullanmaya devam etmen güncel koşulları kabul ettiğin anlamına gelir."
            ),
            LegalSection(
                heading: "10. İletişim",
                body: "Bu koşullarla ilgili sorularını uygulama içindeki destek kanallarımız üzerinden bize iletebilirsin."
            )
        ]
    )
}
