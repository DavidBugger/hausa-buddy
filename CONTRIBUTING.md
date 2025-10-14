# Contributing to HausaBuddy

🎉 First off, thanks for taking the time to contribute! 🎉

We're excited to have you on board. This document will guide you through the process of contributing to HausaBuddy.

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [Getting Started](#-getting-started)
- [How to Contribute](#-how-to-contribute)
  - [Reporting Bugs](#-reporting-bugs)
  - [Suggesting Enhancements](#-suggesting-enhancements)
  - [Your First Code Contribution](#-your-first-code-contribution)
  - [Pull Requests](#-pull-requests)
- [Development Setup](#-development-setup)
  - [Frontend (Flutter)](#frontend-flutter)
  - [Backend (Django)](#backend-django)
- [Code Style Guide](#-code-style-guide)
  - [Dart/Flutter](#dartflutter)
  - [Python/Django](#pythondjango)
- [Commit Message Guidelines](#-commit-message-guidelines)
- [License](#-license)

## 📜 Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## 🚀 Getting Started

1. **Fork** the repository on GitHub
2. **Clone** the project to your own machine
3. **Commit** changes to your own branch
4. **Push** your work back up to your fork
5. Submit a **Pull Request** so we can review your changes

## 🤝 How to Contribute

### 🐛 Reporting Bugs 🐛

- **Ensure the bug was not already reported** by searching on GitHub under [Issues](https://github.com/DavidBugger/hausa-buddy/issues).
- If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/DavidBugger/hausa-buddy/issues/new). Be sure to include:
  - A clear and descriptive title
  - Steps to reproduce the issue
  - Expected vs actual behavior
  - Screenshots if applicable
  - Device/OS version

### 💡 Suggesting Enhancements

- Open a new issue with the **enhancement** label
- Describe the feature and why it would be useful
- Include any relevant technical details or implementation ideas

### 🛠 Your First Code Contribution

Looking for your first contribution? Look for issues with the `good first issue` or `help wanted` labels.

### 🔄 Pull Requests

1. Fork the repository and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## 🛠 Development Setup

### Frontend (Flutter)

```bash
# Install Flutter (if not already installed)
# [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

# Clone the repository
git clone [https://github.com/DavidBugger/hausa-buddy.git](https://github.com/DavidBugger/hausa-buddy.git)
cd hausa-buddy/frontend

# Get dependencies
flutter pub get

# Run the app
flutter run