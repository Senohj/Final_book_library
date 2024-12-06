import 'package:flutter/material.dart';
import 'api_service.dart';
import 'book.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = ApiService.fetchBooks();
  }

  Future<void> _showEditDialog(Book book) async {
    final TextEditingController idController = TextEditingController(text: book.id);
    final TextEditingController titleController = TextEditingController(text: book.title);
    final TextEditingController authorController = TextEditingController(text: book.author);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Author'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editBook(idController.text, titleController.text, authorController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
    final TextEditingController idController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Author'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addBook(idController.text, titleController.text, authorController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editBook(String id, String title, String author) async {
    try {
      await ApiService.updateBook(id, title, author);
      setState(() {
        futureBooks = ApiService.fetchBooks();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update book: $e')),
      );
    }
  }

  void _addBook(String id, String title, String author) async {
    try {
      await ApiService.addBook(id, title, author);
      setState(() {
        futureBooks = ApiService.fetchBooks();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book: $e')),
      );
    }
  }

  void _deleteBook(String id) async {
    try {
      await ApiService.deleteBook(id);
      setState(() {
        futureBooks = ApiService.fetchBooks();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Page'),
      ),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(snapshot.data![index].title),
                    subtitle: Text(snapshot.data![index].author),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(snapshot.data![index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteBook(snapshot.data![index].id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
