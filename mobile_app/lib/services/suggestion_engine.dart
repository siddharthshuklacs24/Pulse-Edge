import '../core/constants.dart';

// 🔥 UPGRADED UX: Humanized, Action-Oriented Coaching
String generateSuggestion(double risk, String activity, double strain, String alertLevel) {
  
  // 🚨 1. CRITICAL STATE (Immediate Danger / Max Exertion Reached)
  if (alertLevel == ALERT_CRITICAL) {
    if (activity == ACTIVITY_RUNNING || activity == ACTIVITY_WALKING) {
      return "⚠️ Exertion limit reached! Stop moving, sit down, and rest immediately.";
    }
    return "⚠️ Critical strain detected. Please stop all physical activity and rest.";
  }

  // ⚠️ 2. ELEVATED STATE (Warning / Stamina Bar Almost Full)
  if (alertLevel == ALERT_ELEVATED) {
    if (activity == ACTIVITY_RUNNING) {
      return "You are pushing your safe limits. Slow down to a walk to recover.";
    }
    if (activity == ACTIVITY_WALKING) {
      return "Your strain is rising. Find a place to sit and take a 2-minute break.";
    }
    return "Strain is unusually high for resting. Focus on deep, slow breaths.";
  }

  // ✅ 3. STABLE STATE (Safe / General Coaching)
  // At this point, the user is not in immediate danger. We coach them based on their baseline risk.
  if (risk >= 0.70) {
    if (activity == ACTIVITY_SITTING) return "Your baseline risk is high. When moving, keep a slow, steady pace.";
    return "Keep your movements light and avoid sudden sprints.";
  } 
  
  if (risk >= 0.40) {
    if (activity == ACTIVITY_SITTING) return "You're safe. A light 5-minute walk is good for circulation.";
    if (activity == ACTIVITY_WALKING) return "Great pace. Keep it steady and don't overexert.";
    return "Moderate risk profile. Ensure you take breaks if you feel winded.";
  } 
  
  // Low Risk Profiles
  if (activity == ACTIVITY_SITTING) {
    return "Heart rate stable. Try to get some light steps in every hour.";
  } else if (activity == ACTIVITY_RUNNING) {
    return "Looking good! Your heart handles this intensity well.";
  }
  
  return "All vitals are stable. You're doing great.";
}