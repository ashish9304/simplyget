import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:good_to_go/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:good_to_go/features/vehicle/data/vehicle_repository.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  int _currentStep = 0;
  final _detailsFormKey = GlobalKey<FormState>();
  final _pricingFormKey = GlobalKey<FormState>();

  // Form Data
  String _type = 'car'; // 'car' or 'bike'
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<XFile> _selectedImages = [];
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List Your Vehicle"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                if (_currentStep == 3 && _isUploading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _currentStep == 3 ? "Publish Listing" : "Continue",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Back"),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text("Type"),
            content: _buildTypeStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text("Details"),
            content: _buildDetailsStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text("Pricing"),
            content: _buildPricingStep(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text("Photos"),
            content: _buildPhotosStep(),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep() {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text("Car"),
          value: 'car',
          // ignore: deprecated_member_use
          groupValue: _type,
          // ignore: deprecated_member_use
          onChanged: (value) => setState(() => _type = value!),
          secondary: const Icon(Icons.directions_car),
        ),
        RadioListTile<String>(
          title: const Text("Bike"),
          value: 'bike',
          // ignore: deprecated_member_use
          groupValue: _type,
          // ignore: deprecated_member_use
          onChanged: (value) => setState(() => _type = value!),
          secondary: const Icon(Icons.two_wheeler),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _detailsFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _brandController,
            decoration: const InputDecoration(labelText: "Brand (e.g. Honda)"),
            validator: (val) => val!.isEmpty ? "Required" : null,
          ),
          TextFormField(
            controller: _modelController,
            decoration: const InputDecoration(labelText: "Model (e.g. Civic)"),
            validator: (val) => val!.isEmpty ? "Required" : null,
          ),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: "Location (City/Area)",
            ),
            validator: (val) => val!.isEmpty ? "Required" : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: "Description",
              hintText: "Describe your vehicle...",
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStep() {
    return Form(
      key: _pricingFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: "Price per Day (₹)"),
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.isEmpty) return "Required";
              if (double.tryParse(val) == null) return "Invalid number";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload at least 3 photos"),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._selectedImages.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(entry.value.path)
                              : FileImage(File(entry.value.path))
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImages.removeAt(entry.key);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }),
              InkWell(
                onTap: _pickImages,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      setState(() => _currentStep += 1);
    } else if (_currentStep == 1) {
      if (_detailsFormKey.currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 2) {
      if (_pricingFormKey.currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 3) {
      _submitListing();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _submitListing() async {
    if (_selectedImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload at least 3 photos")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final repo = ref.read(vehicleRepositoryProvider);

      // 1. Upload Images
      List<String> imageUrls = [];
      for (var image in _selectedImages) {
        final url = await repo.uploadImage(image);
        imageUrls.add(url);
      }

      // 2. Create Vehicle
      final vehicleData = {
        "type": _type,
        "brand": _brandController.text,
        "model": _modelController.text,
        "price_per_day": double.parse(_priceController.text),
        "location": _locationController.text,
        "description": _descriptionController.text,
        "image_url": imageUrls[0], // First image as thumbnail
        "image_urls": imageUrls,
        "is_available": true,
      };

      await repo.createVehicle(vehicleData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehicle Listed Successfully!")),
        );
        context.go('/'); // Or to My Vehicles
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
