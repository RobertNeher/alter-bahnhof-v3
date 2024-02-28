Map<String, dynamic> settings = {
  'mongoDBServerURI': 'mongodb://localhost:21463', // currently in container
  'mongoDatabase': 'AlterBahnhof',
  'alterBahnhofHost': 'localhost',
  'alterBahnhofPort': 13762,
  'alterBahnhofDateFormat': 'yyyy-MM-dd',
  'alterBahnhofMonthDateFormat': 'MMMM yyyy',
  // "Alter Bahnhof with secret key 'Ammertalbahnstrasse 16'",
  // provided by https://www.devglan.com/online-tools/text-encryption-decryption
  'alterBahnhofEncryptionKey': r'+mZNJvkO8gZkMe17F3k+qA==',
  'bookingsCollection': 'Bookings',
  'usersCollection': 'Users',
  'eventTypeCollection': 'EventTypes',
  'bookingStatusCollection': 'BookingStatus',
  'reservedDaysCollection': 'ReservedDays',
  'alterBahnhofStartDate': '2017-09-01',
  'certicatePath': '../server/certificates',
  'bookingYearSpan': 3, //years from today
  'weekDays': ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
  'dayBoxWidth': 50,
  'dayBoxHeight': 30,
};
