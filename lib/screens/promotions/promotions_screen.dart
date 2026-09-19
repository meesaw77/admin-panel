import 'package:admin/controllers/promotions/promotions_controller.dart';
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

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  late PromotionsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<PromotionsController>();
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
      body: Consumer<PromotionsController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Responsive(
                  mobile: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTitle(),
                      const SizedBox(height: 16),
                      _buildHeaderButtons(context, controller),
                    ],
                  ),
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderTitle(),
                      _buildHeaderButtons(context, controller),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchPromotions(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (controller.isAdding) ...[
                            _buildPromotionForm(context, controller),
                            const SizedBox(height: 48),
                            Divider(
                              height: 1,
                              thickness: 0.1,
                              color: Colors.grey[200],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // List Section Title
                          Text(
                            controller.editingPromotion != null
                                ? "Existing ${controller.editingPromotion!.type}s"
                                : "Existing Promotions",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softBlack,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildPromotionList(context, controller),
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

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _controller.isAdding && _controller.editingPromotion != null
              ? "${_controller.editingPromotion!.type} Management"
              : "Promotion Management",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.softBlack,
            fontFamily: "Libre",
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _controller.isAdding && _controller.editingPromotion != null
              ? "Manage your ${_controller.editingPromotion!.type.toLowerCase()} details and settings"
              : "Manage your marketing banners and special offers",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildHeaderButtons(
    BuildContext context,
    PromotionsController controller,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (controller.selectedIds.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () {
              showBulkDeleteDialog(
                context: context,
                count: controller.selectedIds.length,
                itemNamePlural: "promotions",
                onConfirm: controller.deleteSelectedPromotions,
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
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            label: Text("Delete (${controller.selectedIds.length})"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            controller.setAdding(!controller.isAdding);
            if (controller.isAdding) _scrollToTop();
          },
          icon: SvgPicture.asset(
            controller.isAdding ? AppIcons.cross : AppIcons.plus,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          label: Text(controller.isAdding ? "Close Form" : "Create Promotion"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionForm(
    BuildContext context,
    PromotionsController controller,
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
                "${controller.type} Details",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isMobile) ...[
            _buildField(
              "Promotion Title",
              controller.titleController,
              "e.g. 20% Off All Services...",
              svgPath: AppIcons.blogging,
            ),
            const SizedBox(height: 24),
            _buildTypeDropdown(controller),
            const SizedBox(height: 24),
            _buildImageSection(controller),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildField(
                        "Promotion Title",
                        controller.titleController,
                        "e.g. 20% Off All Services...",
                        svgPath: AppIcons.blogging,
                      ),
                      const SizedBox(height: 24),
                      _buildTypeDropdown(controller),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildImageSection(controller)),
              ],
            ),
          ],
          const SizedBox(height: 32),
          Divider(height: 1, thickness: 0.1, color: Colors.grey[200]),
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
                onSave: () => controller.savePromotion(
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

  Widget _buildImageSection(PromotionsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Promotion Banner", AppIcons.image),
        const SizedBox(height: 12),
        Stack(
          children: [
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: _buildImageContent(controller),
              ),
            ),
            if (controller.hasImage ||
                (controller.editingPromotion?.image?.isNotEmpty ?? false))
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

  Widget _buildImageContent(PromotionsController controller) {
    if (controller.webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          controller.webImage!,
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      );
    }
    if (controller.pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          controller.pickedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    if (controller.editingPromotion?.image != null &&
        controller.editingPromotion!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingPromotion!.image),
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.upload,
          colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          width: 60,
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload Promotion Banner",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPromotionList(
    BuildContext context,
    PromotionsController controller,
  ) {
    if (controller.isLoading && controller.promotions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primaryRed,
            size: 30,
          ),
        ),
      );
    }

    if (controller.promotions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "No promotions found.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return LayoutBuilder(
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
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    color: AppColors.white,
                    child: Row(
                      children: [
                        Checkbox(
                          value:
                              controller.selectedIds.length ==
                                  controller.promotions.length &&
                              controller.promotions.isNotEmpty,
                          onChanged: (val) =>
                              controller.selectAll(val ?? false),
                        ),
                        const SizedBox(width: 12),
                        _buildTableHeaderCell("Promotion", 3),
                        _buildTableHeaderCell("Type", 1),
                        _buildTableHeaderCell("Status", 1),
                        _buildTableHeaderCell("Actions", 1, alignEnd: true),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1.0, color: Colors.grey[200]),
                  Column(
                    children: List.generate(controller.promotions.length, (
                      index,
                    ) {
                      final promo = controller.promotions[index];
                      final bool isSelected = controller.selectedIds.contains(
                        promo.id,
                      );
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => controller.toggleSelection(promo.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (val) =>
                                        controller.toggleSelection(promo.id),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        _buildAvatar(
                                          width: 120,
                                          height: 60,
                                          imageUrl:
                                              promo.image != null &&
                                                  promo.image!.isNotEmpty
                                              ? ApiService.getImageUrl(
                                                  promo.image,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            promo.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.softBlack,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      promo.type,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.softBlack,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildStatusChip(promo.status),
                                    ),
                                  ),
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
                                              controller.editPromotion(promo);
                                              _scrollToTop();
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        buildActionIcon(
                                          svgPath: AppIcons.trash,
                                          color: AppColors.primaryRed,
                                          onTap: () => showDeleteConfirm(
                                            context: context,
                                            message:
                                                "Are you sure you want to delete this promotion banner ?",
                                            onDelete: () => controller
                                                .deletePromotion(promo.id),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < controller.promotions.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1.0,
                              color: AppColors.grey.withValues(alpha: 0.1),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    String? svgPath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (svgPath != null) ...[
          buildHeadingWithIcon(label, svgPath),
        ] else ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.softBlack,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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

  Widget _buildTableHeaderCell(String text, int flex, {bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildAvatar({
    String? imageUrl,
    double width = 60,
    double height = 60,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl.isNotEmpty)
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
                Icons.discount_outlined,
                color: AppColors.grey,
                size: 20,
              ),
            )
          : const Icon(
              Icons.discount_outlined,
              color: AppColors.grey,
              size: 20,
            ),
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

  Widget _buildTypeDropdown(PromotionsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Promotion Type", AppIcons.analytic),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: controller.type,
          icon: SvgPicture.asset(
            AppIcons.category,
            width: 14,
            colorFilter: ColorFilter.mode(
              AppColors.grey.withValues(alpha: 0.5),
              BlendMode.srcIn,
            ),
          ),
          dropdownColor: AppColors.white,
          decoration: InputDecoration(
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          items: ["Promotion", "Product"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.setType(newValue);
            }
          },
        ),
      ],
    );
  }
}
