import '../models/food_item.dart';

class DummyData {
  static const List<FoodItem> foodItems = [
    FoodItem(
      id: 1,
      name: 'Nasi Campur Ayam Betutu Khas Gilimanuk',
      merchant: 'Warung Men Runtu',
      price: 35000,
      rating: 4.8,
      reviews: 124,
      distance: 0.8,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5baJlq75-nm2NfayTcSdH6RcZx9Sh2Qsxc96spyteCZFUmqZ_Ew07u_OkPPslO1AFJupBxO1L0oYS5kzT92zt9ajAIRleZy04ocXdvw4L0FW8H6QFCbEcpU3VXUWtNk6wr7zaBst9Mm8aw3pj1Nf9lu3iCbLlH6tgitbRK-n1zg_eP6L6CpJIv9rqyiMODJKReiglTclJxpPmC3EKwPARc--yG80djbwF7Hs1CNWmdoVlHccA6OLWpWLIxI1R0nj8HCmqU-ESeQgX',
      tags: ['Halal'],
    ),
    FoodItem(
      id: 2,
      name: 'Sate Lilit Ikan Tenggiri Premium',
      merchant: 'Sate Lilit Pak Doble',
      price: 25000,
      rating: 4.9,
      reviews: 312,
      distance: 1.2,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCk0ICVnHQLhTSfLjYU5MIl4gchX39_eqkVv5l-TBVEzYxbB3aeL6ZZ7Xogl34XRHwrcBuhbTvfy2vPY-Hte572wgzMap8yJEFfP0uvuIkcBW5z5QSaRPGKN-EgY00AGhgHR6e-LwT0GfJlCcTliWTvcKWh21OIypMBz7l8OqW5F9i7l8t-1ICrTgr8Xh2MZt1GBXs62tog6y_nkZ36PDwCug_Tro7Un_2XOS5FjxD7mjksEhb0qobdIvCFZYg4Rs5kaFx1xHBBA-e0',
      tags: ['Local Favorite'],
    ),
    FoodItem(
      id: 3,
      name: 'Paket Jaja Klepon & Laklak Hangat',
      merchant: 'Pasar Sindu Sanur',
      price: 15000,
      rating: 4.6,
      reviews: 89,
      distance: 2.5,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO3bxf0bdiENfzdF_qSC7OoR7xmh1RNtcKO1TyC45ejx4tkaHZW_4m_qGMMoLq_9SpLQTo23XZ7-hKjba-Z75li7TlwM893Y9uct3DiV5mQY9iRTqY1I4QGpPCLLD3Dtl7uoKwtMi9YQw6xD5ZFx2aCb1GO8P_qE0A4iofV-Flu8v51eWKoYeYGSuFV56QUMsVdZhEVQnnwCP0Jwuutg6o3JohaIeyZZ3h51eNDXupnkAuuUcYwCS3zJXnRJ3IYhV8ZWUgyNnqaSkb',
      tags: ['Jajanan Bali'],
    ),
    FoodItem(
      id: 4,
      name: 'Es Daluman Gula Aren Asli',
      merchant: 'Kedai Kopi & Es Bali',
      price: 12000,
      rating: 4.7,
      reviews: 210,
      distance: 3.1,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuARb6L-zczajcs-wTuoZl2ZxF9I_sjGdgrpTxXp5JlWQPOfts6shxQiauYY6nkXM0zfycrqCZOMhASk_ojyghxJ_FDrxKvQaF-c0dvLZVyASPa_K3XXNX-hPTlVXFZjVmp6PDTeXp1IHx4FqLNpYKtNzxCYrC1m2MWQoJkJH5TmVby82CbKvGLG9M442Mie2IFVYvUvug8JjP8tD06YosYA5EqKlPfE3bD5ZpF_iT5JaqcVWJiEXrzSE3otQGY8yWWrW-qNfyhjOD4g',
      tags: [],
    ),
    FoodItem(
      id: 5,
      name: 'Babi Guling Khas Bali Pak Maha',
      merchant: 'Warung Babi Guling Maha',
      price: 45000,
      rating: 4.9,
      reviews: 450,
      distance: 1.5,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5baJlq75-nm2NfayTcSdH6RcZx9Sh2Qsxc96spyteCZFUmqZ_Ew07u_OkPPslO1AFJupBxO1L0oYS5kzT92zt9ajAIRleZy04ocXdvw4L0FW8H6QFCbEcpU3VXUWtNk6wr7zaBst9Mm8aw3pj1Nf9lu3iCbLlH6tgitbRK-n1zg_eP6L6CpJIv9rqyiMODJKReiglTclJxpPmC3EKwPARc--yG80djbwF7Hs1CNWmdoVlHccA6OLWpWLIxI1R0nj8HCmqU-ESeQgX',
      tags: ['Halal'],
    ),
    FoodItem(
      id: 6,
      name: 'Ayam Betutu Asli Gilimanuk',
      merchant: 'Ayam Betutu Bu Lina',
      price: 30000,
      rating: 4.7,
      reviews: 280,
      distance: 2.1,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCk0ICVnHQLhTSfLjYU5MIl4gchX39_eqkVv5l-TBVEzYxbB3aeL6ZZ7Xogl34XRHwrcBuhbTvfy2vPY-Hte572wgzMap8yJEFfP0uvuIkcBW5z5QSaRPGKN-EgY00AGhgHR6e-LwT0GfJlCcTliWTvcKWh21OIypMBz7l8OqW5F9i7l8t-1ICrTgr8Xh2MZt1GBXs62tog6y_nkZ36PDwCug_Tro7Un_2XOS5FjxD7mjksEhb0qobdIvCFZYg4Rs5kaFx1xHBBA-e0',
      tags: ['Local Favorite'],
    ),
    FoodItem(
      id: 7,
      name: 'Nasi Jinggo Spesial',
      merchant: 'Nasi Jinggo Kuta',
      price: 10000,
      rating: 4.5,
      reviews: 156,
      distance: 0.5,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO3bxf0bdiENfzdF_qSC7OoR7xmh1RNtcKO1TyC45ejx4tkaHZW_4m_qGMMoLq_9SpLQTo23XZ7-hKjba-Z75li7TlwM893Y9uct3DiV5mQY9iRTqY1I4QGpPCLLD3Dtl7uoKwtMi9YQw6xD5ZFx2aCb1GO8P_qE0A4iofV-Flu8v51eWKoYeYGSuFV56QUMsVdZhEVQnnwCP0Jwuutg6o3JohaIeyZZ3h51eNDXupnkAuuUcYwCS3zJXnRJ3IYhV8ZWUgyNnqaSkb',
      tags: ['Jajanan Bali'],
    ),
    FoodItem(
      id: 8,
      name: 'Jus Alpukat Segar',
      merchant: 'Jus Buah Segar Denpasar',
      price: 8000,
      rating: 4.8,
      reviews: 98,
      distance: 1.8,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuARb6L-zczajcs-wTuoZl2ZxF9I_sjGdgrpTxXp5JlWQPOfts6shxQiauYY6nkXM0zfycrqCZOMhASk_ojyghxJ_FDrxKvQaF-c0dvLZVyASPa_K3XXNX-hPTlVXFZjVmp6PDTeXp1IHx4FqLNpYKtNzxCYrC1m2MWQoJkJH5TmVby82CbKvGLG9M442Mie2IFVYvUvug8JjP8tD06YosYA5EqKlPfE3bD5ZpF_iT5JaqcVWJiEXrzSE3otQGY8yWWrW-qNfyhjOD4g',
      tags: [],
    ),
    FoodItem(
      id: 9,
      name: 'Sate Plecing Arjuna',
      merchant: 'Sate Plecing Pak Gede',
      price: 20000,
      rating: 4.6,
      reviews: 187,
      distance: 3.5,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5baJlq75-nm2NfayTcSdH6RcZx9Sh2Qsxc96spyteCZFUmqZ_Ew07u_OkPPslO1AFJupBxO1L0oYS5kzT92zt9ajAIRleZy04ocXdvw4L0FW8H6QFCbEcpU3VXUWtNk6wr7zaBst9Mm8aw3pj1Nf9lu3iCbLlH6tgitbRK-n1zg_eP6L6CpJIv9rqyiMODJKReiglTclJxpPmC3EKwPARc--yG80djbwF7Hs1CNWmdoVlHccA6OLWpWLIxI1R0nj8HCmqU-ESeQgX',
      tags: ['Local Favorite'],
    ),
    FoodItem(
      id: 10,
      name: 'Dadar Gulung Rasa Coklat',
      merchant: 'Toko Jajanan Tradisional',
      price: 5000,
      rating: 4.9,
      reviews: 310,
      distance: 2.0,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO3bxf0bdiENfzdF_qSC7OoR7xmh1RNtcKO1TyC45ejx4tkaHZW_4m_qGMMoLq_9SpLQTo23XZ7-hKjba-Z75li7TlwM893Y9uct3DiV5mQY9iRTqY1I4QGpPCLLD3Dtl7uoKwtMi9YQw6xD5ZFx2aCb1GO8P_qE0A4iofV-Flu8v51eWKoYeYGSuFV56QUMsVdZhEVQnnwCP0Jwuutg6o3JohaIeyZZ3h51eNDXupnkAuuUcYwCS3zJXnRJ3IYhV8ZWUgyNnqaSkb',
      tags: ['Jajanan Bali'],
    ),
  ];
}
