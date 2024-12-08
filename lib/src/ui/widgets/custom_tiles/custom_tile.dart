import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';


class SimpleTile extends StatelessWidget {
  final String title;
  final IconData? leading;
  final IconData? trailing;
  final Function? onTap;
  
  Color getColorText() {
    return ThemeController.instance.brightnessValue 
    ? Colors.black
    :Colors.white;
  }

  SimpleTile({ Key? key, this.title ="",this.leading,this.trailing,this.onTap}) 
  : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ()=>onTap,
      title: Text(title, style: TextStyle(color: getColorText())),
      leading: Icon(leading, color: getColorText()),
      trailing: trailing!=null ? Icon(trailing, color: Colors.grey) : SizedBox(),
    );
  }
}

class ImageTile extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final Function? onTap;
  
  Color getColorText() {
    return ThemeController.instance.brightnessValue 
    ? Colors.black
    :Colors.white;
  }

  ImageTile({ Key? key, 
  this.title ="",
  this.image="https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Imagen_no_disponible.svg/480px-Imagen_no_disponible.svg.png",
  this.description="",
  this.onTap}) 
  : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ()=>onTap,
      title: Text(title, style: TextStyle(color: getColorText())),
      leading: CircleAvatar(backgroundImage: NetworkImage(image),),
      subtitle: Text(description, style: TextStyle(color: Colors.blueGrey),),
    );
  }
}
