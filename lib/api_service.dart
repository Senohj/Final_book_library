import 'dart:convert';
import 'package:http/http.dart' as http;
import 'book.dart';

class ApiService {
  static const String baseUrl = 'https://67524889d1983b9597b5c5f4.mockapi.io/Books_libraryV1';

  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  static Future<void> addBook(String id, String title, String author) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': id,
        'title': title,
        'author': author,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add book');
    }
  }

  static Future<void> updateBook(String id, String title, String author) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'author': author,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update book');
    }
  }

  static Future<void> deleteBook(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete book');
    }
  }
}
