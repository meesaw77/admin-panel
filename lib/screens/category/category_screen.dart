import 'package:admin/controllers/categories/category_controller.dart';
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

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late CategoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<CategoryController>();
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
      body: Consumer<CategoryController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Category Management",
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
                const SizedBox(height: 24),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchCategories(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (controller.isAdding) ...[
                            _buildCategoryForm(context, controller),
                            const SizedBox(height: 48),
                            Divider(
                              height: 1,
                              thickness: 1.0,
                              color: AppColors.grey.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Existing Categories",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.softBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildCategoryList(context, controller),
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

  Widget _buildHeaderButton(CategoryController controller) {
    return ElevatedButton.icon(
      onPressed: () {
        controller.setAdding(!controller.isAdding);
        if (controller.isAdding) _scrollToTop();
      },
      icon: SvgPicture.asset(
        controller.isAdding ? AppIcons.cross : AppIcons.plus,
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
      ),
      label: Text(controller.isAdding ? "Close Form" : "Create Category"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    CategoryController controller,
  ) {
    if (controller.isLoading && controller.categories.isEmpty) {
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

    if (controller.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: AppColors.softBlack.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                "No categories found. Create your first one!",
                style: TextStyle(color: AppColors.grey),
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
            final double tableWidth = constraints.maxWidth > 750
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
                              horizontal: 18,
                              vertical: 18,
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
                                          controller
                                              .filteredCategories
                                              .length &&
                                      controller.filteredCategories.isNotEmpty,
                                  onChanged: (val) =>
                                      controller.selectAll(val ?? false),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "Category Name".toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Status".toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Actions".toUpperCase(),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.grey,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1.0,
                            color: AppColors.grey.withValues(alpha: 0.2),
                          ),
                          // List Items
                          Column(
                            children: List.generate(controller.filteredCategories.length, (
                              index,
                            ) {
                              final category =
                                  controller.filteredCategories[index];
                              final bool isSelected = controller.selectedIds
                                  .contains(category.id);
                              return InkWell(
                                onTap: () =>
                                    controller.toggleSelection(category.id),
                                hoverColor: AppColors.primaryRed.withValues(
                                  alpha: 0.05,
                                ),
                                splashColor: AppColors.primaryRed.withValues(
                                  alpha: 0.1,
                                ),
                                highlightColor: AppColors.primaryRed.withValues(
                                  alpha: 0.1,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (val) => controller
                                                .toggleSelection(category.id),
                                          ),
                                          const SizedBox(width: 8),
                                          // Combined Image & Title Column
                                          Expanded(
                                            flex: 4,
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.white,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child:
                                                      category.image != null &&
                                                          category
                                                              .image!
                                                              .isNotEmpty
                                                      ? AppNetworkImage(
                                                          imageUrl:
                                                              ApiService.getImageUrl(
                                                                category.image,
                                                              ),
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: LoadingAnimationWidget.staggeredDotsWave(
                                                                  color: AppColors
                                                                      .primaryRed,
                                                                  size: 20,
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) {
                                                                return const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  size: 16,
                                                                  color:
                                                                      AppColors
                                                                          .grey,
                                                                );
                                                              },
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 16,
                                                          color: AppColors.grey,
                                                        ),
                                                ),
                                                const SizedBox(width: 16),
                                                Text(
                                                  category.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: AppColors.softBlack,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Status Column
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 85,
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        category.status ==
                                                            "Published"
                                                        ? AppColors.primaryRed
                                                        : AppColors.grey
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    category.status,
                                                    style: TextStyle(
                                                      color:
                                                          category.status ==
                                                              "Published"
                                                          ? AppColors.white
                                                          : AppColors.softBlack,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Actions Column
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
                                                      controller.editCategory(
                                                        category,
                                                      );
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
                                                        "Are you sure you want to delete this category ?",
                                                    onDelete: () => controller
                                                        .deleteCategory(
                                                          category.id,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index <
                                        controller.filteredCategories.length -
                                            1)
                                      Divider(
                                        height: 1,
                                        thickness: 0.2,
                                        color: AppColors.grey.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                  ],
                                ),
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
        ),
      ],
    );
  }

  Widget _buildListHeader(BuildContext context, CategoryController controller) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.grey, width: 0.5),
          ),
          child: Text(
            "Total Categories: ${controller.categories.length}",
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        if (controller.selectedIds.isNotEmpty) ...[
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              showBulkDeleteDialog(
                context: context,
                count: controller.selectedIds.length,
                itemNamePlural: "categories",
                onConfirm: controller.deleteSelectedCategories,
                backgroundColor: AppColors.grey,
                titleColor: AppColors.white,
                contentColor: AppColors.white,
                cancelColor: AppColors.white,
                confirmBackgroundColor: AppColors.grey,
                confirmTextColor: AppColors.white,
                dialogRadius: 20,
                buttonRadius: 20,
              );
            },

            icon: SvgPicture.asset(
              AppIcons.trash,
              width: 18,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            label: Text("Delete(${controller.selectedIds.length})"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
        const Spacer(),
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            style: const TextStyle(color: AppColors.softBlack, fontSize: 13),
            onChanged: (value) => controller.setSearchQuery(value),
            decoration: InputDecoration(
              hintText: "Search Categories...",
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.grey,
              ),
              filled: true,
              fillColor: AppColors.white,
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
                borderSide: const BorderSide(color: AppColors.grey, width: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(CategoryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Add Description", AppIcons.blogging),
        const SizedBox(height: 12),
        TextField(
          controller: controller.descriptionController,
          maxLines: 4,
          style: const TextStyle(color: AppColors.softBlack),
          decoration: InputDecoration(
            hintText: "Write description of this category...",
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: const BorderSide(color: AppColors.grey, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryForm(
    BuildContext context,
    CategoryController controller,
  ) {
    return Column(
      children: [
        _buildFormCard(
          context,
          title: "Category Details",
          children: [
            Responsive(
              mobile: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(controller),
                  const SizedBox(height: 24),
                  _buildDescriptionField(controller),
                  const SizedBox(height: 32),
                  buildVisibilityStatusSection(
                    currentStatus: controller.status,
                    onStatusChanged: (val) => controller.setStatus(val),
                    iconPath: AppIcons.visible,
                  ),
                  const SizedBox(height: 32),
                  _buildImageSection(controller),
                ],
              ),
              tablet: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleField(controller),
                          const SizedBox(height: 24),
                          _buildDescriptionField(controller),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    VerticalDivider(
                      width: 1,
                      thickness: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: buildVisibilityStatusSection(
                        currentStatus: controller.status,
                        onStatusChanged: (val) => controller.setStatus(val),
                        iconPath: AppIcons.visible,
                      ),
                    ),
                    const SizedBox(width: 32),
                    VerticalDivider(
                      width: 1,
                      thickness: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildImageSection(controller)),
                  ],
                ),
              ),
              desktop: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleField(controller),
                          const SizedBox(height: 24),
                          _buildDescriptionField(controller),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    VerticalDivider(
                      width: 1,
                      thickness: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: buildVisibilityStatusSection(
                        currentStatus: controller.status,
                        onStatusChanged: (val) => controller.setStatus(val),
                        iconPath: AppIcons.visible,
                      ),
                    ),
                    const SizedBox(width: 32),
                    VerticalDivider(
                      width: 1,
                      thickness: 0.5,
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildImageSection(controller)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        buildFormActionButtons(
          onDiscard: () => controller.setAdding(false),
          onSave: () => controller.saveCategory(context),
          isLoading: controller.isSaving,
          saveText: controller.editingCategory != null
              ? "Update Category"
              : "Save Category",
          buttonRadius: 6,
          savePadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          loaderColor: AppColors.primaryRed,
        ),
      ],
    );
  }

  Widget _buildFormCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTitleField(CategoryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Add Category Title", AppIcons.category),
        const SizedBox(height: 12),
        TextField(
          controller: controller.titleController,
          style: const TextStyle(color: AppColors.softBlack),
          decoration: InputDecoration(
            hintText: "e.g. Skin Care, Hair Style...",
            hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.white,
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
              borderSide: const BorderSide(color: AppColors.grey, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(CategoryController controller) {
    final bool hasImage =
        controller.webImage != null ||
        controller.pickedImage != null ||
        (controller.editingCategory?.image != null &&
            controller.editingCategory!.image!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Category Image", AppIcons.image),
        const SizedBox(height: 12),
        Stack(
          children: [
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.2),
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
                      color: AppColors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      AppIcons.trash,
                      width: 18,
                      height: 18,
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

  Widget _buildImageContent(CategoryController controller) {
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

    if (controller.editingCategory?.image != null &&
        controller.editingCategory!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingCategory!.image),
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint("EDIT IMAGE FAIL => $url");
            return const Icon(Icons.broken_image, color: AppColors.grey);
          },
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.upload,
          colorFilter: ColorFilter.mode(
            AppColors.grey.withValues(alpha: 0.4),
            BlendMode.srcIn,
          ),
          width: 60,
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload Image",
          style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
