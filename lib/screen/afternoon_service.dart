import 'dart:async';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mini_project_five/models/ModelProvider.dart';
import 'package:mini_project_five/pages/busdata.dart';
import 'package:mini_project_five/screen/evening_bus.dart';
import 'package:mini_project_five/amplifyconfiguration.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api_dart/amplify_api_dart.dart';
import 'package:uuid/uuid.dart';


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
  String? BookingID;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _configureAmplify();
  }


  void _configureAmplify() async {
    final provider = ModelProvider();
    final amplifyApi = AmplifyAPI(options: APIPluginOptions(modelProvider: provider));
    final dataStorePlugin = AmplifyDataStore(modelProvider: provider);

    Amplify.addPlugin(dataStorePlugin);
    Amplify.addPlugin(amplifyApi);
    Amplify.configure(amplifyconfig);

    print('Amplify configured');
  }

  Future<void> create(String _MRTStation, int _TripNo) async {
    try {
      final model = BOOKINGDETAILS5(
        id: Uuid().v4(),
        MRTStation: _MRTStation,
        TripNo: _TripNo,
      );

      final request = ModelMutations.create(model);
      final response = await Amplify.API.mutate(request: request).response;

      final createdBOOKINGDETAILS5 = response.data;
      if (createdBOOKINGDETAILS5 == null) {
        safePrint('errors: ${response.errors}');
        return;
      }

      String id  = createdBOOKINGDETAILS5.id;
      setState(() {
        BookingID = id;
      });
      safePrint('Mutation result: $BookingID');// Return the ID of the created object
    } on ApiException catch (e) {
      safePrint('Mutation failed: $e');
    }
  }

  Future<BOOKINGDETAILS5?> readByID() async {
    final request = ModelQueries.list(
      BOOKINGDETAILS5.classType,
      where: BOOKINGDETAILS5.ID.eq(BookingID),
    );
    final response = await Amplify.API.query(request: request).response;
    final data = response.data?.items.firstOrNull;
    return data;
  }

  Future<int?> countBooking(String MRT, int TripNo) async{
int? count;
  try {
    final request = ModelQueries.list(
      BOOKINGDETAILS5.classType,
      where: BOOKINGDETAILS5.MRTSTATION.eq(MRT).and(
          BOOKINGDETAILS5.TRIPNO.eq(TripNo)),
    );
    final response = await Amplify.API
        .query(request: request)
        .response;
    final data = response.data?.items;

    if (data != null) {
      count = data.length;
      print('$count');
    }
    else
      count = 0;
  }
  catch (e) {
    print('$e');
  }

  return count;
  //await Future.delayed(Duration(seconds:10));

  }

  Future<void> delete() async {
    final BOOKINGDETAILS5? bookingToDelete = await readByID();
    if (bookingToDelete != null) {
      final request = ModelMutations.delete(bookingToDelete);
      final response = await Amplify.API.mutate(request: request).response;
    } else {
      print('No booking found with ID: $BookingID');
    }
  }


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
                  'Station:                    ${selectedBox == 1 ? 'KAP' : 'CLT'}',
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
    String selectedStation = selectedBox == 1 ? 'KAP' : 'CLT';
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
                  onTap: () {
                    setState(() {
                      updateSelectedBox(1);
                    });
                  } , // Update CLT
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    height: selectedBox == 1 ? 70 : 40,
                    curve: Curves.easeOutCubic,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: selectedBox == 1 ? Colors.blueAccent : Colors.grey,
                        child: Center(
                          child: Text(
                            'KAP',
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
              ),

              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      updateSelectedBox(2);
                    });
                  },  // Update CLT
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    height: selectedBox == 2 ? 70 : 40,
                    curve: Curves.easeOutCubic,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: selectedBox == 2 ? Colors.blueAccent : Colors.grey,
                        child: Center(
                          child: Text(
                            'CLT',
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
                //delete();
              });
            },
          )
              :
          BookingService(
            departureTimes: getDepartureTimes(),
            selectedBox: selectedBox,
            bookedTripIndexKLT: bookedTripIndexKLT,
            bookedTripIndexCLT: bookedTripIndexCLT,
            updateBookingStatusKLT: updateBookingStatusKLT,
            updateBookingStatusCLT: updateBookingStatusCLT,
            confirmationPressed: confirmationPressed,
            countBooking: countBooking,

            onPressedConfirm: () {
              setState(() {
                confirmationPressed = true;
                showBookingDetails = true;
                create(selectedStation, selectedBox == 1 ? bookedTripIndexKLT!+1 : bookedTripIndexCLT!+1);
              });
              showBookingConfirmationDialog(context);
            },
          ),
      ],
    );
  }
}

class BookingService extends StatefulWidget {
  final List<DateTime> departureTimes;
  final int selectedBox;
  final int? bookedTripIndexKLT;
  final int? bookedTripIndexCLT;
  final Function(int index, bool newValue) updateBookingStatusKLT;
  final Function(int index, bool newValue) updateBookingStatusCLT;
  final VoidCallback onPressedConfirm;
  final bool confirmationPressed;
  final Future<int?> Function(String MRT, int index) countBooking;

