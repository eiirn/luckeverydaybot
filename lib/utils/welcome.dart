// Function to generate the welcome message
String generateWelcomeMessage([String? name]) => '''
🌟 <b>Welcome to StarLuck Draw${name != null ? ', $name' : ''}!</b> 🌟

Join our daily lucky draw by sending star payments to this bot. Here's how it works:

- Send stars to enter the daily draw
- More stars = higher chance of winning
- Daily winner selected at 12:00 UTC
- Winner receives the prize pool (minus 10-15% fee)

Send your first star payment to join today's draw! Good luck! ✨
''';
