import 'package:admin/controllers/teams/team_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../utils/bulk_delete.dart';
import '../../utils/confirmed_delete.dart';
import '../../widgets/action_button.dart';
import '../../widgets/icon_button.dart';
import '../../widgets/visibility.dart';
import '../../widgets/specialization_dropdown.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late TeamController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<TeamController>();
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
      body: Consumer<TeamController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Responsive(
                  mobile: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Team Management",
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
                        "Team Management",
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

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchTeamMembers(),
                    color: AppColors.primaryRed,
                    child: Scrollbar(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (controller.isAdding) ...[
                            _buildTeamForm(context, controller),
                            const SizedBox(height: 48),
                            Divider(
                              height: 1,
                              thickness: 1.0,
                              color: Colors.grey[200],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Existing Team Members",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.softBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildTeamList(context, controller),
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

  Widget _buildHeaderButton(TeamController controller) {
    return ElevatedButton.icon(
      onPressed: () {
        controller.setAdding(!controller.isAdding);
        if (controller.isAdding) _scrollToTop();
      },
      icon: SvgPicture.asset(
        controller.isAdding ? AppIcons.cross : AppIcons.plus,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: Text(controller.isAdding ? "Close Form" : "Create Team Member"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _buildTeamList(BuildContext context, TeamController controller) {
    if (controller.isLoading && controller.teamMembers.isEmpty) {
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

    if (controller.teamMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
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
                "No team members found. Add your first one!",
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
                          color: AppColors.grey.withValues(alpha: 0.1),
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
                                          controller.filteredMembers.length &&
                                  controller.filteredMembers.isNotEmpty,
                                  onChanged: (val) =>
                                      controller.selectAll(val ?? false),
                                ),
                                const SizedBox(width: 8),
                                _buildTableHeaderCell("Name", 4),
                                _buildTableHeaderCell("Role", 2),
                                _buildTableHeaderCell("Experience", 2),
                                _buildTableHeaderCell("Services", 2),
                                _buildTableHeaderCell("Socials", 2),
                                _buildTableHeaderCell("Status", 2),
                                _buildTableHeaderCell("Actions", 1, alignEnd: true),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.white),
                          // Table Content
                          Column(
                            children: List.generate(
                              controller.filteredMembers.length,
                              (index) {
                                final member = controller.filteredMembers[index];
                                final isSelected = controller.selectedIds.contains(
                                  member.id,
                                );
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          controller.toggleSelection(member.id),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (val) => controller
                                                  .toggleSelection(member.id),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 4,
                                              child: Row(
                                                children: [
                                                  _buildAvatar(
                                                    imageUrl: member.image,
                                                    size: 60,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          member.name,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                AppColors.softBlack,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                member.role,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.softBlack,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "${member.experience} Years",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.softBlack,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                member.specializations
                                                    .split(',')
                                                    .where(
                                                      (s) => s.trim().isNotEmpty,
                                                    )
                                                    .length
                                                    .toString(),
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
                                                  if (member.socialLinks
                                                      .containsKey('Facebook'))
                                                    SvgPicture.asset(
                                                      AppIcons.facebook,
                                                      width: 14,
                                                      height: 14,
                                                    ),
                                                  if (member.socialLinks
                                                          .containsKey(
                                                            'Facebook',
                                                          ) &&
                                                      member.socialLinks
                                                          .containsKey('Instagram'))
                                                    const SizedBox(width: 8),
                                                  if (member.socialLinks
                                                      .containsKey('Instagram'))
                                                    SvgPicture.asset(
                                                      AppIcons.instagram,
                                                      width: 14,
                                                      height: 14,
                                                    ),
                                                  if (member.socialLinks.isEmpty)
                                                    const Text(
                                                      "-",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: AppColors.grey,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: _buildStatusChip(
                                                  member.status,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  buildActionIcon(
                                                    svgPath: AppIcons.edit,
                                                    color: AppColors.primaryRed,
                                                    onTap: () {
                                                      _defer(() {
                                                        controller.editMember(
                                                          member,
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
                                                          "Are you sure you want to delete this User ?",
                                                      onDelete: () => controller
                                                          .deleteMember(member.id),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (index <
                                        controller.filteredMembers.length - 1)
                                      const Divider(
                                        height: 1,
                                        color: AppColors.white,
                                        thickness: 0.5,
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

  Widget _buildTableHeaderCell(String text, int flex, {bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, TeamController controller) {
    bool isMobile = Responsive.isMobile(context);
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${controller.filteredMembers.length} Total Members",
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              if (controller.selectedIds.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildBulkDeleteButton(context, controller),
              ],
              const SizedBox(height: 16),
              _buildSearchField(context, controller),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "${controller.filteredMembers.length} Total Members",
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                  if (controller.selectedIds.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    _buildBulkDeleteButton(context, controller),
                  ],
                ],
              ),
              _buildSearchField(context, controller),
            ],
          );
  }

  Widget _buildBulkDeleteButton(
    BuildContext context,
    TeamController controller,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        showBulkDeleteDialog(
          context: context,
          count: controller.selectedIds.length,
          itemNamePlural: "team members",
          onConfirm: controller.deleteSelectedMembers,
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
        height: 18,
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
      ),
      label: Text("Delete (${controller.selectedIds.length})"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, TeamController controller) {
    bool isMobile = Responsive.isMobile(context);
    return SizedBox(
      width: isMobile ? double.infinity : 300,
      height: 40,
      child: TextField(
        style: const TextStyle(color: AppColors.softBlack, fontSize: 13),
        onChanged: (value) => controller.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: "Search Team Members...",
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.grey.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
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
            : AppColors.grey.withValues(alpha: 0.25),
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

  Widget _buildTeamForm(BuildContext context, TeamController controller) {
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
              SvgPicture.asset(
                AppIcons.team,
                width: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.grey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                controller.editingMember == null
                    ? "New Team Member"
                    : "Edit Team Member",
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
                onStatusChanged: controller.setStatus,
                iconPath: AppIcons.visible,
                horizontalPadding: 6,
                borderRadius: 6,
              ),
              buildFormActionButtons(
                onDiscard: () => controller.setAdding(false),
                onSave: () => controller.saveMember(context),
                // change save method if needed
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

  Widget _buildImagePicker(TeamController controller) {
    bool hasImage =
        controller.webImage != null ||
        controller.pickedImage != null ||
        (controller.editingMember?.image != null &&
            controller.editingMember!.image!.isNotEmpty);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => controller.pickImage(),
          child: Container(
            width: 150,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
            ),
            child: _buildImageContent(controller),
          ),
        ),
        if (hasImage)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => controller.clearImage(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppIcons.trash,
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryRed,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent(TeamController controller) {
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

    if (controller.editingMember?.image != null &&
        controller.editingMember!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ApiService.getImageUrl(controller.editingMember!.image),
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

  Widget _buildFormFields(BuildContext context, TeamController controller) {
    return Column(
      children: [
        _buildResponsiveRow(
          context: context,
          children: [
            _buildField("Full Name", controller.nameController, "Enter name"),
            _buildField(
              "Role",
              controller.roleController,
              "e.g. Senior Stylist",
            ),
            _buildField(
              "Experience",
              controller.experienceController,
              "e.g. 5 Years",
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildResponsiveRow(
          context: context,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Specializations",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softBlack,
                  ),
                ),
                const SizedBox(height: 8),
                SpecializationDropdown(
                  controller: controller.specializationsController,
                  hint: "Select Specializations",
                ),
              ],
            ),
            _buildSocialLinkInput(controller),
            _buildSocialLinkChips(controller),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField(TeamController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.softBlack,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.descriptionController,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          onChanged: (val) => controller.updateWordCount(val),
          decoration: InputDecoration(
            hintText: "Enter member bio/description...",
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
            contentPadding: const EdgeInsets.all(
              12,
            ), // expanded for better breathing room
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.softBlack,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(padding: const EdgeInsets.all(12), child: prefixIcon)
                : null,
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

  Widget _buildSocialLinkInput(TeamController controller) {
    bool isNone = controller.selectedSocialPlatform == 'None';

    final availablePlatforms = [
      'Facebook',
      'Instagram',
    ].where((p) => controller.socialControllers[p]!.text.isEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Social Link",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.softBlack,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.socialLinkInputController,
          readOnly: isNone,
          onSubmitted: (_) => controller.addSocialLink(),
          style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
          decoration: InputDecoration(
            prefixIcon: Container(
              width: 50,
              alignment: Alignment.center,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedSocialPlatform,
                  icon: const SizedBox.shrink(),
                  dropdownColor: AppColors.white,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'None',
                      child: Icon(
                        Icons.link_off,
                        size: 18,
                        color: AppColors.grey,
                      ),
                    ),
                    // Ensure the current selection is always in the items list to prevent crash
                    if (controller.selectedSocialPlatform != 'None' &&
                        !availablePlatforms.contains(
                          controller.selectedSocialPlatform,
                        ))
                      DropdownMenuItem<String>(
                        value: controller.selectedSocialPlatform,
                        child: SvgPicture.asset(
                          controller.selectedSocialPlatform == 'Facebook'
                              ? AppIcons.facebook
                              : AppIcons.instagram,
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ...availablePlatforms.map((String p) {
                      return DropdownMenuItem<String>(
                        value: p,
                        child: SvgPicture.asset(
                          p == 'Facebook'
                              ? AppIcons.facebook
                              : AppIcons.instagram,
                          width: 18,
                          height: 18,
                        ),
                      );
                    }),
                  ],
                  onChanged: (String? val) {
                    if (val != null) {
                      controller.setSelectedSocialPlatform(val);
                    }
                  },
                ),
              ),
            ),
            hintText: isNone
                ? "Select platform to add link"
                : "Enter ${controller.selectedSocialPlatform} link & press Enter",
            hintStyle: TextStyle(
              color: AppColors.grey.withValues(alpha: 0.5),
              fontSize: 13,
            ),
            filled: true,
            fillColor: isNone ? Colors.grey[100] : Colors.grey[50],
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
                color: controller.selectedSocialPlatform != 'None'
                    ? AppColors.grey
                    : AppColors.grey.withValues(alpha: 0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinkChips(TeamController controller) {
    if (controller.socialControllers.values.every((c) => c.text.isEmpty)) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: controller.socialControllers.entries
              .where((e) => e.value.text.isNotEmpty)
              .map((e) {
                final platform = e.key;
                final link = e.value.text;
                return Chip(
                  avatar: SvgPicture.asset(
                    platform == 'Facebook'
                        ? AppIcons.facebook
                        : AppIcons.instagram,
                    width: 16,
                    height: 16,
                  ),
                  label: Text(
                    link,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.softBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  onDeleted: () => controller.removeSocialLink(platform),
                );
              })
              .toList(),
        ),
      ],
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
              imageUrl: ApiService.getImageUrl(imageUrl),
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.person, size: 20, color: Colors.grey),
            )
          : const Icon(Icons.person, size: 20, color: Colors.grey),
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
