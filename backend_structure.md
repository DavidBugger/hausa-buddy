learn_hausa_api/
├── manage.py
├── requirements.txt
├── .env
├── .gitignore
├── README.md
├── learn_hausa_api/
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── development.py
│   │   ├── production.py
│   │   └── testing.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   ├── __init__.py
│   ├── authentication/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── permissions.py
│   │   ├── admin.py
│   │   ├── migrations/
│   │   └── tests/
│   ├── lessons/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── admin.py
│   │   ├── migrations/
│   │   └── tests/
│   ├── quizzes/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── admin.py
│   │   ├── migrations/
│   │   └── tests/
│   ├── bookmarks/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── admin.py
│   │   ├── migrations/
│   │   └── tests/
│   ├── chat/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── consumers.py
│   │   ├── routing.py
│   │   ├── admin.py
│   │   ├── migrations/
│   │   └── tests/
│   └── common/
│       ├── __init__.py
│       ├── models.py
│       ├── serializers.py
│       ├── permissions.py
│       ├── pagination.py
│       ├── utils.py
│       └── validators.py
├── media/
│   ├── audio/
│   │   └── pronunciations/
│   ├── images/
│   │   └── lesson_icons/
│   └── uploads/
├── static/
│   ├── admin/
│   └── api/
└── docs/
├── api_documentation.md
└── deployment.md