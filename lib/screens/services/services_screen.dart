import 'package:admin/controllers/categories/category_controller.dart';
import 'package:admin/models/category_model.dart';
import 'package:admin/controllers/services/services_controller.dart';
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
import '../../widgets/action_button.dart';
import '../../widgets/heading_icon.dart';
import '../../widgets/icon_button.dart';
import '../../widgets/visibility.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late ServicesController _servicesController;
  late CategoryController _categoryController;

  @override
  void initState() {
    super.initState();
    _servicesController = context.read<ServicesController>();
    _categoryController = context.read<CategoryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _servicesController.startPolling();
        _categoryController.startPolling();
      }
    });
  }

  @override
  void dispose() {
    _servicesController.stopPolling();
    _categoryController.stopPolling();
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
      body: Consumer2<ServicesController, CategoryController>(
        builder: (context, controller, categoryController, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Header Section
                Responsive(
                  mobile: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Services Management",
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
                        "Services Management",
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
                const SizedBox(height: 24),

                // Scrollable Content Section
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchServices(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (controller.isAdding) ...[
                            _buildServiceForm(
                              context,
                              controller,
                              categoryController,
                            ),
                            const SizedBox(height: 48),
                            Divider(
                              height: 1,
                              thickness: 1.0,
                              color: Colors.grey[200],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Existing Services",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.softBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildServiceList(context, controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderButton(ServicesController controller) {
    return ElevatedButton.icon(
      onPressed: () {
        controller.setAdding(!controller.isAdding);
        if (controller.isAdding) _scrollToTop();
      },
      icon: SvgPicture.asset(
        controller.isAdding ? AppIcons.cross : AppIcons.plus,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: Text(controller.isAdding ? "Close Form" : "Create Service"),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildServiceForm(
    BuildContext context,
    ServicesController controller,
    CategoryController categoryController,
  ) {
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
              SvgPicture.asset(
                AppIcons.services,
                width: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Service Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive(
            mobile: Column(
              children: [
                _buildBasicInfoFields(controller, categoryController),
                const SizedBox(height: 32),
                _buildImageSection(controller),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildBasicInfoFields(controller, categoryController),
                ),
                const SizedBox(width: 48),
                Expanded(flex: 2, child: _buildImageSection(controller)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, thickness: 1.0, color: Colors.grey[200]),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildVisibilityStatusSection(
                currentStatus: controller.status,
                onStatusChanged: (val) => controller.setStatus(val),
                iconPath: AppIcons.visible,
              ),
              buildFormActionButtons(
                onDiscard: () => controller.setAdding(false),
                onSave: () => controller.saveService(
                  context,
                ), // change save method if needed
                isLoading: controller.isSaving,
                saveText: "Save Changes",
                buttonRadius: 6,
                savePadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                loaderColor: AppColors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoFields(
    ServicesController controller,
    CategoryController categoryController,
  ) {
    return Column(
      children: [
        _buildField(
          "Service Name",
          null,
          controller.nameController,
          "e.g. Hair Cut, Facial Treatment...",
        ),
        const SizedBox(height: 24),
        Flex(
          direction: Responsive.isMobile(context)
              ? Axis.vertical
              : Axis.horizontal,
          children: [
            Expanded(
              flex: Responsive.isMobile(context) ? 0 : 1,
              child: _buildField(
                "Price",
                AppIcons.pound,
                controller.priceController,
                "e.g. 45.00",
                keyboardType: TextInputType.number,
              ),
            ),
            if (!Responsive.isMobile(context)) const SizedBox(width: 24),
            if (Responsive.isMobile(context)) const SizedBox(height: 24),
            Expanded(
              flex: Responsive.isMobile(context) ? 0 : 1,
              child: _buildField(
                "Loyalty Points",
                AppIcons.badge,
                controller.loyaltyPointsController,
                "e.g. 15",
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildResponsiveRow(
          context: context,
          children: [
            _buildDropdownField<Category?>(
              label: "Category",
              svgPath: AppIcons.category,
              hintText: "Select Category",
              value: categoryController.categories.cast<Category?>().firstWhere(
                (c) =>
                    (c?.title ?? "").trim().toLowerCase() ==
                    (controller.selectedCategory ?? "").trim().toLowerCase(),
                orElse: () => null,
              ),
              items: categoryController.categories,
              itemLabel: (c) => c?.title ?? "",

              onChanged: (val) {
                controller.setCategory(val?.title); // ✅ only name
              },
            ),

            _buildDurationSelector(controller),
          ],
        ),
        const SizedBox(height: 24),
        _buildDescriptionField(controller),
      ],
    );
  }

  Widget _buildDescriptionField(ServicesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          "Description",
          AppIcons.blogging,
          controller.descriptionController,
          "Enter service description...",
          maxLines: 4,
          onChanged: (val) => controller.updateWordCount(val),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "${controller.wordCount}/200 words",
            style: TextStyle(
              fontSize: 11,
              color: controller.isDescriptionValid ? Colors.grey : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(ServicesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Service Image", AppIcons.image),
        const SizedBox(height: 12),
        Stack(
          children: [
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: _buildServiceImageContent(controller),
              ),
            ),
            if (controller.hasImage ||
                (controller.editingService?.image?.isNotEmpty ?? false))
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => controller.clearImage(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
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
                      height: 16,
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

  Widget _buildServiceImageContent(ServicesController controller) {
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

    if (controller.editingService?.image != null &&
        controller.editingService!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingService!.image),
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.upload,
          colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          width: 40,
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload Image",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildServiceList(
    BuildContext context,
    ServicesController controller,
  ) {
    if (controller.isLoading && controller.services.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }

    // Truly no data at all
    if (controller.services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.miscellaneous_services,
                size: 64,
                color: AppColors.softBlack.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                "No services found.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildListHeader(context, controller),
        ),
        const SizedBox(height: 16),
        // Search returned no results — show contextual message below the search bar
        if (controller.filteredServices.isEmpty) ...[  
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.softBlack.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  "No results for \"${controller.searchQuery}\"",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ] else ...[
        LayoutBuilder(
          builder: (context, constraints) {
            double tableWidth = (constraints.maxWidth - 32) > 800
                ? (constraints.maxWidth - 32)
                : 800;
            return CustomHorizontalScrollbar(
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    mainAxisSize: MainAxisSize.min,
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
                                      controller.filteredServices.length &&
                                  controller.filteredServices.isNotEmpty,
                              onChanged: (val) =>
                                  controller.selectAll(val ?? false),
                            ),
                            const SizedBox(width: 8),
                            _buildTableHeaderCell("Service", 6),
                            _buildTableHeaderCell("Category", 3),
                            _buildTableHeaderCell("Duration", 3),
                            _buildTableHeaderCell("Loyalty", 3),
                            _buildTableHeaderCell("Price", 2),
                            _buildTableHeaderCell("Status", 0, width: 85),
                            _buildTableHeaderCell("Actions", 2, alignEnd: true),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1.0,
                        color: Colors.grey[200],
                      ),
                      // List Items
                      ...List.generate(controller.filteredServices.length, (
                        index,
                      ) {
                        final service = controller.filteredServices[index];
                        final bool isSelected = controller.selectedIds.contains(
                          service.id,
                        );
                        return Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  controller.toggleSelection(service.id),
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
                                          .toggleSelection(service.id),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 6,
                                      child: Row(
                                        children: [
                                          _buildAvatar(
                                            imageUrl:
                                                service.image != null &&
                                                    service.image!.isNotEmpty
                                                ? ApiService.getImageUrl(
                                                    service.image,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              service.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.softBlack,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        service.category,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.softBlack,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        () {
                                          final int h = service.duration ~/ 60;
                                          final int m = service.duration % 60;
                                          if (h > 0 && m > 0) {
                                            return "${h}h ${m}m";
                                          }
                                          if (h > 0) return "${h}h";
                                          return "$m min";
                                        }(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.softBlack,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "${service.loyaltyPoints} pts",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.softBlack,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppIcons.pound,
                                            width: 14,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.primaryRed,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            service.price.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.softBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusChip(service.status),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          buildActionIcon(
                                            svgPath: AppIcons.edit,
                                            color: AppColors.primaryRed,
                                            onTap: () {
                                              _defer(() {
                                                controller.editService(service);
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
                                                  "Are you sure you want to delete this service ?",
                                              onDelete: () => controller
                                                  .deleteService(service.id),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < controller.filteredServices.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1.0,
                                color: AppColors.grey.withValues(alpha: 0.1),
                              ),
                          ],
                        );
                      }),
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
      ],
    );
  }

  Widget _buildListHeader(BuildContext context, ServicesController controller) {
    return Responsive(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "Total Services: ${controller.filteredServices.length}",
              style: const TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Search
          _buildSearchField(controller),

          if (controller.selectedIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildBulkActions(context, controller),
          ],
        ],
      ),

      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: Total + Delete
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Total Services: ${controller.filteredServices.length}",
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              if (controller.selectedIds.isNotEmpty) ...[
                const SizedBox(width: 16),
                _buildBulkActions(context, controller),
              ],
            ],
          ),

          // RIGHT: Search
          SizedBox(width: 300, child: _buildSearchField(controller)),
        ],
      ),
    );
  }

  Widget _buildSearchField(ServicesController controller) {
    return TextField(
      onChanged: (val) => controller.setSearchQuery(val),
      style: const TextStyle(color: AppColors.softBlack, fontSize: 13),
      decoration: InputDecoration(
        hintText: "Search services...",
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
        filled: true,
        fillColor: AppColors.grey.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.grey, width: 0.5),
        ),
      ),
    );
  }

  Widget _buildBulkActions(
    BuildContext context,
    ServicesController controller,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        showBulkDeleteDialog(
          context: context,
          count: controller.selectedIds.length,
          itemNamePlural: "services",
          onConfirm: controller.deleteSelectedServices,
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
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        width: 16,
      ),
      label: Text("Delete (${controller.selectedIds.length})"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildDurationSelector(ServicesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Duration", AppIcons.duration),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.durationHourController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.softBlack,
                ),
                decoration: InputDecoration(
                  hintText: "Hours",
                  hintStyle: TextStyle(
                    color: AppColors.grey.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.durationMinuteController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.softBlack,
                ),
                decoration: InputDecoration(
                  hintText: "Minutes",
                  hintStyle: TextStyle(
                    color: AppColors.grey.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
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
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String? svgPath,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon(label, svgPath),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.grey.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
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
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String svgPath,
    required T? value, // ✅ nullable
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
    String Function(T)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon(label, svgPath),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.softBlack,
                fontWeight: FontWeight.w500,
              ),
              hint: hintText != null
                  ? Text(
                      hintText,
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  : null,
              elevation: 4,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.grey,
                size: 24,
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        itemLabel != null ? itemLabel(e) : e.toString(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
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
      text.toUpperCase(),
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.grey,
        letterSpacing: 1.1,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: content);
    }
    return Expanded(flex: flex, child: content);
  }

  Widget _buildAvatar({String? imageUrl, double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? AppNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.image_outlined,
                color: AppColors.grey,
                size: 20,
              ),
            )
          : const Icon(Icons.image_outlined, color: AppColors.grey, size: 20),
    );
  }

  Widget _buildStatusChip(String status) {
    final isPublished = status == "Published";
    return Container(
      width: 85,
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPublished ? AppColors.white : AppColors.softBlack,
        ),
      ),
    );
  }

  Widget _buildResponsiveRow({
    required BuildContext context,
    required List<Widget> children,
  }) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: children
            .map(
              (c) => Padding(
                padding: EdgeInsets.only(bottom: c == children.last ? 0 : 24),
                child: c,
              ),
            )
            .toList(),
      );
    }
    return Row(
      children: children
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: c == children.last ? 0 : 24),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }
}
