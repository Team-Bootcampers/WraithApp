//
//  sorular.swift
//  WraithApp
//
//  Created by CAN SAGNAK on 25.07.2026.
//
/*
1. Seyahat Motivasyonu
Soru: Yeni bir seyahat planladığında asıl amacın hangisi olur?

A) Gündelik stresten uzaklaşıp tamamen dinlenmek

B) Yeni kültürler, müzeler ve tarihi yerler keşfetmek

C) Adrenalin, doğa ve yeni maceralar yaşamak

D) İyi yemek, eğlence ve gece hayatının tadını çıkarmak

Yapay Zeka Çıkarımı: Kullanıcının temel rotasını belirler. Önerilecek destinasyonun "Deniz/Kum/Güneş", "Kültür Turu" veya "Macera" olup olmayacağına karar verir.

2. Planlama Tarzı
Soru: Tatil planlarını ne kadar detaylı yaparsın?

A) Uçak ve oteli alırım, gerisi tamamen doğaçlama gelişir.

B) Görülecek ana yerleri belirlerim ama esnek bir programım olur.

C) Saat saat nerede olacağım, nerede yemek yiyeceğim önceden bellidir.

Yapay Zeka Çıkarımı: Yapay zekanın kullanıcıya sunacağı planın detay seviyesini ayarlar. A kişisine sadece "Gidilebilecek 5 yer" listesi verilirken, C kişisine "09:00 Kahvaltı, 10:30 Müze" şeklinde dakik bir takvim sunulmalıdır.

3. Bütçe Önceliği
Soru: Seyahat bütçeni en çok hangi kaleme harcamaktan keyif alırsın?

A) Konforlu ve lüks bir konaklama

B) Michelin yıldızlı restoranlar veya popüler yerel lezzetler

C) Müze girişleri, turlar ve özel aktiviteler

D) Alışveriş ve hediyelik eşyalar

Yapay Zeka Çıkarımı: Kullanıcının harcama alışkanlıklarını profiller. "Ucuz bilet" arayan biri mi yoksa "Kalite için para harcamaktan çekinmeyen" biri mi olduğunu anlar.

4. Keşif Yaklaşımı
Soru: Bir şehri gezerken hangisi seni daha çok heyecanlandırır?

A) Eyfel Kulesi, Kolezyum gibi herkesin bildiği ikonik yapıları görmek

B) Turistlerin bilmediği, yerel halkın takıldığı gizli sokakları ve kafeleri bulmak

Yapay Zeka Çıkarımı: "Mainstream" (popüler) mekanlar ile "Niche/Hidden Gem" (gizli kalmış) mekanların öneri algoritmasındaki ağırlığını belirler.

5. Konaklama Tercihi
Soru: Senin için ideal konaklama deneyimi hangisidir?

A) Her şey dahil, dışarı çıkmama gerek kalmayan büyük bir resort

B) Şehrin merkezinde, şık tasarımlı bir butik otel

C) Yerel biri gibi hissedebileceğim bir Airbnb / Ev

D) Doğayla iç içe bir kamp çadırı, karavan veya glamping

Yapay Zeka Çıkarımı: Konaklama API'lerinden çekilecek verilerin filtrelenmesi için doğrudan parametre sağlar.

6. Seyahat Temposu
Soru: Seyahatlerindeki günlük tempon nasıldır?

A) Sabah erkenden kalkar, güne en az 4-5 lokasyon sığdırırım. (Hızlı)

B) Acele etmem, bir kafede oturup etrafı izleyerek yavaşça gezerim. (Yavaş)

C) Gündüzleri dinlenir, geceleri dışarı çıkarım. (Gececi)

Yapay Zeka Çıkarımı: Yapay zekanın günlük plana ekleyeceği durak sayısını belirler. Hızlı tempo için yoğun bir rota, yavaş tempo için daha az duraklı, aralıklı bir rota çizilir.

7. Yemek Kültürü
Soru: Seyahatlerinde yemek konusu senin için ne ifade ediyor?

A) Seyahatin kendisi! Sokak lezzetlerinden lüks restoranlara her şeyi denerim.

B) Sadece doymak için yerim, bildiğim ve güvenli lezzetleri (pizza, burger vb.) tercih ederim.

C) Sağlıklı, vegan/vejetaryen veya belirli diyetlere uygun yerler ararım.

Yapay Zeka Çıkarımı: Mekan önerilerinde "Yerel Mutfak", "Uluslararası Zincirler" veya "Özel Diyet" filtrelerini aktif hale getirir.

8. Sosyal Tercih ve Ulaşım
Soru: Gittiğin yerde nasıl seyahat etmeyi seversin?

A) Toplu taşıma ve yürüyüş (Şehrin içine karışmak)

B) Araç kiralama veya taksi/Uber (Konfor ve bağımsızlık)

C) Rehberli grup turlarına katılmak (Bilgi almak ve sosyalleşmek)

Yapay Zeka Çıkarımı: Rota oluştururken yürüme mesafelerini ve ulaşım aracı önerilerini optimize eder.

9. Beklenmedik Durumlara Tepki
Soru: Uçağın rötar yaptı veya planladığın tur iptal oldu. Tepkin ne olur?

A) Çok stres olurum, hemen alternatif bir plan yapmaya çalışırım.

B) Fırsat bu fırsat der, havalimanında veya çevrede yeni bir şeyler keşfederim.

Yapay Zeka Çıkarımı: Kullanıcının risk ve stres toleransını ölçer. A kişisi için yapay zeka planlara her zaman "Yedek (B) Planı" eklemeli ve garanti rotalar çizmelidir.

10. İdeal Tatilin Özeti
Soru: Hayalindeki tatili tek bir kelimeyle özetlemen gerekseydi, bu ne olurdu?

A) Huzur

B) Heyecan

C) Lüks

D) Kültür
*/
