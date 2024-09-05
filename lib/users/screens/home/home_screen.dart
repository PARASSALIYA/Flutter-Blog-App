import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blog_app/constants/constants.dart';
import 'package:flutter_blog_app/users/screens/home/drawer_screen.dart';
import 'create_blog_screen.dart';
import 'blog_detail_screen.dart';
import 'package:flutter_blog_app/models/blog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _blogs =
      FirebaseFirestore.instance.collection('blogs');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<List<Blog>> getBlogs() {
    return FirebaseFirestore.instance
        .collection('blogs')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Blog.fromDocument(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blogs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
        leading: Builder(builder: (context) {
          return IconButton(
            iconSize: 30,
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GestureDetector(
              onTap: () {
                // Open profile screen
                Navigator.pushNamed(context, "/profile");
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: const AssetImage("assets/images/profile.jpg"),
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.only(left: 35, right: 35, top: 20, bottom: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Blogs',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune_sharp),
                  onPressed: () {
                    // Implement filter functionality
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _blogs.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final blogs = snapshot.data?.docs ?? [];

                // Filter blogs based on search query
                final filteredBlogs = blogs.where((blog) {
                  final title = blog['title']?.toString().toLowerCase() ?? '';
                  return title.contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredBlogs.length,
                  itemBuilder: (context, index) {
                    final blog = filteredBlogs[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: blog['imageUrl'] != null &&
                                blog['imageUrl'].isNotEmpty
                            ? Image.network(blog['imageUrl'],
                                width: 60, height: 100, fit: BoxFit.cover)
                            : const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                        title: Text(
                          blog['title'] ?? 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By ${blog['author'] ?? 'Unknown Author'}'),
                            Text('${blog['readingTime']} Min Read'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${blog['views']} Views'),
                            Text('${blog['comments']} Comments'),
                          ],
                        ),
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlogDetailScreen(blog: blog.id),
                            ),
                          );*/
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      drawer: DrawerScreen(selectedIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateBlogScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _listTile({required String title, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(left: 20, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(50)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.drawerBackground),
        ),
        leading: Icon(
          icon,
          color: AppColors.drawerBackground,
        ),
      ),
    );
  }
}
