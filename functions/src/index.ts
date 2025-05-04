import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// Scheduled function to run once per day to deactivate expired games
export const deactivateExpiredGames = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    
    // Get all active games that are past their due date
    const gamesRef = db.collection('educational_games');
    const expiredGamesSnapshot = await gamesRef
      .where('isActive', '==', true)
      .where('dueDate', '<', now)
      .get();
    
    if (expiredGamesSnapshot.empty) {
      console.log('No expired games to deactivate');
      return null;
    }
    
    // Create a batch to update all games in one go for efficiency
    const batch = db.batch();
    let count = 0;
    
    expiredGamesSnapshot.forEach((doc) => {
      batch.update(doc.ref, { isActive: false });
      count++;
    });
    
    // Commit the batch
    await batch.commit();
    console.log(`Deactivated ${count} expired games`);
    
    return null;
  });

// Firestore trigger to track student game completion and update streaks
export const updateUserStreakOnGameCompletion = functions.firestore
  .document('game_progress/{progressId}')
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();
    
    // Only proceed if the game was just completed (completedAt changed from null to a timestamp)
    if (!previousValue.completedAt && newValue.completedAt) {
      const userId = newValue.studentId;
      const userRef = db.collection('users').doc(userId);
      
      // Get the user document
      const userDoc = await userRef.get();
      if (!userDoc.exists) {
        console.log(`User ${userId} not found`);
        return null;
      }
      
      const userData = userDoc.data();
      
      // Calculate the current streak
      const lastGameDate = userData?.lastGameCompletionDate 
        ? userData.lastGameCompletionDate.toDate() 
        : null;
      const currentDate = new Date();
      const yesterday = new Date(currentDate);
      yesterday.setDate(yesterday.getDate() - 1);
      
      // Format dates to compare only year, month, and day
      const getDateString = (date: Date) => {
        return date.toISOString().split('T')[0];
      };
      
      let newStreak = userData?.currentStreak || 0;
      
      // If completed a game yesterday or today, increment streak
      if (lastGameDate) {
        const lastGameDateStr = getDateString(lastGameDate);
        const yesterdayStr = getDateString(yesterday);
        const todayStr = getDateString(currentDate);
        
        if (lastGameDateStr === yesterdayStr || lastGameDateStr === todayStr) {
          newStreak += 1;
        } else if (lastGameDateStr !== todayStr) {
          // If last game was not yesterday or today, reset streak
          newStreak = 1;
        }
      } else {
        // First game ever
        newStreak = 1;
      }
      
      // Update user with new streak and completion date
      const updates: any = {
        currentStreak: newStreak,
        lastGameCompletionDate: admin.firestore.FieldValue.serverTimestamp(),
      };
      
      // If new streak is longer than longest streak, update that too
      if (!userData?.longestStreak || newStreak > userData.longestStreak) {
        updates.longestStreak = newStreak;
      }
      
      await userRef.update(updates);
      console.log(`Updated streak for user ${userId} to ${newStreak}`);
    }
    
    return null;
  });

// Function to award badges based on user achievements
export const checkAndAwardBadges = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const previousData = change.before.data();
    
    // Skip if this update was for badges to avoid infinite loops
    if (JSON.stringify(newData.badges) !== JSON.stringify(previousData.badges)) {
      return null;
    }
    
    const userId = context.params.userId;
    const userRef = db.collection('users').doc(userId);
    
    const badgesToAward: string[] = [];
    
    // Check for XP milestones
    if (newData.xp >= 1000 && (!previousData.xp || previousData.xp < 1000)) {
      badgesToAward.push('xp_milestone_1000');
    }
    if (newData.xp >= 5000 && (!previousData.xp || previousData.xp < 5000)) {
      badgesToAward.push('xp_milestone_5000');
    }
    if (newData.xp >= 10000 && (!previousData.xp || previousData.xp < 10000)) {
      badgesToAward.push('xp_milestone_10000');
    }
    
    // Check for streak milestones
    if (newData.currentStreak >= 3 && (!previousData.currentStreak || previousData.currentStreak < 3)) {
      badgesToAward.push('streak_3_days');
    }
    if (newData.currentStreak >= 7 && (!previousData.currentStreak || previousData.currentStreak < 7)) {
      badgesToAward.push('streak_7_days');
    }
    if (newData.currentStreak >= 30 && (!previousData.currentStreak || previousData.currentStreak < 30)) {
      badgesToAward.push('streak_30_days');
    }
    
    // If we have badges to award, update the user document
    if (badgesToAward.length > 0) {
      await userRef.update({
        badges: admin.firestore.FieldValue.arrayUnion(...badgesToAward),
      });
      
      console.log(`Awarded badges to user ${userId}: ${badgesToAward.join(', ')}`);
    }
    
    return null;
  }); 