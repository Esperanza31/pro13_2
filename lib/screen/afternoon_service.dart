import 'package:flutter/material.dart';
import 'package:mini_project_five/pages/get_bus_time.dart';
import 'package:mini_project_five/pages/busdata.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:mini_project_five/pages/map_page.dart';
import 'package:mini_project_five/screen/evening_bus.dart';


class AfternoonService extends StatefulWidget {
  final Function(int) updateSelectedBox;

  AfternoonService({required this.updateSelectedBox});

  @override
  _AfternoonServiceState createState() => _AfternoonServiceState();
}

class _AfternoonServiceState extends State<AfternoonService> {
  int selectedBox = 0; // Default to no selection
  int? bookedTripIndexKLT;
  int? bookedTripIndexCLT;
  bool confirmationPressed = false;
  bool showBookingDetails = false;
  DateTime currentTime = DateTime.now();

  void updateSelectedBox(int box) {
    if (!confirmationPressed) {
      setState(() {
        selectedBox = box;
      });
      widget.updateSelectedBox(box);
    }
  }

  void updateBookingStatusKLT(int index, bool newValue) {
    setState(() {
      if (confirmationPressed) {
        // If confirmation is pressed, allow changing selection
        confirmationPressed = false;
      } else {
        if (newValue) {
          // If the trip is selected, update the booked trip index
          bookedTripIndexKLT = index;
        } else {
          // If the trip is deselected, reset the booked trip index if it matches
          if (bookedTripIndexKLT == index) {
            bookedTripIndexKLT = null;
          }
        }
      }
    });
  }

  void updateBookingStatusCLT(int index, bool newValue) {
    setState(() {
      if (confirmationPressed) {
        // If confirmation is pressed, allow changing selection
        confirmationPressed = false;
      } else {
        if (newValue) {
          // If the trip is selected, update the booked trip index
          bookedTripIndexCLT = index;
        } else {
          // If the trip is deselected, reset the booked trip index if it matches
          if (bookedTripIndexCLT == index) {
            bookedTripIndexCLT = null;
          }
        }
      }
    });
  }

  List<DateTime> getDepartureTimes() {
    if (selectedBox == 1) {
      return KTABus1DepartureTime;
    } else {
      return CLTBus1DepartureTime;
    }
  }

  String formatTime(DateTime time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void showBookingConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 2),
                  Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Thank you for booking with us. Your booking has been confirmed',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Trip Number:         ${selectedBox == 1 ? bookedTripIndexKLT! + 1 : bookedTripIndexCLT! + 1}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Time:                       ${formatTime(getDepartureTimes()[selectedBox == 1 ? bookedTripIndexKLT! : bookedTripIndexCLT!])}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Station:                    ${selectedBox == 1 ? 'King Albert MRT' : 'Clementi MRT'}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedStation = selectedBox == 1 ? 'King Albert MRT' : 'Clementi MRT';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Select MRT:'),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => updateSelectedBox(1), // Update KLT
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 70,
                      color: selectedBox == 1 ? Colors.blueAccent : Colors.grey,
                      child: Center(
                        child: Text(
                          'King Albert MRT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => updateSelectedBox(2), // Update CLT
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 70,
                      color: selectedBox == 2 ? Colors.blueAccent : Colors.grey,
                      child: Center(
                        child: Text(
                          'Clementi MRT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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
        SizedBox(height: 5),
        if (selectedBox != 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(13.0, 10.0, 0.0, 0.0),
            child: Text('Selected Station: $selectedStation',
              style: TextStyle(
                fontFamily: 'PlayFair',
                fontSize: 20,
                fontWeight: FontWeight.w700
              ),),
          ),
        SizedBox(height: 5),
        if (selectedBox != 0)
        Row(
          children: [
            SizedBox(width: 8),
            Icon(
              Icons.warning,
              color: Colors.amber[500],
              size: 20,
            ),
            SizedBox(width: 5),
            Text(
              'Note: Departure time listed from Block 37',
              style: TextStyle(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                fontFamily: 'PlayFair',
              ),
            ),
          ],
        ),

        if (selectedBox != 0)
        showBookingDetails
            ? BookingConfirmation(
          selectedBox: selectedBox,
          bookedTripIndexKLT: bookedTripIndexKLT,
          bookedTripIndexCLT: bookedTripIndexCLT,
          getDepartureTimes: getDepartureTimes,
          onCancel: () {
            setState(() {
              confirmationPressed = false;
              showBookingDetails = false;
            });
          },
        )
            : BookingService(
          departureTimes: getDepartureTimes(),
          selectedBox: selectedBox,
          bookedTripIndexKLT: bookedTripIndexKLT,
          bookedTripIndexCLT: bookedTripIndexCLT,
          updateBookingStatusKLT: updateBookingStatusKLT,
          updateBookingStatusCLT: updateBookingStatusCLT,
          confirmationPressed: confirmationPressed,
          onPressedConfirm: () {
            setState(() {
              confirmationPressed = true;
              showBookingDetails = true;
            });
            showBookingConfirmationDialog(context);
          },
        ),
      ],
    );
  }
}

