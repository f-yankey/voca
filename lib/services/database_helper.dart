import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io' as io;
import '../models/device_contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  static Database _db;

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "voca.db");
    var vocaDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return vocaDb;
  }

  void _onCreate(Database db, int version) async {
    String syncedContactCreationQuery =
        "CREATE TABLE SyncedContact(id INTEGER PRIMARY KEY, DisplayName TEXT, PhoneNumber TEXT)";
    String vocaMessagesQuery =
        "CREATE TABLE VocaMessages(id INTEGER PRIMARY KEY, Sender TEXT, Recipient TEXT, TimeSent TEXT,TimeReceived TEXT)";
    await db.execute(syncedContactCreationQuery).then((result) {
      db.execute(vocaMessagesQuery);
    });

    print("Database initialized");
  }

  Future<bool> saveSyncedContact(List<DeviceContact> _syncedContacts) async {
    List<DeviceContact> availableSyncedContacts = [];
    List<DeviceContact> newContacts = [];
    List<DeviceContact> incomingContacts = _syncedContacts;
    var dbClient;
    bool alreadyExists = false;
    DeviceContact incomingContact;
    bool result;

    dbClient = await db;
    availableSyncedContacts = await retrieveSyncedContact();

    if (availableSyncedContacts.length > 0) {
      incomingContacts.forEach((incomingCon) {
        availableSyncedContacts.forEach((syncCon) {
          incomingContact = incomingCon;

          print(incomingCon.getComparableValue() +
              " >against< " +
              syncCon.getComparableValue());
          if (syncCon.getComparableValue() ==
              incomingContact.getComparableValue()) {
            alreadyExists = true;

            print(syncCon.getComparableValue().toString() + " ALREADY EXISTS");
          }
        });

        if (!alreadyExists) {
          newContacts.add(incomingContact);
        }

        print('Resetting alreadyExists');
        //RESETTING alreadyExists
        alreadyExists = false;
      });

      print("New contacts lenght: " + newContacts.length.toString());
      print(newContacts);
      print('About to do Inserting =><<<<<<<<<<<<<<<< ');

      if (newContacts.length > 0) {
        print('>>>>>>>>>>>>>>>>>>> Inserting =><<<<<<<<<<<<<<<< ');
        newContacts.forEach((contact) {
          print('Inserting => ' + contact.phoneNumber);
          dbClient.insert("SyncedContact", contact.toMap()).then((data) {
            result = true;
            print('RESULT OF ENTRY: ' + result.toString());
          });
        });
        return result;
      } else {
        print('Nothing to  INSERT INTO DB ');
        result = true;
      }
    } else {
      _syncedContacts.forEach((data) {
        var numResult = dbClient.insert("SyncedContact", data.toMap());
        print('RESULT OF ENTRY: ' + numResult.toString());
      });
      result = true;
    }

    return result;
  }

  Future<List<DeviceContact>> retrieveSyncedContact() async {
    print('FETCHING FROM DB');
    List<DeviceContact> savedSyncedContacts = [];
    var dbClient = await db;
    var result = await dbClient
        .query("SyncedContact", columns: ['id', 'DisplayName', 'PhoneNumber']);

    result.toList().forEach((res) {
      DeviceContact contact = DeviceContact.fromMap(res);
      savedSyncedContacts.add(contact);
      // print(contact.nameLeadingAlphabet + ' ===>> ' + contact.displayName);
    });

    return savedSyncedContacts;
  }

  Future<DeviceContact> getContact(String _phoneNumber) async {
    var dbClient = await db;
    var result;
    dbClient
        .rawQuery(
            'SELECT * FROM SyncedContact WHERE PhoneNumber = $_phoneNumber')
        .then((data) {
      result = data;
      print('database result:');
      print(result);
    });

    if (result == null) {
      return null;
    }

    return DeviceContact.fromMap(result.first);
  }
}
