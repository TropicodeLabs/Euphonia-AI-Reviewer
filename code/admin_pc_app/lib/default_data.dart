// this class will assist in getting the appropiate database names for the usual column names
// so the user of this class will be able of getting the appropiate column name for the database
// by providing  a not parsed column name
class DefaultClipColumns {
  static const List<String> columnNames = [
    "Selection",
    "Begin File",
    "Begin Time (s)",
    "End Time (s)",
    "Low Freq (Hz)",
    "High Freq (Hz)",
    "Species Code",
    "Common Name",
    "Confidence",
    "clip_basename",
  ];

  static const List<String> databaseColumnNames = [
    "selection",
    "beginFile",
    "beginTime",
    "endTime",
    "lowFreq",
    "highFreq",
    "speciesCode",
    "commonName",
    "confidence",
    "clipBasename",
  ];

  /// Returns the database column name for a given user-friendly column name.
  /// If the column name is not found, returns null.
  static String? getDatabaseColumnName(String columnName) {
    final index = columnNames.indexOf(columnName);
    return index != -1 ? databaseColumnNames[index] : null;
  }

  static String? getColumnFriendlyName(String databaseColumnName) {
    final index = databaseColumnNames.indexOf(databaseColumnName);
    return index != -1 ? columnNames[index] : null;
  }
}
