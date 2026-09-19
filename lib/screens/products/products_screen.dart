import 'package:admin/controllers/products/product_controller.dart';
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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late ProductController _productController;

  @override
  void initState() {
    super.initState();
    _productController = context.read<ProductController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _productController.startPolling();
    });
  }

  @override
  void dispose() {
    _productController.stopPolling();
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
      body: Consumer<ProductController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Responsive(
                  mobile: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTitle(),
                      const SizedBox(height: 16),
                      _buildHeaderActions(controller),
                    ],
                  ),
                  desktop: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderTitle(),
                      _buildHeaderActions(controller),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchProducts(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (controller.isAdding) ...[
                            _buildProductForm(context, controller),
                            const SizedBox(height: 48),
                            Divider(
                              height: 1,
                              thickness: 0.1,
                              color: Colors.grey[200],
                            ),
                            const SizedBox(height: 24),
                          ],

                          const Text(
                            "Existing Products",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softBlack,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildProductList(context, controller),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Management",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.softBlack,
            fontFamily: "Libre",
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Manage your inventory and product listings",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildHeaderActions(ProductController controller) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            controller.setAdding(!controller.isAdding);
            if (controller.isAdding) {
              _scrollToTop();
            }
          },
          icon: SvgPicture.asset(
            controller.isAdding ? AppIcons.cross : AppIcons.plus,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          label: Text(controller.isAdding ? "Close Form" : "Create Product"),
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

  Widget _buildProductForm(BuildContext context, ProductController controller) {
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
                AppIcons.product,
                width: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Product Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Responsive(
            mobile: Column(
              children: [
                _buildBasicInfoFields(controller),
                const SizedBox(height: 32),
                _buildProductImageSection(controller),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildBasicInfoFields(controller)),
                const SizedBox(width: 48),
                Expanded(flex: 2, child: _buildProductImageSection(controller)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${controller.wordCount}/200 words",
              style: TextStyle(
                fontSize: 11,
                color: controller.isDescriptionValid ? Colors.grey : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                onSave: () => controller.saveProduct(context),
                onDiscard: () => controller.setAdding(false),
                isLoading: controller.isSaving,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoFields(ProductController controller) {
    return Column(
      children: [
        _buildField(
          label: "Product Name",
          controller: controller.nameController,
          hint: "e.g. Lip Gloss, Eye Shadow...",
        ),
        const SizedBox(height: 24),
        _buildField(
          label: "Price",
          svgPath: AppIcons.pound,
          controller: controller.priceController,
          hint: "e.g. 29.99",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _buildField(
          label: "Description",
          svgPath: AppIcons.blogging,
          controller: controller.descriptionController,
          hint: "Enter product description...",
          maxLines: 4,
          onChanged: (val) => controller.updateWordCount(val),
        ),
      ],
    );
  }

  Widget _buildProductImageSection(ProductController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Product Image", AppIcons.image),
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
                child: _buildProductImageContent(controller),
              ),
            ),
            if (controller.hasImage ||
                (controller.editingProduct?.image?.isNotEmpty ?? false))
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

  Widget _buildProductImageContent(ProductController controller) {
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
    if (controller.editingProduct?.image != null &&
        controller.editingProduct!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingProduct!.image),
          fit: BoxFit.cover,
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
          width: 40,
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload Product Image",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductList(BuildContext context, ProductController controller) {
    if (controller.isLoading && controller.products.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.primaryRed,
            size: 20,
          ),
        ),
      );
    }

    if (controller.products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("No products found.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListHeader(context, controller),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double tableWidth =
                constraints.maxWidth > 800 ? constraints.maxWidth : 800;
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
                              value: controller.selectedIds.length ==
                                      controller.filteredProducts.length &&
                                  controller.filteredProducts.isNotEmpty,
                              onChanged: (val) =>
                                  controller.selectAll(val ?? false),
                            ),
                            const SizedBox(width: 8),
                            _buildTableHeaderCell("Name", 4),
                            _buildTableHeaderCell("Price", 1),
                            _buildTableHeaderCell("Status", 0, width: 85),
                            _buildTableHeaderCell("Actions", 2,
                                alignEnd: true),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1.0,
                        color: Colors.grey[200],
                      ),
                      Column(
                        children: List.generate(
                          controller.filteredProducts.length,
                          (index) {
                            final product =
                                controller.filteredProducts[index];
                            final bool isSelected = controller.selectedIds
                                .contains(product.id);
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () =>
                                      controller.toggleSelection(product.id),
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
                                              .toggleSelection(product.id),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              _buildAvatar(
                                                imageUrl: product.image !=
                                                            null &&
                                                        product.image!
                                                            .isNotEmpty
                                                    ? ApiService.getImageUrl(
                                                        product.image,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: AppColors.softBlack,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                AppIcons.pound,
                                                width: 14,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  AppColors.primaryRed,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.price
                                                    .toStringAsFixed(2),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.softBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildStatusChip(product.status),
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
                                                    controller
                                                        .editProduct(product);
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
                                                      "Are you sure you want to delete this product ?",
                                                  onDelete: () => controller
                                                      .deleteProduct(
                                                          product.id),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (index < controller.filteredProducts.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: AppColors.grey.withValues(alpha: 0.1),
                                  ),
                              ],
                            );
                          },
                        ),
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

  Widget _buildListHeader(BuildContext context, ProductController controller) {
    return Responsive(
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "Total Products: ${controller.products.length}",
              style: const TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
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
                  "Total Products: ${controller.products.length}",
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
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

  Widget _buildBulkDeleteButton(
    BuildContext context,
    ProductController controller,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        showBulkDeleteDialog(
          context: context,
          count: controller.selectedIds.length,
          itemNamePlural: "products",
          onConfirm: controller.deleteSelectedProducts,
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
        width: 16,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: Text("Delete (${controller.selectedIds.length})"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildSearchBar(ProductController controller) {
    return SizedBox(
      width: 300,
      height: 40,
      child: TextField(
        onChanged: (value) => controller.setSearchQuery(value),
        style: const TextStyle(fontSize: 13, color: AppColors.softBlack),
        decoration: InputDecoration(
          hintText: "Search Products...",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          filled: true,
          fillColor: AppColors.grey.withValues(alpha: 0.03),
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

  Widget _buildField({
    required String label,
    String? svgPath,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (svgPath != null) ...[
              SvgPicture.asset(
                svgPath,
                width: 14,
                colorFilter: const ColorFilter.mode(
                  AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.softBlack,
              ),
            ),
          ],
        ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
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
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 20, color: Colors.grey),
            )
          : const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
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
          color: isPublished ? AppColors.white : AppColors.softBlack,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
