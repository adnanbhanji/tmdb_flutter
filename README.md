# TMDB Flutter App

A feature-rich Flutter application that uses The Movie Database (TMDB) API to provide users with information about movies, TV shows, and actors.

## Features

- 🎬 Browse trending movies and TV shows
- 🔍 Search for movies, TV shows, and actors
- ⭐ Rate movies and maintain a personal rating history
- 📑 Create and manage a watchlist
- 🌓 Dark/Light theme support
- 🎭 Detailed cast information and filmography
- 📺 Streaming service availability
- 🔒 Secure API key management with .env
- 🎯 Content ratings and additional movie/show details

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/yourusername/tmdb_flutter.git
```

2. Create a `.env` file in the root directory and add your TMDB API key:

```
TMDB_API_KEY=your_api_key_here
```

3. Install dependencies

```bash
flutter pub get
```

4. Run the app

```bash
flutter run
```

## Architecture

- Provider for state management
- GoRouter for navigation
- Dio for API requests
- SharedPreferences for local storage
- CachedNetworkImage for efficient image loading

## Screenshots

[Add your screenshots here]

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for their excellent API
- Flutter team for the amazing framework
- All the package authors used in this project