  BookingService({
    required this.departureTimes,
    required this.selectedBox,
    required this.bookedTripIndexKLT,
    required this.bookedTripIndexCLT,
    required this.updateBookingStatusKLT,
    required this.updateBookingStatusCLT,
    required this.onPressedConfirm,
    required this.confirmationPressed,
    required this.countBooking,
  });

  @override
  State<BookingService> createState() => _BookingServiceState();
}

class _BookingServiceState extends State<BookingService> {
  Color finalColor = Colors.grey;
  late Timer _timer;
  late Map<int, int?> bookingCounts; //store count
  bool canConfirm() {
    return widget.selectedBox == 1 ? widget.bookedTripIndexKLT != null : widget.bookedTripIndexCLT != null;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bookingCounts = {};
    _timer = Timer.periodic(Duration(seconds:3), (timer){
      _updateBookingCounts();
  });
  }

  @override
  void dispose(){
  _timer.cancel();
  super.dispose();
  }
  void _updateBookingCounts() async{
 for(int i = 0; i<widget.departureTimes.length; i++){
 int? count = await widget.countBooking(widget.selectedBox == 1 ?'KAP': 'CLT', i+1);
 setState(() {
   bookingCounts[i] = count;
 });
 }
  }

  Color _getColor(int _count){
    if (_count < 3)
    return Colors.green;
    else if (_count >=3 && _count <5)
    return Colors.yellowAccent;
    else
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Container(width: MediaQuery.of(context).size.width * 0.15, height: 5, color: Colors.green),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text('<50%'),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            Container(width: MediaQuery.of(context).size.width * 0.15, height: 5, color: Colors.yellowAccent),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text('50%<x<99%'),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            Container(width: MediaQuery.of(context).size.width * 0.15, height: 5, color: Colors.red),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Text('FULL'),
          ],
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.departureTimes.length,
            itemBuilder: (context, index) {
              final time = widget.departureTimes[index];
              int finalvalue = 0;
              bool isBookedKLT = index == widget.bookedTripIndexKLT;
              bool isBookedCLT = index == widget.bookedTripIndexCLT;
              bool canBook = widget.selectedBox == 1
                  ? widget.bookedTripIndexKLT == null
                  : widget.bookedTripIndexCLT == null;
              int? count = bookingCounts[index];

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
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Row(
                                children: [
                                  if (count != null)
                                  Container(width: 5, height: 57, color: _getColor(count)),
                                  Text(
                                    '     Departure Trip ${index + 1}',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(width: 70),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.black, // Adjust color as needed
                                    ),
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
                                  // FutureBuilder<int?>(
                                  //   future: widget.countBooking(widget.selectedBox == 1? 'KAP': 'CLT', index),
                                  //   builder: (context, snapshot) {
                                  //     int NoOfBooking = 0;
                                  //     if(snapshot.connectionState == ConnectionState.waiting||snapshot.connectionState == ConnectionState.none){
                                  //     return SizedBox();
                                  //     }
                                  //     else if (snapshot.connectionState ==
                                  //         ConnectionState.done) {
                                  //       if (snapshot.hasError)
                                  //       return Text('Has Error');
                                  //       else if (snapshot.hasData) {
                                  //         final count = snapshot.data ?? 0;
                                  //         NoOfBooking = count;
                                  //         if (finalvalue != NoOfBooking)
                                  //         finalvalue = NoOfBooking;
                                  //         return Text('$finalvalue');
                                  //       }
                                  //     }
                                  //     return Text('Unknown error');
                                  //   }
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),



                        GestureDetector(
                          onTap: () {
                            if (widget.selectedBox == 1) {
                              widget.updateBookingStatusKLT(index, !isBookedKLT);
                            } else {
                              widget.updateBookingStatusCLT(index, !isBookedCLT);
                            }
                          },
                          child: Icon(
                            widget.selectedBox == 1 ? (isBookedKLT ? Icons.check_box : Icons
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
                onPressed: widget.onPressedConfirm,
                child: Text('Confirm'),
              ),
            ),
          ),
        SizedBox(height: 20),
        if(widget.selectedBox == 1)
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
        if(widget.selectedBox == 1)
          EveningStartPoint.getBusTime(KTABus1DepartureTime, context),
        SizedBox(height: 30),
        if(widget.selectedBox == 2)
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
        if(widget.selectedBox == 2)
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
    final String station = selectedBox == 1 ? 'KAP' : 'CLT';
    DateTime currentTime = DateTime.now();
    bool isAfter3pm = currentTime.hour >= 15 ? true : false;

    if(bookedTime != null){
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
                        SizedBox(width: MediaQuery.of(context).size.width * 0.65),
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
      );}
    else
      return SizedBox();
  }
}