class BookingService extends StatelessWidget {
  final List<DateTime> departureTimes;
  final int selectedBox;
  final int? bookedTripIndexKLT;
  final int? bookedTripIndexCLT;
  final Function(int index, bool newValue) updateBookingStatusKLT;
  final Function(int index, bool newValue) updateBookingStatusCLT;
  final VoidCallback onPressedConfirm;
  final bool confirmationPressed;

  BookingService({
    required this.departureTimes,
    required this.selectedBox,
    required this.bookedTripIndexKLT,
    required this.bookedTripIndexCLT,
    required this.updateBookingStatusKLT,
    required this.updateBookingStatusCLT,
    required this.onPressedConfirm,
    required this.confirmationPressed,
  });

  bool canConfirm() {
    return selectedBox == 1 ? bookedTripIndexKLT != null : bookedTripIndexCLT != null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: departureTimes.length,
            itemBuilder: (context, index) {
              final time = departureTimes[index];
              bool isBookedKLT = index == bookedTripIndexKLT;
              bool isBookedCLT = index == bookedTripIndexCLT;
              bool canBook = selectedBox == 1
                  ? bookedTripIndexKLT == null
                  : bookedTripIndexCLT == null;

              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.lightBlue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  0.0), // Set to 0.0 for 90-degree corners
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    'Departure Trip ${index + 1}',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(width: 70),
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.black, // Adjust color as needed
                                  ),
                                  SizedBox(width: 30),
                                  Text(
                                    '${time.hour.toString().padLeft(2, '0')}:${time
                                        .minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (selectedBox == 1) {
                              updateBookingStatusKLT(index, !isBookedKLT);
                            } else {
                              updateBookingStatusCLT(index, !isBookedCLT);
                            }
                          },
                          child: Icon(
                            selectedBox == 1 ? (isBookedKLT ? Icons.check_box : Icons
                                .check_box_outline_blank) : (isBookedCLT ? Icons
                                .check_box : Icons.check_box_outline_blank),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        if (canConfirm())
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: onPressedConfirm,
                child: Text('Confirm'),
              ),
            ),
          ),
        SizedBox(height: 20),
        if(selectedBox == 1)
        Row(
          children: [
            SizedBox(width: 10),
            Text('Bus ETA for King Albert MRT',
              style: TextStyle(
                fontSize: 23,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        if(selectedBox == 1)
        EveningStartPoint.getBusTime(KTABus1DepartureTime, context),
        SizedBox(height: 30),
        if(selectedBox == 2)
        Row(
          children: [
            SizedBox(width: 10),
            Text('Bus ETA for Clementi MRT',
              style: TextStyle(
                fontSize: 23,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        if(selectedBox == 2)
        EveningStartPoint.getBusTime(CLTBus1DepartureTime, context),
      ],
    );
  }
}

class BookingConfirmation extends StatelessWidget {
  final int selectedBox;
  final int? bookedTripIndexKLT;
  final int? bookedTripIndexCLT;
  final List<DateTime> Function() getDepartureTimes;
  final VoidCallback onCancel;

  const BookingConfirmation({
    required this.selectedBox,
    required this.bookedTripIndexKLT,
    required this.bookedTripIndexCLT,
    required this.getDepartureTimes,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final int? bookedTripIndex = selectedBox == 1 ? bookedTripIndexKLT : bookedTripIndexCLT;
    final DateTime bookedTime = getDepartureTimes()[bookedTripIndex!];
    final String station = selectedBox == 1 ? 'King Albert Station' : 'Clementi Station';
    DateTime currentTime = DateTime.now();
    bool isAfter3pm = currentTime.hour >= 15 ? true : false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_available, color: Colors.blueAccent),
                      Text(
                        'Booking Confirmation:',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Trip Number',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.4),
                      Text('${bookedTripIndex +1}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),)
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.52),
                      Text('${bookedTime.hour.toString().padLeft(2, '0')}:${bookedTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),)
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 1,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Station',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.48),
                      Text('$station',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),)
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.7),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: ElevatedButton(
                          onPressed: onCancel,
                          child: Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        EveningStartPoint.getBusTime(selectedBox == 1
            ? KTABus1DepartureTime
            : CLTBus1DepartureTime, context)

      ],
    );
  }
}
