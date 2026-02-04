Tamamen Yapay zeka kullanarak bir mobil uygulama yaptıracağım, aşağıda istediğim uygulamayı açıkladım. Senden isteğim sırasıyla 3 tane çok detaylı en optimal promptu oluşturman olacak. Yani 3 adımda uygulamayı eksiksiz yapmış olmalıyım. Promptların sonucunda elimde çalışan, hatasız, en optimal şekilde kodlanmış bir mobil uygulama olmalı. Promptları hazırlarken her zaman güncel paketleri yüklemesi gerektiğini ve bu paketlerin güncel sürümlerini kontrol ederek yüklemesi gerektiğini de bildirmelisin. 
1. Prompt: Stitch ai'ın en iyi ekran tasarımlarını oluşturması için detaylı prompt yazmalısın. Stitch ai'ın oluşturduğu Ekran tasarımlarının hepsini bir dosyaya atacağım, ikinci promptumda bu tasarımları kullanmasını uymasını isteyeceğim.
2. Prompt: Stitch ai'ın oluşturduğu ekran tasarımlarını kullanarak uygulamanın frontendini tamamen eksiksiz hatasız en optimal şekilde kodlamasını isteyeceğim. Bu promptu Google Antigravity'deki claude opus 4.5 modeline vereceğim. Çok detaylı bir prompt olmalı. Planning modunu kullanacağım, yani önce plan yapacak, sonra ben "Proceed" butonuna tıkladığımda kodlamaya başlayacak.
3. Prompt: Uygulamanın backendini tamamen eksiksiz hatasız en optimal şekilde kodlamasını isteyeceğim. Bu promptu Google Antigravity'deki claude opus 4.5 modeline vereceğim(2. promptu yazdığım chat ile aynı chatte devam edeceğim bu prompt ile). Çok detaylı bir prompt olmalı. Planning modunu kullanacağım, yani önce plan yapacak, sonra ben "Proceed" butonuna tıkladığımda kodlamaya başlayacak.

Uygulamanın amacı: Not defteri, not kaydetmek, notları görüntülemek, yani kısaca bir not uygulaması. Flutter ile yapacağız.

Notlar için veritabanı: sqflite paketi kullan. 
bottom bar için: google_nav_bar 
zengin bir not düzenleme ekranı için, yani kısaca not ekranı için appflowy_editor paketi kullanalım.

bottom bar'da notların görüntülendiği ana sayfa ekranına ek olarak, 2. bir sayfa daha olacak graph, node, düğüm şeklinde notların önizlemesi gözükecek. 1: ana sayfa, notların görüntülendiği alan. (notu floating buton ile ekleyebilecekler) 2: graph sayfası, notların graph olarak görüntülendiği alan. 3: settings sayfası, uygulamanın ayarları alan.

Sayfalar arası/ekranlar arası geçişler cupertino kullan. settings sayfasında uygulama geneli için karanlık/aydınlık tema seçeneği olacak. bir switch ile ayarlanacak. not ekranında, notlara fotoğraf da ekleyebilelim, fotoğrafı da googlenin image picker paketi ile alabiliriz. depolama iznine gerek kalmadan.