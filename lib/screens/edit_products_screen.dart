import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/add_product';
  const EditProductScreen({Key key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedPoduct = Product(
    description: '',
    id: null,
    imageUrl: '',
    price: 0,
    title: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'image': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  var _isInit = true;
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedPoduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedPoduct.title,
          'description': _editedPoduct.description,
          'price': _editedPoduct.price.toString(),
          'image': '',
        };
        _imageUrlController.text = _editedPoduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editedPoduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedPoduct.id, _editedPoduct);
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedPoduct);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_priceFocusNode),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a value';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedPoduct = Product(
                      description: _editedPoduct.description,
                      id: _editedPoduct.id,
                      imageUrl: _editedPoduct.imageUrl,
                      price: _editedPoduct.price,
                      title: value,
                      isFavorite: _editedPoduct.isFavorite);
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_descriptionFocusNode),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'please enter a valide number';
                  }

                  if (double.parse(value) <= 0) {
                    return 'please enter a  number > 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedPoduct = Product(
                      description: _editedPoduct.description,
                      id: _editedPoduct.id,
                      imageUrl: _editedPoduct.imageUrl,
                      price: double.parse(value),
                      title: _editedPoduct.title,
                      isFavorite: _editedPoduct.isFavorite);
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'please enter price';
                  }

                  if ((value.length) < 10) {
                    return 'please enter a atleast  10 char';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _editedPoduct = Product(
                      description: newValue,
                      id: _editedPoduct.id,
                      imageUrl: _editedPoduct.imageUrl,
                      price: _editedPoduct.price,
                      title: _editedPoduct.title,
                      isFavorite: _editedPoduct.isFavorite);
                },
              ),
              Row(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: _imageUrlController.text.isEmpty
                        ? Text('enter a url')
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter image URL';
                        }
                        if (!value.startsWith('http') &&
                            !value.startsWith('https')) {
                          return null;
                        }
                        if (!value.endsWith('.png') &&
                            !value.endsWith('.jpg') &&
                            !value.endsWith('.jpeg')) {
                          return 'please enter valid url';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) => _saveForm(),
                      onSaved: (newValue) {
                        _editedPoduct = Product(
                            description: _editedPoduct.description,
                            id: _editedPoduct.id,
                            imageUrl: newValue,
                            price: _editedPoduct.price,
                            title: _editedPoduct.title,
                            isFavorite: _editedPoduct.isFavorite);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
