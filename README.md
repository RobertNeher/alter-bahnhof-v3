# alter-bahnhof-v3

A full-stack implementation for booking of events for Alter Bahnhof, basing upon MongoDB, FLutter, and a REST-based application server.

# Architecture
MongoDB for persistencee (will be a cloud instance when ready for production).
A pure Dart layer provides a REST service on top of MongoDB:
![Architecture of this ecosystem](./assets/Architekur%20Buchungssystem.png)

Following parts are on client level.

## Management
Modify, duplicate, or delete booking entries.

# Major Components
## data_migration
A simple Dart-based command line tool to migrate the CSV export of CalendarApp.
The CSV file must be imported to Google Sheet or MS Excel, by specification of semicolon ";" as delimiter and exported to CSV file again, due to buggy utf-8 id of original (PHP based)
Finally this export file is the source for migration tool.

## server
REST-layer on top of MongoDB persistence service.
In fact it is ca ommand-line tool implemented in Dart.

## modules
### settings
All general settings and paramteres are managed at this service (needs refactoring towards SharedPreferences or a separate REST service)
No Material data may get part of configuration. The REST API service will fail which uses this package as well.

## model
### booking
Handling data around bookings, like weekdays, booking states, holiday names (only national ones) etc.

### user
Handling data around admintrative users.

### status
For future handling a mini workflow engine, triggering scripts during state transitions.

# Progress
29.06.2021 #0.0.1 running with
- REST-based persistence layer
- null safety
- migration tool from CalendarApp to MongoDB
- Color and text scheme for "Alter Bahnhof" following the UI guidelines: https://docs.google.com/document/d/12IIGbA9dxBxu4mlzkCkeuJE03daElEcX2OKBm0xkH7A/edit?usp=sharing

# Planned
- I10n support
