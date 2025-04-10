import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class AddAttachmentPage extends StatelessWidget {
  const AddAttachmentPage({Key? key}) : super(key: key);

  static final ADD_ATTACHMENT_PAGE = "add_attachment_page_route";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<dynamic> images = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
                margin: EdgeInsets.all(90),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/folder.png"),
                        fit: BoxFit.contain))),
          ),
          Flexible(
            child: Column(
              children: [
                Text(
                  images.length == 0 ? "Sin Recursos" : "Mis Recursos",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: fontColor()),
                ),
                Expanded(
                  child: images.length == 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              Constants.contentAttachment,
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            MediumButton(
                                onTap: () {},
                                title: "Agregar recurso",
                                icon: Icons.add,
                                primaryColor: false)
                          ],
                        )
                      : StaggeredGridView.countBuilder(
                          physics: BouncingScrollPhysics(),
                          crossAxisCount: 2,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return _ImageCard(images[index]);
                          },
                          staggeredTileBuilder: (int index) =>
                              new StaggeredTile.count(
                                  1, index.isEven ? 1.3 : 1.9),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                        ),
                )
              ],
            ),
            flex: 1,
          )
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final image;
  const _ImageCard(this.image, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(image: DecorationImage(image: NetworkImage(image))));
  }
}
