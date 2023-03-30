import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/edit_products_screen.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageURL;
  UserProductItem({
    Key key,
    @required this.title,
    @required this.id,
    @required this.imageURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageURL),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id);
            },
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).primaryColor,
            ),
          ),
          IconButton(
            onPressed: () {
              Provider.of<Products>(context, listen: false).deleteProduct(id);
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
