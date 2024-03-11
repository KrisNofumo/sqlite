import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite/modelo.dart';
import 'package:sqlite/main.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db"; 
  static const _databaseVersion = 1;

  static const table = 'my_table';
  
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge= 'age';

  late Database _db;
}

Future <void> init() async {
  final path;
  if(kIsWeb) {
    path = "/assets/db";
  } else {
    final documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    path = join(documentsDirectory, _databaseName);
  }
  // Crear y abrir la BD
  _db = await openDatabase(
    path,
    version = _databaseVersion,
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child: center(
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Insert',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(size.width * 0.4, 45),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Select',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(size.width * 0.4, 45),
                      ),
                    ),
          ),
                  ],
      )
                );
  }
}

void _insert(BuildContext context) async {
  final name = TextEditingController();
  final age = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Insertar nuevo usuario'),
        content Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nombre'),
            TextFormField(),
            const SizedBox(height:20,),
            Text('Anios(int)'),   
            TextFormField(),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () {
            Navigator.of(context).pop();
          }
          , child: const Text(
             'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(60, 45),
                      ),),
          TextButton(onPressed: () async {
            //JSON
            Map<String, dynamic> row = {
              DatabaseHelper.columnName: name.text,
              DatabaseHelper.columnAge: int.parse(age.text)
            };
            final id = await dbHelper.insert(row);

            debugPrint('insert row id: $id');

            Navigator.of(context).pop();
          }
          , child: const Text(
             'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(60, 45),
                      ),)
        ],
      ),
    },
  ),
}

void _select() async {
  final allRows = await dbHelper.queryAllRows();
  debugPrint('query all rows');
  for(final row in allRows) {
    debugPrint(row.toString());
  }
}

Future<int> insert(Map<String, dynamic> row) async {
  return await _db.insert(table, row);
} 

Future<List<Map<String, dynamic>>> queryAllRows() async {
  return await _db.query(table);
}
// insert delete