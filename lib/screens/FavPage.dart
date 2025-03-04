import 'package:e_shop_igl/screens/DetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites(); // Fetch favorites when the page is loaded
  }

  /// Fetch favorites from the database
  Future<void> _fetchFavorites() async {
    try {
      final response = await Supabase.instance.client
          .from('favorites')
          .select()
          .order('created_at');
      setState(() {
        _favorites = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load favorites: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Delete favorite item from the database
  Future<void> _deleteFromFavorites(int deviceId) async {
    try {
      final response = await Supabase.instance.client
          .from('favorites')
          .delete()
          .eq('device_id', deviceId); // Assuming `device_id` is the identifier

      if (response.error == null) {
        setState(() {
          _favorites
              .removeWhere((favorite) => favorite['device_id'] == deviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from favorites!')),
        );
      } else {
        throw response.error!.message;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(child: Text('No favorites added yet.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 6 / 7,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    return _buildFavoriteCard(favorite);
                  },
                ),
    );
  }

  // Function to build a single favorite card
  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image for the favorite item
          Expanded(
            child: favorite['image_url'] != null
                ? Image.network(
                    favorite['image_url'],
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.device_unknown,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
          // Favorite item details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite['name'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Type: ${favorite['type'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Price: \$${favorite['price'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Show Details button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the details screen (if needed)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceDetailsPage(
                      device: favorite,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Show Details'),
            ),
          ),
          // Delete from favorites button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Delete the item from favorites
                _deleteFromFavorites(favorite['device_id']);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                iconColor: Colors.red, // Red button for delete
              ),
              child: Text('Delete from Favorites'),
            ),
          ),
        ],
      ),
    );
  }
}
