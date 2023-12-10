import 'package:keuanganku/database/model/data_wallet.dart'; // Ganti dengan lokasi file yang benar
import 'package:sqflite/sqflite.dart';

class SQLDataPemasukan {
  Future createTable(Database db) async {
    await db.execute(SQLDataPemasukan().sqlCreateQuery);
  }

  final Map<String, Map<String, String>> _table = {
    "id": {
      "name": "id",
      "type": "INTEGER",
      "constraint": "AUTO INCREMENT PRIMARY KEY",
    },
    "id_kategori": {
      "name": "id_kategori",
      "type": "INTEGER",
      "constraint": "NOT NULL",
    },
    "id_wallet": {
      "name": "id_wallet",
      "type": "INTEGER",
      "constraint": "NOT NULL",
    },
    "waktu": {
      "name": "waktu",
      "type": "TEXT",
      "constraint": "NOT NULL",
    },
    "judul": {
      "name": "judul",
      "type": "TEXT",
      "constraint": "",
    },
    "deskripsi": {
      "name": "deskripsi",
      "type": "TEXT",
      "constraint": "",
    },
    "nilai": {
      "name": "nilai",
      "type": "REAL",
      "constraint": "",
    },
  };

  final _tableName = "data_pemasukan";
  
  String get sqlCreateQuery {
    String columns = "";
    _table.forEach((key, value) {
      columns += "${value['name']} ${value['type']} ${value['constraint']}, ";
    });

    // Hapus spasi dan koma pada baris terakhir
    columns = columns.substring(0, columns.length - 2);

    return """
      CREATE TABLE IF NOT EXISTS $_tableName (
        $columns
      )
    """;
  }


  // READ METHODS
  Future<List<DataWallet>> readWithClause({required String clause, required Database db}) async {
    final List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: clause,
    );
    List<DataWallet> data = [];
    for (final result in results) {
      data.add(DataWallet.fromMap(result));
    }
    return data;
  }

  Future<List<DataWallet>> readDataByMonth(int year, int month, {required Database db}) async {
    String formattedMonth = month < 10 ? '0$month' : '$month';
    String startDate = '$year-$formattedMonth-01';
    String endDate = '$year-$formattedMonth-31'; // Sesuaikan dengan bulan tertentu

    List<Map<String, dynamic>> results = await db.rawQuery(
      "SELECT * FROM $_tableName WHERE strftime('%Y-%m-%d', waktu) BETWEEN '$startDate' AND '$endDate'"
    );

    List<DataWallet> data = results.map((map) => DataWallet.fromMap(map)).toList();
    return data;
  }

  Future<List<DataWallet>> readDataByDate(DateTime tanggal, {required Database db}) async {
    String formattedDate = tanggal.toIso8601String().substring(0, 10);
    List<Map<String, dynamic>> results = await db.rawQuery(
      "SELECT * FROM $_tableName WHERE waktu LIKE '$formattedDate%'"
    );

    List<DataWallet> data = results.map((map) => DataWallet.fromMap(map)).toList();
    return data;
  }

  Future<List<DataWallet>> readDataByYear(int year, {required Database db}) async {
    List<Map<String, dynamic>> results = await db.rawQuery(
      "SELECT * FROM $_tableName WHERE strftime('%Y', waktu) = '$year'"
    );

    List<DataWallet> data = results.map((map) => DataWallet.fromMap(map)).toList();
    return data;
  }

  // CREATE METHODS
  Future<int> create(DataWallet data, Database db) async {
    return 
    await db.rawInsert(
      "INSERT INTO $_tableName(id_kategori, id_wallet, waktu, judul, deskripsi, nilai) VALUES(?,?,?,?,?,?)", 
      [data.id_kategori, data.id_wallet, data.waktu.toIso8601String(), data.judul, data.deskripsi, data.nilai]
    );
  }
}
