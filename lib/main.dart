import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MyRow extends StatefulWidget {
  const MyRow({
    super.key,
    required this.middleFill,
    required this.text,
    this.middleCellWidgetWidth = 5,
    this.height = 30,
    this.minMiddleCellWidth = 10,
    this.onCheckBoxChanged, 
    this.textSize = 18,
  });

  final Widget middleFill;
  final String text;
  final double textSize;
  final double middleCellWidgetWidth;
  final double height;
  final double minMiddleCellWidth;
  final void Function(bool?)? onCheckBoxChanged;

  @override
  State<MyRow> createState() => _MyRowState();
}

class _MyRowState extends State<MyRow> {
  final GlobalKey _middleCellKey = GlobalKey();

  Size? _currentMiddleCellSize;

  final GlobalKey _textCellKey = GlobalKey();

  Size? _initialTextCellSize;
  Size? _currentTextCellSize;

  void _setTextCellSize(_) {
    final currentSize = _textCellKey.currentContext!.size!;

    _initialTextCellSize ??= currentSize;

    setState(() {
      _currentTextCellSize = currentSize;
    });
  }

  void _setMiddleCellSize(_) {
    setState(() {
      _currentMiddleCellSize = _middleCellKey.currentContext!.size!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMiddleCellSize == null) {
      WidgetsBinding.instance.addPostFrameCallback(_setMiddleCellSize);
      WidgetsBinding.instance.addPostFrameCallback(_setTextCellSize);
    }

    final border = BoxDecoration(border: Border.all(color: Colors.black));

    final double middleCellWidth = (_currentMiddleCellSize == null)
        ? MediaQuery.of(context).size.width
        : _currentMiddleCellSize!.width;

    final middleCellContainer = Container(
      key: _middleCellKey,
      decoration: border,
      height: widget.height,
      child: Row(
        children: Iterable.generate(
                middleCellWidth ~/ widget.middleCellWidgetWidth)
            .map((e) => SizedBox(
                  width: widget.middleCellWidgetWidth,
                  child: widget.middleFill,
                ))
            .toList(),
      ),
    );

    final textCellContainer = Container(
      key: _textCellKey,
      decoration: border,
      height: widget.height,
      child: Text(
        widget.text,
        style: TextStyle(fontSize: widget.textSize),
        overflow: TextOverflow.ellipsis,
      ),
    );

    late final middleCell;
    late final textCell;

    if (_currentMiddleCellSize != null &&
        _currentMiddleCellSize!.width <= widget.minMiddleCellWidth) {
      if (_currentTextCellSize!.width > _initialTextCellSize!.width) {
        textCell = textCellContainer;
        middleCell = Expanded(
          child: middleCellContainer,
        );
      } else {
        middleCell = Container(
          key: _middleCellKey,
          width: widget.minMiddleCellWidth,
          height: widget.height,
          decoration: border,
        );
        textCell = Expanded(child: textCellContainer);
      }
    } else {
      middleCell = Expanded(child: middleCellContainer);
      textCell = textCellContainer;
    }

    return NotificationListener(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback(_setMiddleCellSize);
        WidgetsBinding.instance.addPostFrameCallback(_setTextCellSize);
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textCell,
            middleCell,
            Container(
              decoration: border,
              height: widget.height,
              child:
                  Checkbox(value: false, onChanged: widget.onCheckBoxChanged),
            )
          ],
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: MyRow(
            middleFill: Icon(Icons.flutter_dash_rounded),
            middleCellWidgetWidth: 20,
            text: "Какой-то текст",
          ),
        ),
      ),
    );
  }
}
