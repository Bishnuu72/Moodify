# 🏗️ Moodify Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER DEVICE                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Flutter App (Dart)                      │  │
│  │  ┌────────────────┐  ┌────────────────┐  ┌─────────────┐ │  │
│  │  │   User         │  │   Admin        │  │  Therapist  │ │  │
│  │  │   Dashboard    │  │   Dashboard    │  │  Dashboard  │ │  │
│  │  └────────┬───────┘  └────────┬───────┘  └──────┬──────┘ │  │
│  │           │                   │                  │        │  │
│  │  ┌────────▼───────────────────▼──────────────────▼────┐  │  │
│  │  │              Screens & Widgets                      │  │  │
│  │  │  - Home Screen                                      │  │  │
│  │  │  - Mood Wall                                        │  │  │
│  │  │  - New Mood Entry                                   │  │  │
│  │  │  - Wellness Tools                                   │  │  │
│  │  │  - Emotion Detection                                │  │  │
│  │  │  - Profile Management                               │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │           │                                                │  │
│  │  ┌────────▼────────────────────────────────────────┐      │  │
│  │  │          Services Layer                          │      │  │
│  │  │  ┌─────────────────┐  ┌─────────────────────┐   │      │  │
│  │  │  │ AuthService     │  │ ApiService          │   │      │  │
│  │  │  │ (Firebase Auth) │  │ (MongoDB REST API)  │   │      │  │
│  │  │  └─────────────────┘  └─────────────────────┘   │      │  │
│  │  └─────────────────────────────────────────────────┘      │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
            ▼                               ▼
┌───────────────────────┐       ┌─────────────────────────────┐
│   Firebase Console    │       │   Node.js Backend Server    │
│  ┌─────────────────┐  │       │  (Express.js + MongoDB)     │
│  │ Authentication  │  │       │  ┌───────────────────────┐  │
│  │                 │  │       │  │   API Endpoints       │  │
│  │ - Email/Pass    │  │       │  │                       │  │
│  │ - User Roles    │  │       │  │ GET  /api/moods/:id   │  │
│  │ - Session Mgmt  │  │       │  │ POST /api/moods       │  │
│  └─────────────────┘  │       │  │ PUT  /api/moods/:id   │  │
│                       │       │  │ DELETE /api/moods/:id │  │
│  ┌─────────────────┐  │       │  │                       │  │
│  │ Cloud Firestore │  │       │  │ GET  /api/users/:id   │  │
│  │ (Legacy Data)   │  │       │  │ PUT  /api/users/:id   │  │
│  │                 │  │       │  │ GET  /api/users       │  │
│  │ ⚠️ Keep as is   │  │       │  └───────────────────────┘  │
│  └─────────────────┘  │       │            │                  │
└───────────────────────┘       │  ┌─────────▼──────────────┐  │
                                │  │   Controllers          │  │
                                │  │  - moodController      │  │
                                │  │  - userController      │  │
                                │  └────────────────────────┘  │
                                │            │                  │
                                │  ┌─────────▼──────────────┐  │
                                │  │   Models (Schemas)     │  │
                                │  │  - User.js             │  │
                                │  │  - MoodEntry.js        │  │
                                │  └────────────────────────┘  │
                                └──────────────┬───────────────┘
                                               │
                                               ▼
                                    ┌─────────────────────┐
                                    │   MongoDB Atlas     │
                                    │   (Cloud Database)  │
                                    │                     │
                                    │  Collections:       │
                                    │  - users            │
                                    │  - moodentries      │
                                    │  - sessions         │
                                    │  - therapists       │
                                    └─────────────────────┘
```

---

## Data Flow Diagrams

### 1. Authentication Flow (Firebase - Unchanged)

```
┌──────────┐     Login Request      ┌─────────────┐
│  Flutter │ ─────────────────────► │  Firebase   │
│   App    │                        │  Auth       │
│          │ ◄───────────────────── │             │
└──────────┘   User Data + Token    └─────────────┘
     │
     │ Store in AppState
     ▼
