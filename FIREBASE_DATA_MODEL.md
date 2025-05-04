# Learn & Play Firebase Data Model

This document provides sample data structures for each collection in our Firestore database.

## Users Collection

```javascript
// users/{userId}
{
  "id": "user123",
  "email": "teacher@example.com",
  "name": "Ms. Johnson",
  "avatar": "https://storage.example.com/users/user123/profile/avatar.jpg",
  "role": "teacher", // or "student"
  "createdAt": Timestamp(2023-05-15),
  "enrolledClasses": ["subject456", "subject789"], // For students
  "xp": 1250,
  "coins": 75,
  "currentStreak": 5,
  "longestStreak": 12,
  "badges": ["first_game_completed", "math_master_level_1"],
  "settings": {
    "notifications": true,
    "darkMode": false,
    "soundEffects": true
  },
  "teachingSubjects": ["math", "science"], // For teachers only
  "teachingGradeYears": [3, 4, 5], // For teachers only
  "studentGradeYear": 4 // For students only
}
```

## Subjects Collection

```javascript
// subjects/{subjectId}
{
  "id": "subject456",
  "name": "4th Grade Math",
  "description": "Mathematics for 4th grade students covering arithmetic, fractions, and basic geometry",
  "gradeYear": 4,
  "teacherId": "user123",
  "studentIds": ["student1", "student2", "student3"],
  "createdAt": Timestamp(2023-05-20),
  "coverImage": "https://storage.example.com/subjects/subject456/cover.jpg",
  "tags": ["math", "elementary", "fractions"],
  "meetingSchedule": {
    "days": ["Monday", "Wednesday"],
    "time": "10:00 AM",
    "duration": 45 // minutes
  }
}
```

## Educational Games Collection

```javascript
// educational_games/{gameId}
{
  "id": "game789",
  "title": "Multiplication Challenge",
  "description": "Test your multiplication skills with this interactive quiz!",
  "coverImage": "https://storage.example.com/games/game789/cover.jpg",
  "teacherId": "user123",
  "subjectId": "subject456",
  "gradeYear": 4,
  "createdAt": Timestamp(2023-06-01),
  "dueDate": Timestamp(2023-06-15),
  "isActive": true,
  "questions": [
    {
      "id": "q1",
      "text": "What is 7 × 8?",
      "options": [
        {
          "id": "o1",
          "text": "54",
          "isCorrect": false,
          "explanation": null
        },
        {
          "id": "o2",
          "text": "56",
          "isCorrect": true,
          "explanation": "7 × 8 = 56 because 7 × 8 = 7 + 7 + 7 + 7 + 7 + 7 + 7 + 7 = 56"
        },
        {
          "id": "o3",
          "text": "58",
          "isCorrect": false,
          "explanation": null
        },
        {
          "id": "o4",
          "text": "63",
          "isCorrect": false,
          "explanation": null
        }
      ],
      "points": 10,
      "imageUrl": null,
      "timeLimit": 30 // seconds
    },
    // More questions...
  ],
  "difficulty": 3, // 1-5 scale
  "estimatedDuration": 15, // minutes
  "tags": ["multiplication", "arithmetic", "timed"],
  "maxPoints": 100
}
```

## Game Progress Collection

```javascript
// game_progress/{progressId}
{
  "id": "progress101",
  "gameId": "game789",
  "studentId": "student1",
  "subjectId": "subject456",
  "startedAt": Timestamp(2023-06-05T10:15:00),
  "completedAt": Timestamp(2023-06-05T10:28:30), // null if not completed
  "score": 80,
  "totalPossibleScore": 100,
  "completionPercentage": 80.0,
  "answers": [
    {
      "questionId": "q1",
      "selectedOptionId": "o2",
      "isCorrect": true,
      "pointsEarned": 10,
      "timeSpent": 12 // seconds
    },
    // More answers...
  ],
  "xpEarned": 40,
  "coinsEarned": 8,
  "badgesEarned": ["quick_thinker"]
}
```

## App Settings Collection

```javascript
// app_settings/{settingId}
{
  "id": "gamification",
  "xpLevels": [
    {"level": 1, "minXp": 0, "maxXp": 99},
    {"level": 2, "minXp": 100, "maxXp": 249},
    {"level": 3, "minXp": 250, "maxXp": 499}
    // More levels...
  ],
  "coinRewards": {
    "gameCompletion": 5,
    "perfectScore": 10,
    "dailyLogin": 2
  },
  "streakRewards": {
    "3days": {"xp": 15, "coins": 5},
    "7days": {"xp": 50, "coins": 15, "badges": ["weekly_streak"]},
    "30days": {"xp": 200, "coins": 50, "badges": ["monthly_streak"]}
  }
}
```

## Badges Collection

```javascript
// badges/{badgeId}
{
  "id": "math_master_level_1",
  "name": "Math Master Level 1",
  "description": "Complete 5 math games with at least 80% accuracy",
  "imageUrl": "https://storage.example.com/badges/math_master_level_1.png",
  "category": "subject",
  "conditions": {
    "gameType": "math",
    "minCompletedGames": 5,
    "minAccuracy": 80
  },
  "xpReward": 50,
  "coinReward": 15,
  "rarity": "common" // common, uncommon, rare, epic, legendary
}
```

## Analytics Collection

```javascript
// analytics/{docId}
{
  "id": "analytic123",
  "type": "subject_performance",
  "subjectId": "subject456",
  "teacherId": "user123",
  "period": "2023-06",
  "data": {
    "averageScore": 78.5,
    "totalGamesPlayed": 124,
    "completionRate": 86.2,
    "mostChallenging": "question047",
    "studentCount": 24,
    "topPerformers": ["student7", "student12", "student3"]
  },
  "timestamp": Timestamp(2023-06-30)
}
```

## User Activity Collection

```javascript
// user_activity/{logId}
{
  "id": "activity456",
  "userId": "student1",
  "activityType": "game_played",
  "subjectId": "subject456",
  "gameId": "game789",
  "timestamp": Timestamp(2023-06-05T10:15:00),
  "details": {
    "score": 80,
    "duration": 13.5, // minutes
    "deviceType": "tablet",
    "platform": "iOS"
  }
}
```

## Relationships Diagram

The following relationships exist between collections:

- `users (teacher) -> subjects` (1:many): A teacher can create multiple subjects
- `users (student) -> subjects` (many:many): A student can enroll in multiple subjects, and a subject can have multiple students
- `subjects -> educational_games` (1:many): A subject can have multiple games
- `users (teacher) -> educational_games` (1:many): A teacher creates multiple games
- `users (student) -> game_progress` (1:many): A student can have progress records for multiple games
- `educational_games -> game_progress` (1:many): A game can have progress records from multiple students
- `badges -> users` (many:many): Users can earn multiple badges 