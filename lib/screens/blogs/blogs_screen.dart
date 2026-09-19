import 'package:admin/controllers/blogs/blogs_controller.dart';
import 'package:admin/controllers/services/services_controller.dart';
import 'package:admin/models/blog_model.dart';
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

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  late final BlogsController _blogsController;

  @override
  void initState() {
    super.initState();
    _blogsController = context.read<BlogsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _blogsController.startPolling();
    });
  }

  @override
  void dispose() {
    _blogsController.stopPolling();
    super.dispose();
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

  void _defer(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => fn());
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Consumer<BlogsController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, controller),
                const SizedBox(height: 24),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchBlogs(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (controller.isAdding) ...[
                            _buildBlogForm(context, controller),
                            const SizedBox(height: 24),
                          ],
                          _buildBlogList(context, controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BlogsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Blog Management",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.softBlack,
                fontFamily: "Libre",
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage your articles, news and health tips",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            if (controller.selectedIds.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  showBulkDeleteDialog(
                    context: context,
                    count: controller.selectedIds.length,
                    itemNamePlural: "blogs",
                    onConfirm: controller.deleteSelectedBlogs,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                controller.setAdding(!controller.isAdding);
                if (controller.isAdding) {
                  _scrollToTop();
                }
              },
              icon: SvgPicture.asset(
                controller.isAdding ? AppIcons.cross : AppIcons.plus,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
              label: Text(controller.isAdding ? "Close Form" : "Create Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- BLOG FORM (UPDATED: NO 200 LIMIT + LINK + TOOLBAR) ----------------

  Widget _buildBlogForm(BuildContext context, BlogsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.blogging,
                width: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                controller.editingBlog != null
                    ? "Edit Post"
                    : "Create New Post",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormFields(controller),
                const SizedBox(height: 24),
                buildVisibilityStatusSection(
                  currentStatus: controller.status,
                  onStatusChanged: (val) => controller.setStatus(val),
                  iconPath: AppIcons.visible,
                ),
                const SizedBox(height: 24),
                _buildImageSection(controller),
              ],
            ),
            tablet: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildFormFields(controller)),
                  const SizedBox(width: 32),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey[200],
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
                    thickness: 1,
                    color: Colors.grey[200],
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
                  Expanded(flex: 3, child: _buildFormFields(controller)),
                  const SizedBox(width: 32),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey[200],
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
                    thickness: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _buildImageSection(controller)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildFormActionButtons(
                onDiscard: () => controller.setAdding(false),
                onSave: () => controller.saveBlog(context),
                isLoading: controller.isSaving,
                saveText: controller.editingBlog != null
                    ? "Update Blog"
                    : "Save Blog",
                buttonRadius: 6,
                savePadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                loaderColor: AppColors.primaryRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BlogsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          "Post Title",
          controller.titleController,
          "e.g. 5 Tips for Better Skin...",
        ),
        const SizedBox(height: 24),

        _buildServiceSelector(controller),
        const SizedBox(height: 24),

        // ✅ LINK FIELD (optional)
        _buildField(
          "Link (optional)",
          controller.linkController, // ✅ MUST exist in BlogsController
          "https://example.com",
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.softBlack,
              ),
            ),
            _WordCount(controller: controller.descriptionController),
          ],
        ),
        const SizedBox(height: 8),

        // ✅ NO LIMIT (removed onChanged updateWordCount + removed 200 counter)
        TextField(
          controller: controller.descriptionController,
          maxLines: 8,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.softBlack,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: "Write your content here...",
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

  Widget _buildImageSection(BlogsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeadingWithIcon("Cover Image", AppIcons.image),
        const SizedBox(height: 12),
        Stack(
          children: [
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                height: 250,
                width: 220,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: _buildImageContent(controller),
              ),
            ),
            if (controller.hasImage ||
                (controller.editingBlog?.image?.isNotEmpty ?? false))
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => controller.clearImage(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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

  Widget _buildImageContent(BlogsController controller) {
    if (controller.webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          controller.webImage!,
          fit: BoxFit.cover,
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

    if (controller.editingBlog?.image != null &&
        controller.editingBlog!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingBlog!.image),
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint("EDIT IMAGE FAIL => $url");
            return const Icon(Icons.broken_image, color: Colors.grey);
          },
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppIcons.upload,
          colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
          width: 50,
        ),
        const SizedBox(height: 12),
        const Text(
          "Upload cover image",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ---------------- BLOG LIST ----------------

  Widget _buildBlogList(BuildContext context, BlogsController controller) {
    if (controller.isLoading && controller.blogs.isEmpty) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth > 750.0
            ? constraints.maxWidth
            : 750.0;
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildListHeader(controller),
                  Divider(height: 1, thickness: 1.0, color: Colors.grey[200]),
                  Column(
                    children: List.generate(controller.filteredBlogs.length, (
                      index,
                    ) {
                      final blog = controller.filteredBlogs[index];
                      return Column(
                        children: [
                          _buildBlogItem(context, controller, blog),
                          if (index < controller.filteredBlogs.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1.0,
                              color: AppColors.grey.withValues(alpha: 0.4),
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

  Widget _buildListHeader(BlogsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: AppColors.white,
      child: Row(
        children: [
          Checkbox(
            value:
                controller.selectedIds.length ==
                    controller.filteredBlogs.length &&
                controller.filteredBlogs.isNotEmpty,
            onChanged: (val) => controller.selectAll(val ?? false),
          ),
          const SizedBox(width: 8),
          _buildTableHeaderCell("Post Title", 3),
          _buildTableHeaderCell("Category", 2),
          _buildTableHeaderCell("Status", 1, textAlign: TextAlign.center),
          _buildTableHeaderCell("Actions", 1, textAlign: TextAlign.end),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(
    String text,
    int flex, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text.toUpperCase(),
        textAlign: textAlign,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildBlogItem(
    BuildContext context,
    BlogsController controller,
    Blog blog,
  ) {
    final isSelected = controller.selectedIds.contains(blog.id);

    return InkWell(
      onTap: () => controller.toggleSelection(blog.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            IgnorePointer(child: Checkbox(value: isSelected, onChanged: null)),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _buildAvatar(
                    imageUrl: (blog.image != null && blog.image!.isNotEmpty)
                        ? ApiService.getImageUrl(blog.image)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      blog.title,
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
            _buildTableHeaderCell(blog.category ?? "-", 2),
            Expanded(
              flex: 1,
              child: Center(child: _buildStatusChip(blog.status)),
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
                        controller.editBlog(blog);
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
                      message: "Are you sure you want to delete this post ?",
                      onDelete: () => controller.deleteBlog(blog.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({String? imageUrl}) {
    return Container(
      height: 60,
      width: 60,
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
              errorWidget: (context, url, error) =>
                  const Icon(Icons.person, color: AppColors.grey, size: 20),
            )
          : const Icon(Icons.person, color: AppColors.grey, size: 20),
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

  // ---------------- SHARED FIELD + CATEGORY ----------------

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    String? svgPath,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
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
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.softBlack,
            fontWeight: FontWeight.w400,
          ),
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

  Widget _buildServiceSelector(BlogsController controller) {
    return Consumer<ServicesController>(
      builder: (context, servicesController, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeadingWithIcon("Category", AppIcons.category),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text(
                    "Select Category",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                  value:
                      servicesController.services.any(
                        (s) => s.name == controller.selectedService,
                      )
                      ? controller.selectedService
                      : null,
                  dropdownColor: Colors.white,
                  iconEnabledColor: AppColors.softBlack,
                  items: servicesController.services
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.name,
                          child: Text(
                            e.name,
                            style: const TextStyle(
                              color: AppColors.softBlack,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) controller.setService(val);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ✅ Word count (NO LIMIT)
class _WordCount extends StatelessWidget {
  final TextEditingController controller;
  const _WordCount({required this.controller});

  int _countWords(String s) {
    final t = s.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      // ignore: unnecessary_underscores
      builder: (_, v, __) {
        final words = _countWords(v.text);
        return Text(
          "$words words",
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        );
      },
    );
  }
}
