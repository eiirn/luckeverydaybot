# Cash Splash Bot 🌟

A Telegram bot that creates daily lucky draws for users. Players send stars to enter the pool, and every day at 23:59 UTC, a winner is randomly selected to receive the pooled prize (minus a small platform fee).

## Features

- 💫 Daily lucky draw system
- 💰 User balance management
- 🎟️ Fair random winner selection
- 📊 Transaction tracking
- 🏆 User statistics and history
- 👥 Referral system
- 🔄 Real-time updates with Supabase

## Technology Stack

- **Backend**: Dart (core)
- **Database**: [Supabase](https://supabase.com/)
- **Bot Framework**: [Televerse](https://pub.dev/packages/televerse)

## Setup

### Prerequisites

- Dart SDK
- Supabase account and project
- Telegram Bot Token (from [@BotFather](https://t.me/BotFather))

### Environment Setup

1. Clone the repository
   ```bash
   git clone https://github.com/eiirn/luckeverydaybot.git
   cd luckeverydaybot
   ```

2. Install dependencies
   ```bash
   dart pub get
   ```

3. Create a `.env` file in the root directory. Check the [.env.sample](./.env.sample) file.

### Database Setup

1. Check the `lib/models/` to create a db structure matching it.

### Running the Bot

```bash
dart run bin/main.dart
```

## Database Schema

### Users Table
Tracks user information and statistics.

### Transactions Table
Records all star transfers between users and the bot.

### Pool Table
Manages daily pool entries and winners.

## Bot Commands

- `/start` - Start the bot and get a welcome message
- `/join` - To join today's pool
- `/today` - View today's stats (winnings, participations, etc.)
- `/help` - Get help with bot usage
- `/invite` - Get your referral link

## How It Works

1. Users send stars to the bot to participate in the daily pool
2. Each star sent is recorded as a transaction
3. At 23:59 UTC, the bot randomly selects a winner
4. The winner receives the pool prize minus the platform fee (15%)
5. A new pool starts for the next day

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Televerse](https://pub.dev/packages/televerse) - Telegram Bot API framework for Dart
- [Supabase](https://supabase.com/) - Open source Firebase alternative