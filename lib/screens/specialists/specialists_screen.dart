import 'package:admin/controllers/specialists/specialist_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../utils/bulk_delete.dart';
import '../../utils/confirmed_delete.dart';
import 'package:admin/widgets/action_button.dart';
import 'package:admin/widgets/heading_icon.dart';
import 'package:admin/controllers/services/services_controller.dart';
import 'package:admin/controllers/categories/category_controller.dart';
import '../../widgets/icon_button.dart';
import '../../widgets/visibility.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';

class SpecialistsScreen extends StatefulWidget {
  const SpecialistsScreen({super.key});

  @override
  State<SpecialistsScreen> createState() => _SpecialistsScreenState();
}

class _SpecialistsScreenState extends State<SpecialistsScreen> {
  late SpecialistController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<SpecialistController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.startPolling();
      }
    });
  }

  @override
  void dispose() {
    _controller.stopPolling();
    super.dispose();
  }

  void _defer(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fn());
  }

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        final controller = PrimaryScrollController.of(context);
        if (controller.hasClients) {
          controller.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<SpecialistController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // Fixed Header Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Responsive(
                  mobile: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Specialist Management",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softBlack,
                          fontFamily: "Libre",
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHeaderButton(controller),
                    ],
                  ),
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Specialist Management",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softBlack,
                          fontFamily: "Libre",
                        ),
                      ),
                      _buildHeaderButton(controller),
                    ],
                  ),
                ),
              ),

              // Scrollable Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchSpecialists(),
                  color: AppColors.primaryRed,
                  child: Scrollbar(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (controller.isAdding) ...[
                          _buildSpecialistForm(context, controller),
                          const SizedBox(height: 48),
                          Divider(
                            height: 1,
                            thickness: 1.0,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Existing Specialists",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softBlack,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildSpecialistList(context, controller),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderButton(SpecialistController controller) {
    return ElevatedButton.icon(
      onPressed: () {
        controller.setAdding(!controller.isAdding);
        if (controller.isAdding) _scrollToTop();
      },
      icon: SvgPicture.asset(
        controller.isAdding ? AppIcons.cross : AppIcons.plus,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: Text(controller.isAdding ? "Close Form" : "Create Specialist"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildSpecialistList(
    BuildContext context,
    SpecialistController controller,
  ) {
    if (controller.isLoading && controller.specialists.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }

    if (controller.specialists.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.softBlack.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                "No specialists found. Add your first one!",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildListHeader(context, controller),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double tableWidth = constraints.maxWidth > 750
                ? constraints.maxWidth
                : 750;
            return CustomHorizontalScrollbar(
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                width: tableWidth,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value:
                                  controller.selectedIds.length ==
                                      controller.filteredSpecialists.length &&
                                  controller.filteredSpecialists.isNotEmpty,
                              onChanged: (val) =>
                                  controller.selectAll(val ?? false),
                            ),
                            const SizedBox(width: 8),
                            _buildTableHeaderCell("Name", 3),
                            _buildTableHeaderCell("Role", 2),
                            _buildTableHeaderCell("Services", 2),
                            _buildTableHeaderCell("Experience", 2),
                            _buildTableHeaderCell("Status", 1),
                            _buildTableHeaderCell("Actions", 1, alignEnd: true),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1.0,
                        color: Colors.grey[200],
                      ),
                      // List Items
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredSpecialists.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 0.3,
                          color: AppColors.grey.withValues(alpha: 0.4),
                        ),
                        itemBuilder: (context, index) {
                          final specialist =
                              controller.filteredSpecialists[index];
                          final bool isSelected = controller.selectedIds
                              .contains(specialist.id);
                          return InkWell(
                            onTap: () =>
                                controller.toggleSelection(specialist.id),
                            hoverColor: AppColors.primaryRed.withValues(
                              alpha: 0.05,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) => controller
                                        .toggleSelection(specialist.id),
                                  ),
                                  const SizedBox(width: 8),
                                  // Name Column with Image
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        _buildAvatar(
                                          imageUrl:
                                              specialist.image != null &&
                                                  specialist.image!.isNotEmpty
                                              ? ApiService.getImageUrl(
                                                  specialist.image,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          specialist.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.softBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Role Column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      specialist.role,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.softBlack,
                                      ),
                                    ),
                                  ),
                                  // Services Column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      () {
                                        final count = specialist.specializations
                                            .split(',')
                                            .where((s) => s.trim().isNotEmpty)
                                            .length;
                                        return count == 0
                                            ? "No services yet"
                                            : "$count ${count == 1 ? 'Service' : 'Services'}";
                                      }(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.softBlack,
                                      ),
                                    ),
                                  ),
                                  // Experience Column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      specialist.experience,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.softBlack,
                                      ),
                                    ),
                                  ),
                                  // Status Column
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildStatusChip(
                                        specialist.status,
                                      ),
                                    ),
                                  ),
                                  // Actions Column
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        buildActionIcon(
                                          svgPath: AppIcons.edit,
                                          color: AppColors.primaryRed,
                                          onTap: () {
                                            _defer(() {
                                              controller.editSpecialist(
                                                specialist,
                                              );
                                              _scrollToTop();
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 16),
                                        buildActionIcon(
                                          svgPath: AppIcons.trash,
                                          color: AppColors.primaryRed,
                                          onTap: () => showDeleteConfirm(
                                            context: context,
                                            message:
                                                "Are you sure you want to delete this specialist ?",
                                            onDelete: () =>
                                                controller.deleteSpecialist(
                                                  specialist.id,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildListHeader(
    BuildContext context,
    SpecialistController controller,
  ) {
    return Responsive(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalCount(controller),
          const SizedBox(height: 16),
          if (controller.selectedIds.isNotEmpty) ...[
            _buildBulkDeleteButton(context, controller),
            const SizedBox(height: 16),
          ],
          _buildSearchBar(controller),
        ],
      ),
      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTotalCount(controller),
              if (controller.selectedIds.isNotEmpty) ...[
                const SizedBox(width: 16),
                _buildBulkDeleteButton(context, controller),
              ],
            ],
          ),
          _buildSearchBar(controller),
        ],
      ),
    );
  }

  Widget _buildTotalCount(SpecialistController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "Total Specialists: ${controller.specialists.length}",
        style: const TextStyle(
          color: AppColors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBulkDeleteButton(
    BuildContext context,
    SpecialistController controller,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        showBulkDeleteDialog(
          context: context,
          count: controller.selectedIds.length,
          itemNamePlural: "specialists",
          onConfirm: controller.deleteSelectedSpecialists,
          backgroundColor: AppColors.grey,
          titleColor: AppColors.white,
          contentColor: AppColors.white,
          cancelColor: AppColors.white,
          confirmBackgroundColor: AppColors.grey,
          confirmTextColor: AppColors.white,
          dialogRadius: 6,
          buttonRadius: 6,
        );
      },

      icon: SvgPicture.asset(
        AppIcons.trash,
        width: 18,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: Text("Delete (${controller.selectedIds.length})"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildSearchBar(SpecialistController controller) {
    return SizedBox(
      width: 300,
      height: 40,
      child: TextField(
        style: const TextStyle(color: AppColors.softBlack, fontSize: 13),
        onChanged: (value) => controller.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: "Search Specialists...",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistForm(
    BuildContext context,
    SpecialistController controller,
  ) {
    bool isMobile = Responsive.isMobile(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                controller.editingSpecialist == null
                    ? "New Specialist"
                    : "Edit Specialist",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive(
            mobile: Column(
              children: [
                _buildImagePicker(controller),
                const SizedBox(height: 24),
                _buildFormFields(context, controller),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(controller),
                const SizedBox(width: 24),
                Expanded(child: _buildFormFields(context, controller)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDescriptionField(controller),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              buildVisibilityStatusSection(
                currentStatus: controller.status,
                onStatusChanged: (val) => controller.setStatus(val),
                iconPath: AppIcons.visible,
              ),
              _buildActionButtons(context, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(SpecialistController controller) {
    bool hasImage =
        controller.hasImage ||
        (controller.editingSpecialist?.image != null &&
            controller.editingSpecialist!.image!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                width: 150,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: _buildImageContent(controller),
              ),
            ),
            if (hasImage)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => controller.clearImage(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      AppIcons.trash,
                      width: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent(SpecialistController controller) {
    if (controller.webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(controller.webImage!, fit: BoxFit.cover),
      );
    }

    if (controller.pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(controller.pickedImage!, fit: BoxFit.cover),
      );
    }

    if (controller.editingSpecialist?.image != null &&
        controller.editingSpecialist!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingSpecialist!.image),
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          errorWidget: (context, url, error) => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                "Image failed",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.upload,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
        const SizedBox(height: 8),
        const Text(
          "Add Image",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    SpecialistController controller,
  ) {
    bool isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildField(
                label: "Full Name",
                controller: controller.nameController,
                hint: "Enter name",
                svgPath: AppIcons.users,
              ),
            ),
            if (!isMobile) const SizedBox(width: 16),
            if (isMobile) const SizedBox(height: 16),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildField(
                label: "Role",
                controller: controller.roleController,
                hint: "e.g. Senior Stylist",
                svgPath: AppIcons.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildServicesHeader(context, controller),
            ),
            if (!isMobile) const SizedBox(width: 16),
            if (isMobile) const SizedBox(height: 16),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildField(
                label: "Experience",
                controller: controller.experienceController,
                hint: "e.g. 5 Years",
                svgPath: AppIcons.info,
              ),
            ),
          ],
        ),
        if (controller.showServicesList) ...[
          const SizedBox(height: 16),
          _buildServicesList(context, controller),
        ],
      ],
    );
  }

  Widget _buildServicesHeader(
    BuildContext context,
    SpecialistController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Specializations",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.softBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.selectedServices.isEmpty
                    ? "No services yet"
                    : "${controller.selectedServices.length} services selected",
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.softBlack,
                ),
              ),
              TextButton(
                onPressed: () => controller.setShowServicesList(
                  !controller.showServicesList,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.primaryRed,
                ),
                child: Text(
                  controller.showServicesList ? "Close" : "Change",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    SpecialistController controller,
  ) {
    return Column(
      children: [
        // Search and Category Filter
        Consumer<CategoryController>(
          builder: (context, catController, child) {
            final categories =
                ["All Categories"] +
                catController.categories.map((c) => c.title).toList();

            return Row(
              children: [
                // Search
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller.servicesSearchController,
                    "Search services...",
                    hint: "Search by name...",
                    onChanged: (val) => controller.setServicesSearchQuery(val),
                    prefix: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        AppIcons.search,
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Category
                Expanded(
                  flex: 2,
                  child: _buildDropdown(
                    categories,
                    controller.selectedServicesCategory ?? "All Categories",
                    onChanged: (val) => controller.setSelectedServicesCategory(
                      val == "All Categories" ? null : val,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        // Services List
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Consumer<ServicesController>(
            builder: (context, servicesController, child) {
              if (servicesController.isLoading &&
                  servicesController.services.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredServices = servicesController.services.where((s) {
                final matchesCategory =
                    controller.selectedServicesCategory == null ||
                    s.category == controller.selectedServicesCategory;
                final matchesSearch =
                    controller.servicesSearchQuery.isEmpty ||
                    s.name.toLowerCase().contains(
                      controller.servicesSearchQuery.toLowerCase(),
                    );
                return matchesCategory && matchesSearch;
              }).toList();

              if (filteredServices.isEmpty) {
                return const Center(child: Text("No services found"));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: filteredServices.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 0.5, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  final isSelected = controller.selectedServices.contains(
                    service.name,
                  );

                  return InkWell(
                    onTap: () =>
                        controller.toggleServiceSelection(service.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: service.image != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        ApiService.getImageUrl(service.image),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[100],
                            ),
                            child: service.image == null
                                ? const Icon(Icons.image, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  service.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primaryRed,
                            onChanged: (val) =>
                                controller.toggleServiceSelection(service.name),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hint,
    String? svgPath,
    Widget? prefix,
    bool isPassword = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
      decoration: InputDecoration(
        hintText: hint ?? label,
        hintStyle: TextStyle(
          color: AppColors.grey.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon:
            prefix ??
            (svgPath != null
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      svgPath,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        AppColors.grey.withValues(alpha: 0.5),
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : null),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value, {
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.softBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(SpecialistController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildHeadingWithIcon("Description", AppIcons.info),
            Text(
              "${controller.wordCount}/200 words",
              style: TextStyle(
                fontSize: 11,
                color: controller.isDescriptionValid ? Colors.grey : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.descriptionController,
          onChanged: (val) => controller.updateWordCount(val),
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          decoration: InputDecoration(
            hintText: "Enter specialist bio or description...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SpecialistController controller,
  ) {
    return buildFormActionButtons(
      onSave: () => controller.saveSpecialist(context),
      onDiscard: () => controller.setAdding(false),
      isLoading: controller.isSaving,
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String svgPath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon(label, svgPath),
        const SizedBox(height: 8),
        _buildTextField(controller, label, hint: hint, svgPath: svgPath),
      ],
    );
  }

  Widget _buildTableHeaderCell(
    String text,
    int flex, {
    double? width,
    bool alignEnd = false,
  }) {
    Widget content = Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.grey,
        letterSpacing: 0.5,
      ),
    );

    if (width != null) {
      return SizedBox(
        width: width,
        child: alignEnd
            ? Align(alignment: Alignment.centerRight, child: content)
            : content,
      );
    }

    return Expanded(
      flex: flex,
      child: alignEnd
          ? Align(alignment: Alignment.centerRight, child: content)
          : content,
    );
  }

  Widget _buildAvatar({String? imageUrl, double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? AppNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 20, color: Colors.grey),
            )
          : const Icon(Icons.image, size: 20, color: Colors.grey),
    );
  }

  Widget _buildStatusChip(String status) {
    final isPublished = status == "Published";
    return Container(
      width: 85, // Narrow width ONLY for Specialist screen
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isPublished
            ? AppColors.primaryRed
            : AppColors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPublished ? AppColors.white : AppColors.softBlack,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
