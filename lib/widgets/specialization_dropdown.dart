import 'package:admin/controllers/services/services_controller.dart';
import 'package:admin/controllers/teams/team_controller.dart';
import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpecializationDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const SpecializationDropdown({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  State<SpecializationDropdown> createState() => _SpecializationDropdownState();
}

class _SpecializationDropdownState extends State<SpecializationDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final servicesController = context.read<ServicesController>();
        if (servicesController.services.isEmpty &&
            !servicesController.isLoading) {
          servicesController.fetchServices();
        }
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
       context.read<TeamController>().setDropdownOpen(false);
    }
  }

  void _toggleOverlay(ServicesController servicesController, TeamController teamController) {
    if (teamController.isDropdownOpen) {
      _removeOverlay();
    } else {
      if (teamController.selectedCategory == null) return;
      _showOverlay(servicesController, teamController);
    }
  }

  void _showOverlay(ServicesController servicesController, TeamController teamController) {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final categoryServices =
        servicesController.services
            .where((s) => s.category == teamController.selectedCategory)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    if (categoryServices.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          width: size.width / 2 - 8,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(
              0.0,
              48.0 + 4.0,
            ),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
              child: TapRegion(
                onTapOutside: (_) => _removeOverlay(),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Consumer<TeamController>(
                      builder: (context, controller, child) {
                         return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: categoryServices.map((service) {
                            final isSelected = controller.selectedServices.contains(
                              service.name,
                            );
                            return CheckboxListTile(
                              checkColor: AppColors.white,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primaryRed,
                              title: Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.softBlack,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? checked) {
                                controller.toggleServiceSelection(service.name);
                              },
                            );
                          }).toList(),
                        );
                      }
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    teamController.setDropdownOpen(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ServicesController, TeamController>(
      builder: (context, servicesController, teamController, child) {
        final categories =
            servicesController.services
                .map((s) => s.category)
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Dropdown
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: AppColors.white,
                        value: teamController.selectedCategory,
                        isExpanded: true,
                        hint: Text(
                          "Select Category",
                          style: TextStyle(
                            color: AppColors.grey.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.softBlack,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          teamController.setSelectedCategory(newValue);
                          if (teamController.isDropdownOpen) {
                            _removeOverlay();
                          }
                        },
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Service Dropdown (Multi-Select Trigger)
                Expanded(
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: GestureDetector(
                      onTap: () {
                        if (teamController.selectedCategory != null) {
                          _toggleOverlay(servicesController, teamController);
                        }
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: teamController.selectedCategory == null
                              ? Colors.grey[100]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: teamController.isDropdownOpen
                                ? AppColors.primaryRed
                                : AppColors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Select Services...",
                                style: TextStyle(
                                  color: AppColors.grey.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              teamController.isDropdownOpen
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: teamController.isDropdownOpen
                                  ? AppColors.primaryRed
                                  : AppColors.grey.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Chips rendered below the dropdowns
            if (teamController.selectedServices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: teamController.selectedServices.map((service) {
                    return Chip(
                      label: Text(
                        service,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.softBlack,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      onDeleted: () {
                        teamController.removeServiceSelection(service);
                        _overlayEntry?.markNeedsBuild();
                      },
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}
