import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite/main.dart';

///CLASE PARA LA CREACIÓN DE LA BD Y FUNCIONES DEL CRUD
class DatabaseHelper {
  static const _databaseName = "MyDatabase.db"; //NOMBRE DE SU BD
  static const _databaseVersion = 1; //VERSION DE LA BD

  static const table = 'my_table'; //NOMBRE DE LA TABLA
  //SUS ATRIBUTOS
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge = 'age';

  late Database _db; //SE CREA LA INSTANCIA DE LA BD A TRAVÉS DE SQLITE

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final path;

    ///Obtención de la dirección/path para almacenar la BD
    if (kIsWeb) {
      //Indicamos si se va abrir en web
      //Dirección en donde se guardara la BD
      path = "/assets/db"; //Local dentro de nuestra app (visible)
    } else {
      //Se almacena de forma oculta dentro de la app
      final documentsDirectory =
          (await getApplicationDocumentsDirectory()).path;
      path = join(documentsDirectory, _databaseName);
    }

    ///fin de obtención
    ///CRAER Y ABRIR LA BD
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY autoincrement,
      $columnName TEXT NOT NULL,
      $columnAge INTEGER NOT NULL
    )
  ''');
  }
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  /*Future<int> insert(Model row) async {
    try {
      return _db.insert(table, row.toJson());
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }*/

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _insert(context), //Llamado a un ALERTDIALOG
              child: const Text('insert'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _select,
              child: const Text('query'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _update,
              child: const Text('update'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _delete,
              child: const Text('delete'),
            ),
          ],
        ),
      ),
    );
  }
}

// Button onPressed methods
void _insert(BuildContext context) async {
  final name = TextEditingController();
  final age = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Insertar nuevo usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nombre'),
            TextFormField(
              controller: name,
              obscureText: false,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                  errorText: null),
              onChanged: (texto) {},
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Años(int)'),
            TextFormField(
              controller: age,
              obscureText: false,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                  errorText: null),
              onChanged: (texto) {},
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el AlertDialog
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              ///JSON
              Map<String, dynamic> row = {
                DatabaseHelper.columnName: name.text,
                DatabaseHelper.columnAge: int.parse(age.text)
              };
              final id = await dbHelper.insert(row);

              debugPrint('inserted row id: $id'); // = print("");

              Navigator.of(context).pop(); // Cerrar el AlertDialog
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}

void _select() async {
  final allRows = await dbHelper.queryAllRows();
  debugPrint('query all rows:');
  for (final row in allRows) {
    debugPrint(row.toString());
  }
}

void _update() async {
  // row to update
  Map<String, dynamic> row = {
    DatabaseHelper.columnId: 1,
    DatabaseHelper.columnName: 'Mary',
    DatabaseHelper.columnAge: 32
  };
  final rowsAffected = await dbHelper.update(row);
  debugPrint('updated $rowsAffected row(s)');
}

void _delete() async {
  // Assuming that the number of rows is the id for the last row.
  final id = await dbHelper.queryRowCount();
  final rowsDeleted = await dbHelper.delete(id);
  debugPrint('deleted $rowsDeleted row(s): row $id');
}
