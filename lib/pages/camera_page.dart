
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/camera_view_model.dart';
import '../utils/constants.dart';
import 'form_page.dart';

class CameraPage extends StatelessWidget {
  static const String routeName = 'camera';
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scan Page'),
            backgroundColor: Color(0xFF6200EE),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: viewModel.isFormValid
                    ? () => context.goNamed(
                    FormPage.routeName,
                    extra: viewModel.createContact()
                )
                    : null,
                icon: const Icon(Icons.arrow_forward),
                color: viewModel.isFormValid
                    ? Colors.white
                    : Colors.grey.shade400,
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Camera',
                        style: TextStyle(color: Colors.white, fontSize: 16)
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      backgroundColor: Colors.deepPurple,
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.getImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text('Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 16)
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      backgroundColor: Colors.indigo,
                      elevation: 5,
                    ),
                  ),
                ],
              ),
              if (viewModel.isScanOver)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        DragTargetItem(
                          property: ContactProperties.name,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 12),
                        DragTargetItem(
                          property: ContactProperties.mobile,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 12),
                        DragTargetItem(
                          property: ContactProperties.email,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 12),
                        DragTargetItem(
                          property: ContactProperties.company,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 12),
                        DragTargetItem(
                          property: ContactProperties.designation,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 12),
                        DragTargetItem(
                          property: ContactProperties.address,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 12),
                        DragTargetItem(
                          property: ContactProperties.website,
                          viewModel: viewModel,
                        ),
                      ],
                    ),
                  ),
                ),
              if (viewModel.isScanOver)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(hint),
                ),
              Wrap(
                spacing: 8,
                children: viewModel.lines.map((line) =>
                    LineItem(line: line)
                ).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}

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
  List<String> dragItems = [];

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
                fontSize: 16
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
                      dragItems.isEmpty ? 'Drop here' : dragItems.join(' '),
                    ),
                  ),
                  if (dragItems.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          dragItems.clear();
                        });
                        widget.viewModel.updatePropertyValue(widget.property, '');
                      },
                      child: const Icon(
                          Icons.clear,
                          size: 15,
                          color: Colors.red
                      ),
                    ),
                ],
              ),
            ),
            onAccept: (value) {
              setState(() {
                if (!dragItems.contains(value)) {
                  dragItems.add(value);
                }
              });
              widget.viewModel.updatePropertyValue(
                widget.property,
                dragItems.join(' '),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LineItem extends StatelessWidget {
  final String line;
  const LineItem({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.black38,
        ),
        child: Text(
            line,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white
            )
        ),
      ),
      child: Chip(
        label: Text(line),
      ),
    );
  }
}





