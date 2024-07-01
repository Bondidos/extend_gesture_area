This package allows you to process gestures even if they were outside the widget (with a given padding),
without changing widget size

## Usage
1. Wrap gesture widget with ExtendGestureAreaConsumer and set gesturePadding
   ```dart
   import 'package:extend_gesture_area/extend_gesture_area.dart';
   
   ExtendGestureAreaConsumer(
          gesturePadding: 30,
          child: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
   ```
2. Wrap parent with ExtendGestureAreaDetector.   
Note: Parent should contain gesture widget and area around it (gesturePadding)

   ```dart
   import 'package:extend_gesture_area/extend_gesture_area.dart';

   @override
   Widget build(BuildContext context) {
   // Wrap Scaffold, because this widget is a parent of FloatingActionButton
   // and owns area around it
   return ExtendGestureAreaDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineMedium,
              ),
            ],
          ),
        ),
   floatingActionButton: ExtendGestureAreaConsumer(
          gesturePadding: 30,  // set gesture padding
          child: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
   }
   ```
