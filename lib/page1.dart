import 'package:a_7_1/main.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';



class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [_buildTop(), _buildMiddle(), _buildBottom()]);
  }

  Widget _buildTop() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTaxiMenu(),
            _buildTaxiMenu(),
            _buildTaxiMenu(),
            _buildTaxiMenu(),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTaxiMenu(),
            _buildTaxiMenu(),
            _buildTaxiMenu(),
            _buildTaxiMenu(visible: false),
          ],
        ),
      ],
    );
  }

  Widget _buildTaxiMenu({bool visible = true}) {
    return Opacity(
      opacity: visible ? 1.0 : 0.0,
      child: InkWell(
        onTap: () {},
        child: Column(
          children: <Widget>[Icon(Icons.local_taxi, size: 40), Text('택시')],
        ),
      ),
    );
  }

  Widget _buildMiddle() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
      ),
      items: dummyItems.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }


  Widget _buildBottom() {
    final items = List.generate(10, (i) {
      return ListTile(
        leading: Icon(Icons.notifications_none),
        title: Text('[이벤트] 이것은 공지사항입니다.'),
      );
    });

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children : items,
    );
  }
}