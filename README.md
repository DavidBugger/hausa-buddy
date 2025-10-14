
# 🗣️ HausaBuddy — Learn Hausa the Smart Way

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.13-blue)](https://flutter.dev/)
[![Django](https://img.shields.io/badge/Django-4.2-green)](https://www.djangoproject.com/)

## � Table of Contents

- [🚀 Project Overview](#-project-overview)
- [🎯 Core Objectives](#-core-objectives)
- [🧠 Key Features](#-key-features)
- [🧩 Tech Stack](#-tech-stack)
- [🗂️ Folder Structure](#%EF%B8%8F-folder-structure-flutter)
- [🧱 Django Models Overview](#-django-models-overview)
- [🔌 API Endpoints](#-api-endpoints-sample)
- [⚙️ Getting Started](#%EF%B8%8F-getting-started)
- [🧭 Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [💼 About the Project Lead](#-about-the-project-lead)
- [🏆 License](#-license)

# �🗣️ HausaBuddy — Learn Hausa the Smart Way

> **Empowering communication through technology and culture.**  
> HausaBuddy is an intelligent language learning platform designed to help users — especially corps members, travelers, and professionals — learn the **Hausa language** quickly and interactively through AI-powered features like **Text-to-Speech, Quizzes, Audio Lessons, and Chat-based Learning**.

---

## 🚀 Project Overview

The **HausaBuddy App** is a mobile learning solution aimed at preserving and promoting the Hausa language while making it accessible to a global audience.  
Built with **Flutter (for mobile)** and **Django (for backend APIs)**, the app combines **AI** and **linguistic data** to deliver a modern, engaging, and culturally rich learning experience.

---

## 🎯 Core Objectives

- Bridge the communication gap for non-Hausa speakers living or working in Northern Nigeria.  
- Digitize and preserve the Hausa dialect in an engaging, mobile-first format.  
- Provide **AI-assisted conversational practice** to accelerate real-life fluency.  
- Support offline learning for users in low-connectivity areas.

---

## 🧠 Key Features

| Feature | Description |
|----------|-------------|
| 🔑 **User Authentication** | Secure sign up & login using email or Google OAuth. |
| 📚 **Lessons Module** | Structured lessons with native pronunciations & translations. |
| 🔊 **Audio Playback** | Learn correct pronunciation through text-to-speech. |
| 🧩 **Quizzes & Assessments** | Reinforce learning through interactive tests. |
| 💬 **AI Chat Tutor** | Engage in real-time Hausa conversation practice. |
| 🔖 **Bookmarks & Progress Tracking** | Save favorite words & track learning milestones. |
| 🛰️ **Offline Mode** | Continue learning without internet connectivity. |

---

## 🧩 Tech Stack

**Frontend:** Flutter (Dart)  
**Backend:** Django REST Framework  
**Database:** PostgreSQL  
**AI Services:** Google Text-to-Speech API, OpenAI Whisper (Speech Recognition)  
**Hosting:** DigitalOcean / AWS  
**Version Control:** Git + GitHub  
**API Testing:** Postman  

---

## 🗂️ Folder Structure (Flutter)

```

HausaBuddy_app/
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── widgets/
│   ├── models/
│   ├── services/
│   └── utils/
├── assets/
│   ├── audio/
│   ├── images/
│   └── fonts/
├── pubspec.yaml
└── README.md

```

---

## 🧱 Django Models Overview

- **Lesson** — title, description, audio, category  
- **Quiz** — question, options, correct_answer  
- **Bookmark** — user, lesson  
- **UserProgress** — user, lesson, completed  
- **ChatSession** — user, AI assistant conversation logs  

---

## 🔌 API Endpoints (Sample)

| Endpoint | Method | Description |
|-----------|---------|-------------|
| `/api/auth/register/` | POST | Register new users |
| `/api/auth/login/` | POST | Authenticate users |
| `/api/lessons/` | GET | Fetch all Hausa lessons |
| `/api/lessons/<id>/` | GET | Retrieve a single lesson |
| `/api/quizzes/` | GET | Get quiz questions |
| `/api/chat/` | POST | Interact with AI tutor |

> Full documentation: [Postman Collection](./docs/HausaBuddy.postman_collection.json)

---

## ⚙️ Getting Started

### Backend Setup (Django)

```bash
# Clone repository
git clone https://github.com/<your-username>/HausaBuddy.git
cd HausaBuddy/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Start development server
python manage.py runserver
````

### Frontend Setup (Flutter)

```bash
cd ../HausaBuddy_app
flutter pub get
flutter run
```

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Report Bugs**: File an issue if you find any bugs
2. **Suggest Features**: Share your ideas for new features
3. **Submit Pull Requests**: Help us improve the codebase
4. **Improve Documentation**: Help make our docs better
5. **Spread the Word**: Share HausaBuddy with others

Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### 🛠️ Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🧭 Roadmap

* [x] Project wireframe & API structure
* [x] Django models & serializers setup
* [ ] AI Chat Tutor integration
* [ ] Offline support implementation
* [ ] Launch beta on Play Store
* [ ] Add multi-language support

---

## 💼 About the Project Lead

**👤 Abdulsalam Usman (Dev Dave)**
Full-Stack Developer | AI & EdTech Innovator | Founder of HausaBuddy
📍 Abuja, Nigeria

* 🌐 [LinkedIn](https://linkedin.com/in/abdulsalamusman)
* 💻 [Portfolio](https://urdata.com.ng)
* 📧 [devdaveofficial@gmail.com](mailto:devdaveofficial@gmail.com)

---

## 🏆 License

This project is licensed under the **MIT License** — free for learning and open collaboration.

---

### ❤️ Contribute

Contributions, feedback, and feature suggestions are welcome!
Please create an issue or submit a pull request to help us improve **HausaBuddy**.

---

> *“Preserving language, promoting culture, empowering people — one word at a time.”*

