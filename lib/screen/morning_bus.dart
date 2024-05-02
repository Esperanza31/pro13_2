import 'package:flutter/material.dart';
import 'package:mini_project_five/pages/get_bus_time.dart';
import 'package:mini_project_five/pages/busdata.dart';
import 'package:mini_project_five/pages/location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:mini_project_five/pages/map_page.dart';
import 'package:mini_project_five/screen/morning_bus.dart';

class BusPage extends StatefulWidget {

  final Function(int) updateSelectedBox;

  BusPage({required this.updateSelectedBox});
  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {
  int selectedBox = 0;
  LocationService _locationService = LocationService();
  Map_Page _map_page = Map_Page();

  void updateSelectedBox(int box){
    setState(() {
      selectedBox = box;
    });
    widget.updateSelectedBox(box);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => updateSelectedBox(1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 60,
                      color:
                      selectedBox == 1 ? Colors.blueAccent : Colors.grey,
                      // Change color based on selection
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'King Albert Station',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => updateSelectedBox(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 60,
                      color:
                      selectedBox == 2 ? Colors.blueAccent : Colors.grey,
                      // Change color based on selection
                      child: Center(
                        child: Text(
                          'Clementi Station',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        BusTimeFunctions.getBusTime(selectedBox == 1
            ? KTABus1ArrivalTime
            : CLTBus1ArrivalTime),
        SizedBox(height: 16),
      ],
    );
  }
}


