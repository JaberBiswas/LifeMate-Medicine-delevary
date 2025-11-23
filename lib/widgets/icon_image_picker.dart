import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/theme.dart';

class IconImagePicker extends StatefulWidget {
  const IconImagePicker({
    super.key,
    required this.onIconSelected,
    required this.onImageSelected,
    this.initialIcon,
    this.initialImageUrl,
  });

  final Function(IconData?) onIconSelected;
  final Function(File?) onImageSelected;
  final IconData? initialIcon;
  final String? initialImageUrl;

  @override
  State<IconImagePicker> createState() => _IconImagePickerState();
}

class _IconImagePickerState extends State<IconImagePicker> {
  bool _isIconMode = true;
  IconData? _selectedIcon;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Medicine and healthcare related icons (100+ icons)
  final List<IconData> _commonIcons = [
    // Medical Services & Facilities
    Icons.medical_services,
    Icons.medical_services_outlined,
    Icons.local_hospital,
    Icons.local_hospital_outlined,
    Icons.local_pharmacy,
    Icons.local_pharmacy_outlined,
    Icons.emergency,
    Icons.emergency_outlined,
    Icons.health_and_safety,
    Icons.health_and_safety_outlined,
    Icons.medical_information,
    Icons.medical_information_outlined,
    
    // Medications & Treatments
    Icons.medication,
    Icons.medication_outlined,
    Icons.medication_liquid,
    Icons.medication_liquid_outlined,
    Icons.vaccines,
    Icons.vaccines_outlined,
    Icons.healing,
    Icons.healing_outlined,
    Icons.circle,
    Icons.circle_outlined,
    
    // Body Parts & Organs
    Icons.favorite,
    Icons.favorite_outline,
    Icons.bloodtype,
    Icons.bloodtype_outlined,
    Icons.psychology,
    Icons.psychology_outlined,
    Icons.self_improvement,
    Icons.self_improvement_outlined,
    
    // Medical Equipment & Devices
    Icons.monitor_heart,
    Icons.monitor_heart_outlined,
    Icons.devices,
    Icons.devices_outlined,
    Icons.sensors,
    Icons.sensors_outlined,
    
    // Science & Research
    Icons.science,
    Icons.science_outlined,
    Icons.biotech,
    Icons.biotech_outlined,
    Icons.analytics,
    Icons.analytics_outlined,
    Icons.auto_awesome,
    Icons.auto_awesome_outlined,
    Icons.bug_report,
    Icons.bug_report_outlined,
    
    // Diseases & Conditions
    Icons.coronavirus,
    Icons.coronavirus_outlined,
    Icons.airline_stops,
    Icons.airline_stops_outlined,
    
    // General Healthcare
    Icons.water,
    Icons.water_outlined,
    Icons.thermostat,
    Icons.thermostat_outlined,
    Icons.thermostat_auto,
    Icons.thermostat_auto_outlined,
    
    // Categories & Organization
    Icons.category,
    Icons.category_outlined,
    Icons.label,
    Icons.label_outlined,
    Icons.tag,
    Icons.tag_outlined,
    
    // Additional Medical Icons (using common medical-related icons)
    Icons.hotel, // Hospital-like
    Icons.hotel_outlined,
    Icons.home,
    Icons.home_outlined,
    Icons.business,
    Icons.business_outlined,
    
    // Care & Support
    Icons.accessible,
    Icons.accessible_outlined,
    Icons.accessible_forward,
    Icons.accessible_forward_outlined,
    Icons.hearing,
    Icons.hearing_outlined,
    Icons.hearing_disabled,
    Icons.hearing_disabled_outlined,
    Icons.visibility,
    Icons.visibility_outlined,
    Icons.visibility_off,
    Icons.visibility_off_outlined,
    
    // First Aid & Emergency
    Icons.warning,
    Icons.warning_outlined,
    Icons.error,
    Icons.error_outlined,
    Icons.error_outline,
    Icons.info,
    Icons.info_outline,
    Icons.help,
    Icons.help_outline,
    
    // Monitoring & Tracking
    Icons.monitor,
    Icons.monitor_outlined,
    Icons.track_changes,
    Icons.track_changes_outlined,
    Icons.timeline,
    Icons.timeline_outlined,
    Icons.history,
    Icons.history_outlined,
    Icons.schedule,
    Icons.schedule_outlined,
    
    // Communication & Information
    Icons.phone,
    Icons.phone_outlined,
    Icons.call,
    Icons.call_outlined,
    Icons.message,
    Icons.message_outlined,
    Icons.notifications,
    Icons.notifications_outlined,
    Icons.notification_important,
    Icons.notification_important_outlined,
    
    // Additional Healthcare Icons
    Icons.wc,
    Icons.wc_outlined,
    Icons.elderly,
    Icons.elderly_outlined,
    Icons.child_care,
    Icons.child_care_outlined,
    Icons.person,
    Icons.person_outline,
    Icons.person_add,
    Icons.person_add_outlined,
    
    // Health & Wellness
    Icons.fitness_center,
    Icons.fitness_center_outlined,
    Icons.spa,
    Icons.spa_outlined,
    Icons.pool,
    Icons.pool_outlined,
    Icons.beach_access,
    Icons.beach_access_outlined,
    Icons.restaurant,
    Icons.restaurant_outlined,
    Icons.local_dining,
    Icons.local_dining_outlined,
    Icons.no_food,
    Icons.no_food_outlined,
    
    // Time & Schedule
    Icons.access_time,
    Icons.access_time_outlined,
    Icons.access_time_filled,
    Icons.access_time_filled_outlined,
    Icons.timer,
    Icons.timer_outlined,
    Icons.timer_off,
    Icons.timer_off_outlined,
    Icons.alarm,
    Icons.alarm_outlined,
    Icons.alarm_add,
    Icons.alarm_add_outlined,
    
    // Storage & Inventory
    Icons.inventory,
    Icons.inventory_outlined,
    Icons.inventory_2,
    Icons.inventory_2_outlined,
    Icons.warehouse,
    Icons.warehouse_outlined,
    Icons.storage,
    Icons.storage_outlined,
    Icons.shopping_bag,
    Icons.shopping_bag_outlined,
    Icons.shopping_cart,
    Icons.shopping_cart_outlined,
    
    // Documentation & Records
    Icons.description,
    Icons.description_outlined,
    Icons.assignment,
    Icons.assignment_outlined,
    Icons.article,
    Icons.article_outlined,
    Icons.note,
    Icons.note_outlined,
    Icons.note_add,
    Icons.note_add_outlined,
    Icons.file_present,
    Icons.file_present_outlined,
    
    // Search & Find
    Icons.search,
    Icons.search_outlined,
    Icons.find_in_page,
    Icons.find_in_page_outlined,
    Icons.filter_list,
    Icons.filter_list_outlined,
    
    // Settings & Configuration
    Icons.settings,
    Icons.settings_outlined,
    Icons.settings_applications,
    Icons.settings_applications_outlined,
    Icons.tune,
    Icons.tune_outlined,
    
    // Status & Indicators
    Icons.check_circle,
    Icons.check_circle_outline,
    Icons.cancel,
    Icons.cancel_outlined,
    Icons.radio_button_checked,
    Icons.radio_button_unchecked,
    Icons.check_box,
    Icons.check_box_outline_blank,
    
    // Additional Useful Icons
    Icons.add,
    Icons.add_circle,
    Icons.add_circle_outline,
    Icons.remove,
    Icons.remove_circle,
    Icons.remove_circle_outline,
    Icons.edit,
    Icons.edit_outlined,
    Icons.delete,
    Icons.delete_outlined,
    Icons.save,
    Icons.save_outlined,
    Icons.print,
    Icons.print_outlined,
    Icons.share,
    Icons.share_outlined,
    Icons.download,
    Icons.download_outlined,
    Icons.upload,
    Icons.upload_outlined,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _isIconMode = false;
    } else if (widget.initialIcon != null) {
      _isIconMode = true;
      _selectedIcon = widget.initialIcon;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isIconMode = false;
        });
        widget.onImageSelected(_selectedImage);
        widget.onIconSelected(null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isIconMode = false;
        });
        widget.onImageSelected(_selectedImage);
        widget.onIconSelected(null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectIcon(IconData icon) {
    setState(() {
      _selectedIcon = icon;
      _isIconMode = true;
      _selectedImage = null;
    });
    widget.onIconSelected(icon);
    widget.onImageSelected(null);
  }

  void _clearSelection() {
    setState(() {
      _selectedIcon = null;
      _selectedImage = null;
    });
    widget.onIconSelected(null);
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ignore: prefer_const_constructors
            Flexible(
              child: const Text(
                'Category Icon/Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            // Toggle buttons for Icon/Image
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(
                    label: 'Icon',
                    isSelected: _isIconMode,
                    onTap: () {
                      setState(() {
                        _isIconMode = true;
                        // Don't clear _selectedImage here - let it be cleared when icon is actually selected
                      });
                      // Only notify if we're switching from image mode to icon mode
                      // Don't call callbacks with null here - just toggle the mode
                    },
                  ),
                  _buildToggleButton(
                    label: 'Image',
                    isSelected: !_isIconMode,
                    onTap: () {
                      setState(() {
                        _isIconMode = false;
                        // Don't clear _selectedIcon here - let it be cleared when image is actually selected
                      });
                      // Only notify if we're switching from icon mode to image mode
                      // Don't call callbacks with null here - just toggle the mode
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Preview area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.gray.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Preview
              SizedBox(
                width: 100,
                height: 100,
                child: _isIconMode
                    ? (_selectedIcon != null
                        ? Icon(
                            _selectedIcon,
                            size: 60,
                            color: AppTheme.primaryTeal,
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: AppTheme.gray,
                          ))
                    : (_selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (widget.initialImageUrl != null &&
                                widget.initialImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.initialImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: AppTheme.gray,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: AppTheme.gray,
                              ))),
              ),
              const SizedBox(height: 12),
              // Action buttons
              if (_isIconMode)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _commonIcons.map((icon) {
                    return InkWell(
                      onTap: () => _selectIcon(icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? AppTheme.primaryTeal
                              : AppTheme.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedIcon == icon
                                ? AppTheme.primaryTeal
                                : AppTheme.gray.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon
                              ? AppTheme.white
                              : AppTheme.gray,
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Choose Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              if ((_selectedIcon != null || _selectedImage != null) ||
                  (widget.initialImageUrl != null &&
                      widget.initialImageUrl!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: _clearSelection,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.gray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

