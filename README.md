# DesktopAppTest

A Flutter project using MVVM architecture with Docker support.

## Project Structure

The project follows MVVM architecture:
- `lib/models/`: Data models
- `lib/view_models/`: Business logic and state management (Riverpod)
- `lib/views/`: UI screens and components
- `lib/utils/`: Utility functions and helpers
- `lib/services/`: Services for external data sources
- `lib/config/`: App configuration and routing
- `docs/`: Learning documentation

State management: Riverpod

## Getting Started

### Local Development
1. Run `flutter pub get` to install dependencies
2. Start the app with `flutter run`

### Docker Development
```bash
# Production build (web)
docker-compose up flutter-web

# Development with hot reload
docker-compose up flutter-dev
```

### Platform Support
- ✅ **Android**: `flutter run -d android`
- ✅ **iOS**: `flutter run -d ios` (macOS only)
- ✅ **Web**: `flutter run -d chrome`
- ✅ **Windows**: `flutter run -d windows`
- ✅ **macOS**: `flutter run -d macos`
- ✅ **Linux**: `flutter run -d linux`
- ✅ **Docker**: Production web deployment

## Learning Resources

Comprehensive Flutter learning guides are available in the `docs/` folder:
- [01-getting-started.md](docs/01-getting-started.md) - Flutter basics and setup
- [02-project-structure.md](docs/02-project-structure.md) - MVVM architecture explained
- [03-widgets-basics.md](docs/03-widgets-basics.md) - Flutter widgets fundamentals
- [04-state-management.md](docs/04-state-management.md) - Riverpod state management
- [05-building-ui.md](docs/05-building-ui.md) - Complete UI examples
- [06-navigation.md](docs/06-navigation.md) - Routing and navigation
- [07-docker-deployment.md](docs/07-docker-deployment.md) - Docker deployment guide

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Docker**: Containerization
- **MVVM**: Architecture pattern
