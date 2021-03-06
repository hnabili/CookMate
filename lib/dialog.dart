import 'package:flutter/material.dart';

/*
  File: dialog.dart
  Functionality: This class defines the popup that is displayed when an item 
  is not found in our UPC. It displays a popup that informs the user that the 
  item could not be found and to try entering the item manually
*/

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Consts.padding),
      ),      
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

dialogContent(BuildContext context) {
  return Stack(
    children: <Widget>[
      Container(
        padding: EdgeInsets.only(
        top: Consts.padding,
        bottom: Consts.padding,
        left: Consts.padding,
        right: Consts.padding,
        ),
        decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(Consts.padding),
        boxShadow: [
          BoxShadow(
          color: Colors.black26,
          blurRadius: 10.0,
          offset: const Offset(0.0, 10.0),
          ),
         ],
          ),
        child: Column(
         mainAxisSize: MainAxisSize.min, // To make the card compact
         children: <Widget>[
         Text(
           title,
            style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
             ),
          ),
         SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: 16.0,
            ),
            ),
        SizedBox(height: 24.0),
        Align(
          alignment: Alignment.center,
          child: FlatButton(
           onPressed: () {
            try{
             Navigator.of(context).pop(); // To close the dialog
            } catch (e) {}
            
           },
          child: Text(buttonText),
            ),
          ),
       ],
       ),
       ),
      //...top circlular image part,
    ],
  );
}
}
class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}