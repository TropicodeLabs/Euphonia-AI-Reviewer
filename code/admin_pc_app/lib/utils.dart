import 'package:csv/csv.dart';

class Utils {
  static String detectEOL(String content) {
    // Count occurrences of each newline character
    int crlfCount = '\r\n'.allMatches(content).length; // Count of \r\n
    int crCount = '\r'.allMatches(content).length -
        crlfCount; // Adjust for \r\n being counted in \r
    int lfCount = '\n'.allMatches(content).length -
        crlfCount; // Adjust for \r\n being counted in \n

    // Determine which newline character is most common
    if (crlfCount > crCount && crlfCount > lfCount) {
      return '\r\n'; // Windows style
    } else if (crCount > lfCount) {
      return '\r'; // Old Mac style
    } else {
      return '\n'; // Unix/Linux/Mac OS X style
    }
  }

  static List<List<dynamic>> convertCsvStringToListOfLists(String content) {
    String eol = detectEOL(content);

    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(content, eol: eol);

    // data validation: all rows must have the same number of columns
    int numColumns = rowsAsListOfValues.first.length;
    if (rowsAsListOfValues.any((row) => row.length != numColumns)) {
      throw Exception('All rows must have the same number of columns');
    }

    return rowsAsListOfValues;
  }
}
