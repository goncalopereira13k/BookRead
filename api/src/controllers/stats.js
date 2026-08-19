const db = require('../models');
const ReadingLog = db.readinglog;

module.exports = {
  getStreak: async (req, res) => {
    try {
      const user = req.user;

      // Get all reading logs for the user, ordered by date
      const readingLogs = await ReadingLog.findAll({
        where: { userId: user.id },
        attributes: ['createdAt'],
        order: [['createdAt', 'DESC']]
      });

      if (readingLogs.length === 0) {
        return res.status(200).json({
          userId: user.id.toString(),
          start: new Date().toISOString(),
          end: new Date().toISOString(),
          length: 0
        });
      }

      // Extract unique dates
      const dates = readingLogs.map(log => {
        const date = new Date(log.createdAt);
        // Check if date is valid
        if (isNaN(date.getTime())) {
          return null;
        }
        return date.toISOString().split('T')[0]; // YYYY-MM-DD format
      }).filter(date => date !== null); // Remove invalid dates

      // Remove duplicates and sort in descending order
      const uniqueDates = [...new Set(dates)].sort((a, b) => new Date(b) - new Date(a));

      if (uniqueDates.length === 0) {
        return res.status(200).json({
          userId: user.id.toString(),
          start: new Date().toISOString(),
          end: new Date().toISOString(),
          length: 0
        });
      }

      // Calculate streak from the most recent date
      let streakLength = 1;
      const today = new Date().toISOString().split('T')[0];

      // Check if the most recent log is from today or yesterday
      const mostRecentDate = new Date(uniqueDates[0]);
      const todayDate = new Date(today);
      const daysDiff = Math.floor((todayDate - mostRecentDate) / (1000 * 60 * 60 * 24));

      // If the most recent reading is more than 1 day ago, streak is broken
      if (daysDiff > 1) {
        return res.status(200).json({
          userId: user.id.toString(),
          start: new Date().toISOString(),
          end: new Date().toISOString(),
          length: 0
        });
      }

      // Count consecutive days
      for (let i = 1; i < uniqueDates.length; i++) {
        const currentDate = new Date(uniqueDates[i]);
        const previousDate = new Date(uniqueDates[i - 1]);
        const daysBetween = Math.floor((previousDate - currentDate) / (1000 * 60 * 60 * 24));

        if (daysBetween === 1) {
          streakLength++;
        } else {
          break;
        }
      }

      // Calculate start and end dates for the streak
      const endDate = new Date(uniqueDates[0]);
      const startDate = new Date(uniqueDates[streakLength - 1]);

      return res.status(200).json({
        userId: user.id.toString(),
        start: startDate.toISOString(),
        end: endDate.toISOString(),
        length: streakLength
      });
    } catch (error) {
      console.error('Error calculating streak:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  }
}
