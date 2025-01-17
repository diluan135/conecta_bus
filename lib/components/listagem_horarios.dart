import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ListagemHorarios extends StatefulWidget {
  final List snapData;
  final int currentIndex;
  final bool sValue;
  const ListagemHorarios(
      {super.key,
      required this.snapData,
      required this.currentIndex,
      required this.sValue});

  @override
  State<ListagemHorarios> createState() => _ListagemHorariosState();
}

class _ListagemHorariosState extends State<ListagemHorarios> {
  List saidasPossiveis = ["T-B", "TU-", "TC-"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollablePositionedList.builder(
            initialScrollIndex: widget.currentIndex,
            itemCount: widget.snapData.length,
            itemBuilder: (context, index) {
              if (!widget.sValue) {
                return saidasPossiveis.contains(widget.snapData[index]
                                    ['sentido']
                                .substring(0, 3)) &&
                            widget.snapData[index]['sentido'] != "TU-TC" ||
                        widget.snapData[index]['sentido'] == "TO-TNR"
                    ? Card(
                        child: ListTile(
                          subtitle: Center(
                              child: Text(
                                  "${widget.snapData[index]['via'] ?? ""}")),
                          title: Center(
                            child: Text(
                              widget.snapData[index]['horario'].substring(0, 5),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              } else {
                return saidasPossiveis.contains(widget.snapData[index]
                                    ['sentido']
                                .substring(0, 3)) &&
                            widget.snapData[index]['sentido'] != "TU-TC" ||
                        widget.snapData[index]['sentido'] == "TO-TNR"
                    ? const SizedBox.shrink()
                    : Card(
                        child: ListTile(
                          subtitle: Center(
                            child:
                                Text("${widget.snapData[index]['via'] ?? ""}"),
                          ),
                          title: Center(
                            child: Text(
                                widget.snapData[index]['horario']
                                    .substring(0, 5),
                                style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      );
              }
            },
          ),
        ),
      ],
    );
  }
}
