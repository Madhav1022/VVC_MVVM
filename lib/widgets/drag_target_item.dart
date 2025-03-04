
import 'package:flutter/material.dart';
import '../viewmodels/camera_view_model.dart';

class DragTargetItem extends StatefulWidget {
  final String property;
  final CameraViewModel viewModel;

  const DragTargetItem({
    super.key,
    required this.property,
    required this.viewModel,
  });

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            widget.property,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: candidateData.isNotEmpty
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.viewModel.getPropertyValue(widget.property).isEmpty
                          ? 'Drop here'
                          : widget.viewModel.getPropertyValue(widget.property),
                    ),
                  ),
                  if (widget.viewModel.getPropertyValue(widget.property).isNotEmpty)
                    InkWell(
                      onTap: () {
                        widget.viewModel.clearPropertyValue(widget.property);
                      },
                      child: const Icon(
                        Icons.clear,
                        size: 15,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            onAccept: (value) {
              widget.viewModel.updatePropertyValue(widget.property, value);
            },
          ),
        ),
      ],
    );
  }
}