┌──────────┐
│ Provider │
│ AuthService│
└──────────┘
```

### 2. Mood Creation Flow (New - MongoDB)

```
┌──────────┐   POST /api/moods    ┌─────────────┐
│  Flutter │ ───────────────────► │  Node.js    │
│   App    │   {userId, mood,     │  Backend    │
│          │    emotionScore}     │             │
└──────────┘                      └──────┬──────┘
     │                                   │
     │                                   │ Save to DB
     │                                   ▼
     │                            ┌─────────────┐
     │                            │  MongoDB    │
     │                            │  Atlas      │
     │                            └──────┬──────┘
     │                                   │
     │   {success: true, data: {...}     │
     ◄───────────────────────────────────┘
     │
     │ Update UI
     ▼
 Display Success
```

### 3. Load User Dashboard Flow

```
┌──────────┐  GET /api/moods/:userId  ┌─────────────┐
│  Flutter │ ───────────────────────► │  Node.js    │
│   App    │                          │  Backend    │
└──────────┘                          └──────┬──────┘
     │                                       │
     │                                       │ Query DB
     │                                       ▼
     │                                ┌─────────────┐
     │                                │  MongoDB    │
     │                                │  Atlas      │
     │                                └──────┬──────┘
     │                                       │
     │   [{mood1}, {mood2}, ...]             │
     ◄───────────────────────────────────────┘
     │
     │ Render List
     ▼
 Display Mood History
```

---

## Component Breakdown

### Frontend (Flutter)

#### Presentation Layer
- **Screens**: Full-page layouts (HomeScreen, MoodWallScreen, etc.)
- **Widgets**: Reusable components (MoodCard, StatCard, etc.)
- **Constants**: App-wide styling (colors, fonts, etc.)

#### Business Logic Layer
- **AuthService**: Manages Firebase authentication state
- **ApiService**: Handles HTTP requests to MongoDB backend
- **Providers**: State management (Provider package)

#### Data Access Layer
- **Firebase Auth SDK**: User authentication
- **HTTP Client**: REST API communication

### Backend (Node.js + Express)

#### API Routes
```
/api/health          → Health check
/api/moods           → CRUD operations for moods
/api/users           → User profile management
```

#### Controllers
- **moodController**: Business logic for mood entries
- **userController**: Business logic for user profiles

#### Models (Mongoose Schemas)
- **User**: User profile schema
- **MoodEntry**: Mood entry schema with timestamps

#### Middleware
- **CORS**: Cross-origin resource sharing
- **Helmet**: Security headers
- **Rate Limiter**: DDoS protection
- **Error Handler**: Global error handling

### Database (MongoDB Atlas)

#### Collections
1. **users**
   - Stores user profiles
   - Synced with Firebase Auth userId
   - Contains role, displayName, bio, etc.

2. **moodentries**
   - Stores all mood logs
   - References users via userId
   - Includes mood, score, note, tags, etc.

3. **sessions** (future)
   - Therapist session scheduling
   - Patient-therapist matching

4. **therapists** (future)
   - Therapist profiles
   - Specializations, availability

---

## Security Architecture

```
┌─────────────────────────────────────────┐
│         Security Layers                  │
├─────────────────────────────────────────┤
│ 1. Firebase Authentication              │
│    - Email/Password validation          │
│    - JWT tokens                         │
│    - Session management                 │
├─────────────────────────────────────────┤
│ 2. Backend Security (Express)           │
│    - Helmet.js (security headers)       │
│    - CORS policy                        │
│    - Rate limiting (100 req/15min)      │
│    - Input validation                   │
├─────────────────────────────────────────┤
│ 3. Database Security (MongoDB)          │
│    - IP whitelist                       │
│    - Username/password auth             │
│    - Encrypted connection (TLS)         │
│    - Role-based access control          │
└─────────────────────────────────────────┘
```

---

## Deployment Architecture (Future)

```
┌─────────────────────────────────────────────────────────┐
│                    Production Setup                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────┐                                         │
│  │   Flutter  │                                         │
│  │  Web App   │                                         │
│  └─────┬──────┘                                         │
│        │                                                 │
│  ┌─────▼──────┐     ┌─────────────┐     ┌────────────┐ │
│  │   CDN      │────►│   Backend   │────►│  MongoDB   │ │
│  │ (Web/Mob)  │     │   (Cluster) │     │  Atlas     │ │
│  └────────────┘     └─────────────┘     └────────────┘ │
│                          │                               │
│                    ┌─────▼──────┐                        │
│                    │  Firebase  │                        │
│                    │    Auth    │                        │
│                    └────────────┘                        │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Frontend** | Flutter/Dart | Cross-platform mobile app |
| **Auth** | Firebase Auth | User authentication |
| **Backend** | Node.js + Express | REST API server |
| **Database** | MongoDB Atlas | NoSQL database |
| **ODM** | Mongoose | MongoDB object modeling |
| **State Mgmt** | Provider | Flutter state management |
| **HTTP Client** | http package | API communication |
| **Security** | Helmet, CORS | Backend security |

---

## Key Design Decisions

### Why Hybrid Approach?
✅ **Firebase Auth**: Best-in-class authentication, already working perfectly  
✅ **MongoDB**: Flexible schema, better for analytics, easier queries  
✅ **Node.js**: JavaScript ecosystem, fast development, scalable  

### Why REST API?
✅ **Platform Independent**: Can add web/iOS/Android easily  
✅ **Scalable**: Stateless architecture  
✅ **Maintainable**: Clear separation of concerns  

### Why Not Only Firestore?
✅ **MongoDB Advantages**:
- Better querying capabilities
- More flexible schema evolution
- Easier analytics and aggregation
- Better for complex relationships
- Lower cost at scale

---

## Scalability Considerations

### Current Setup (Development)
- Single Node.js instance
- MongoDB Atlas shared cluster
- Direct API calls from Flutter

### Future Scaling (Production)
- Load balancer → Multiple backend instances
- MongoDB Atlas dedicated cluster
- Redis caching layer
- CDN for static assets
- Message queue for async tasks

---

## Monitoring & Logging

```
Application Logs (Backend)
├── Morgan (HTTP request logging)
├── Console errors
└── Custom loggers

Database Monitoring (MongoDB Atlas)
├── Performance metrics
├── Slow query logs
└── Connection tracking

Future Additions
├── Sentry (error tracking)
├── New Relic (APM)
└── Winston/Morgan (structured logging)
```

---

This architecture provides a solid foundation for your Moodify app with clear separation between authentication (Firebase) and data storage (MongoDB), making it scalable, maintainable, and secure!
