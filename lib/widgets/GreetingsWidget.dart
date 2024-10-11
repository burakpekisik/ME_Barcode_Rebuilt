// greeting_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final String greetingMessage = _getRandomGreetingMessage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Sola dayalı içerik
      children: [
        const Text(
          'Mektup Evi',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.left, // Sola hizalanmış metin
        ),
        const SizedBox(height: 5),
        Text(
          greetingMessage,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.left, // Sola hizalanmış metin
        ),
      ],
    );
  }

  // Function to get a randomized greeting message based on the time of day
  String _getRandomGreetingMessage() {
    List<String> morningMessages = [
      "Günaydın! ☀️ Bugün harika bir gün olacak, inan bana! 🌟",
      "Merhaba! 😊 Her şey gönlünce olsun! 💫",
      "İyi sabahlar! ☀️ Bugün umut dolu bir gün seni bekliyor! 🌸",
      "Sabahın güzelliğiyle birlikte mutlu bir gün dilerim! 🌅",
      "Yeni bir gün, yeni bir başlangıç! 🕊️ Enerjini topla ve günün tadını çıkar! 🌞",
      "Gün doğdu! ☀️ Hayatında güzel şeyler olsun! 💐",
      "Sabahın neşesiyle dolup taşman dileğiyle! 😇 Mutlu günler! 🌼",
      "Günaydın! Bugün küçük bir mucize seni bekliyor olabilir! 🌸✨",
      "Sabahların tazeliğiyle güzel haberler alman dileğiyle! 📬☀️",
      "Kahveni al, güne enerji dolu başla! ☕ Günün harika geçsin! 🌟",
      "PITTTIIIIRCIIIIIIIIIIKKKK 🚗"
    ];

    List<String> afternoonMessages = [
      "İyi günler! 🌞 Güzel şeyler seni bulsun bugün! 🌼",
      "Selam! 😊 Umarım günün harika geçiyordur! 💪",
      "Güzel bir öğle sonrası dilerim! 🌟 Başarılar seninle olsun! 💼",
      "Tebessüm et! 😊 Geriye harika anılar bırak! 🌸",
      "Öğle vakti enerji dolu ol! 💪 Her şey gönlünce olsun! 🌿",
      "Günün en verimli saatleri geldi! 🌞 İyi işler yapmanı dilerim! 💼",
      "Bir ara ver ve kendini ödüllendir! ☕ Günün geri kalanı harika geçsin! 🌟",
      "Gün ortasında biraz rahatla ve kendine zaman ayır! 🧘‍♂️ İyi hisler seninle! 💖",
      "Bu öğleden sonra güzel sürprizlerle dolu olabilir! 🎉 Tadını çıkar! 🌸",
      "Merhaba! 😊 Yeni fırsatlar seni bekliyor olabilir, gözlerini açık tut! 👀🌟",
      "PITTTIIIIRCIIIIIIIIIIKKKK 🚗"
    ];

    List<String> eveningMessages = [
      "İyi akşamlar! 🌙 Umarım günün güzel geçmiştir! 💖",
      "Akşamın huzuru seninle olsun! 🌠 Mutlu anlar dilerim! 😊",
      "Selam! 👋 Bu akşam harika şeyler yapacağına eminim! 💪",
      "Güzel bir akşam geçirmen dileğiyle! 🌙 Rahatla ve dinlen! 🛋️",
      "Yorgunluklarını bırak ve gecenin huzuruna kapıl! 🌌 Mutlu akşamlar! 😊",
      "Akşam oldu! Günün tüm güzelliklerini içinde biriktir ve dinlen! 🌙✨",
      "Akşamın dinginliğiyle kendine zaman ayır, mükemmel bir akşam senin olsun! 🍃🌙",
      "İyi akşamlar! Günün yorgunluğunu at ve güzel anılar biriktir! 💖",
      "Güneş batıyor ama güzel anılar yeni başlıyor! 🌅 İyi akşamlar! ✨",
      "Akşamları sevdiklerinle geçirmek gibisi yok! 🏡 Mutlu bir akşam geçirmen dileğiyle! 💖",
      "PITTTIIIIRCIIIIIIIIIIKKKK 🚗"
    ];

    List<String> nightMessages = [
      "İyi geceler! 🌙 Rüya gibi bir uyku dilerim! 💫",
      "Gecenin huzuru üzerinizde olsun! 🌌 Yarın harika şeyler seni bekliyor! 🌟",
      "Tatlı rüyalar! 💤 Yarın için enerji depola! 🌟",
      "Yıldızlar kadar parlak bir gelecek dilerim! 🌠 İyi geceler! 😴",
      "Geceyi huzurla geçir, rüyaların en güzeli seninle olsun! 🌙✨",
      "Gecenin dinginliğinde huzur bulman dileğiyle! 🌌 İyi geceler! 😇",
      "Gözlerini kapat, yeni bir günün güzelliklerine hazırlan! 💤 Yarın senin günün olacak! 🌟",
      "İyi geceler! 🌙 Sevgi dolu rüyalar seninle olsun! 🌸✨",
      "Geceye bir tebessümle veda et! 😊 Yarın yeni fırsatlar seni bekliyor olacak! 🌟",
      "Tatlı uykular! 😴 Yeni bir günün ışıkları seni mutlu etsin! 🌄",
      "PITTTIIIIRCIIIIIIIIIIKKKK 🚗"
    ];

    List<String> selectedMessages;

    // Get current hour
    int currentHour = DateTime.now().hour;

    // Select greeting message based on time of day
    if (currentHour >= 6 && currentHour < 12) {
      selectedMessages = morningMessages;
    } else if (currentHour >= 12 && currentHour < 18) {
      selectedMessages = afternoonMessages;
    } else if (currentHour >= 18 && currentHour < 22) {
      selectedMessages = eveningMessages;
    } else {
      selectedMessages = nightMessages;
    }

    // Randomize the message
    Random random = Random();
    int index = random.nextInt(selectedMessages.length);
    return selectedMessages[index];
  }
}