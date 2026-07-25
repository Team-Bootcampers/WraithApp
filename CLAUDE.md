# CLAUDE.md

Bu dosya, bu iOS projesinde çalışırken Claude Code'un uyması gereken kuralları tanımlar.

## Genel Prensipler

- **Sadelik esastır.** Over-engineering yapılmaz; problemi çözecek en yalın çözüm tercih edilir.
- Apple'ın önerdiği best practice'ler takip edilir (Human Interface Guidelines, Apple'ın resmi API kullanım önerileri vb.).
- **OOP, SOLID ve Clean Code** prensiplerine uyulur.
- Gereksiz soyutlama, gereksiz protokol/katman eklenmez. Kod okunabilir ve amacına uygun olmalı.
- Gerekmedikçe yorum satırı (comment) eklenmez. Kod kendini açıklamalı; yorum sadece karmaşık/kritik bir mantığı açıklamak için kullanılır.

## Mimari

- **MVVM** mimarisi kullanılır (Model - View - ViewController - ViewModel).
- **Sadece UIKit** kullanılır. SwiftUI kullanılmaz.
- **Storyboard kesinlikle kullanılmaz.** Tüm ekranlar **programmatic UI** olarak yazılır.
- Auto Layout, **NSLayoutConstraint** ile kod üzerinden kurulur (SnapKit vb. üçüncü parti layout kütüphaneleri kullanılmaz, aksi belirtilmedikçe).

## Klasör / Feature Yapısı

Her feature aşağıdaki alt klasör yapısına sahip olmalıdır:

```
FeatureName/
├── Views/
├── ViewModels/
├── Models/
└── Services/
```

- Bir feature'a ait tüm dosyalar kendi feature klasörü altında, yukarıdaki kategorilere göre konumlandırılır.
- Feature'lar birbirinin içine karışmaz; ortak/shared kod ayrı bir `Common` veya `Shared` klasöründe tutulur.

## ViewController ve Cell Kuralları

- Tüm view elemanları (`UILabel`, `UIButton`, `UIStackView` vb.) dosyanın en üstünde **`private lazy var`** olarak tanımlanır.
- Bir view elemanının tüm ayarları (frame'e bağlı olmayan stil, font, renk, corner radius, target-action vb.) bu `lazy var` closure'ı içinde yapılır — ayrı bir `configure` metoduna dağıtılmaz.
- Layout kurulumu (`addSubview`, `NSLayoutConstraint.activate`) ayrı ve düzenli bir metotta (`setupLayout`, `setupConstraints` gibi) toplanır.
- Cell'lerde gerektiği durumlarda **`prepareForReuse()`** override edilerek state ve içerik sıfırlanır (image, label text, cancel edilmesi gereken network isteği vb.).

Örnek düzen (bir ViewController için sıralama):
1. `private lazy var` ile view tanımlamaları
2. Lifecycle metotları (`viewDidLoad` vb.)
3. Layout kurulum metotları
4. Binding / ViewModel bağlantı metotları
5. Action metotları (`@objc` fonksiyonlar)

## MARK Kullanımı

- Her dosya, ilgili bölümleri ayıran `// MARK: -` ifadeleriyle düzenlenir.
- Tipik MARK bölümleri: `// MARK: - UI Components`, `// MARK: - Lifecycle`, `// MARK: - Setup`, `// MARK: - Actions`, `// MARK: - Binding` gibi anlamlı ve tutarlı isimler kullanılır.

## Networking

- Tüm network işlemleri merkezi **NetworkManager** paketi üzerinden yapılır.
- Feature'lar NetworkManager'a doğrudan erişmez; her feature kendi `Services` klasöründe bir servis (örn. `ProfileService`) tanımlar ve bu servis NetworkManager'ı kullanır.
- Veri çekme işlemleri **async/await** ile yapılır (NetworkManager paketindeki mevcut yapıya uygun şekilde).
- Completion handler tabanlı eski API kullanımından kaçınılır.

## Kod Stili Özeti

| Konu | Kural |
|---|---|
| Mimari | MVVM |
| UI Framework | UIKit (programmatic, storyboard yok) |
| Layout | NSLayoutConstraint |
| View tanımlama | `private lazy var`, dosya başında |
| Cell reuse | `prepareForReuse()` gerektiğinde override edilir |
| Klasörleme | Feature > Views / ViewModels / Models / Services |
| Network | NetworkManager paketi + feature bazlı Services, async/await |
| Yorumlar | Gerekmedikçe eklenmez |
| Kod organizasyonu | `// MARK: -` ile bölümlenir |
| Prensipler | OOP, SOLID, Clean Code |
| Claude Code hiçbir zaman simülatörü build edip çalıştırmaz veya xcodebuild komutu koşmaz, çünkü bu gereksiz token tüketir. Kod değişikliği sonrası test/doğrulama kullanıcı tarafından manuel yapılır |