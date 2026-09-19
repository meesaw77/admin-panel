import 'package:admin/screens/management/password_field.dart';
import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/controllers/management/management_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/theme/colors.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/services/api_service.dart';
import 'package:admin/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:admin/utils/snack_bar_utils.dart';
import '../../utils/bulk_delete.dart';
import '../../utils/confirmed_delete.dart';
import 'package:admin/controllers/teams/team_controller.dart';
import '../../widgets/action_button.dart';
import '../../widgets/icon_button.dart';
import 'package:admin/widgets/custom_horizontal_scrollbar.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminManagementView();
  }
}

class AdminManagementView extends StatefulWidget {
  const AdminManagementView({super.key});

  @override
  State<AdminManagementView> createState() => _AdminManagementViewState();
}

class _AdminManagementViewState extends State<AdminManagementView> {
  @override
  Widget build(BuildContext context) {
    return const UserManagementTab();
  }
}

// --- User Management Tab ---
class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  late ManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ManagementController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.fetchUsers(); // ✅ Crucial: Refreshes list after login
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
    return Consumer<ManagementController>(
      builder: (context, controller, child) {
        // Access team members here for use in sub-methods
        final teamController = context.watch<TeamController>();
        final teamMembers = teamController.teamMembers;

        return Column(
          children: [
            // Fixed Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "User Management",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.softBlack,
                      fontFamily: "Libre",
                    ),
                  ),
                  Row(
                    children: [
                      if (controller.selectedUserIds.isNotEmpty) ...[
                        _buildBulkDeleteButton(context, controller),
                        const SizedBox(width: 16),
                      ],
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.setAddingUser(!controller.isAddingUser);
                          if (controller.isAddingUser) _scrollToTop();
                        },
                        icon: SvgPicture.asset(
                          controller.isAddingUser
                              ? AppIcons.cross
                              : AppIcons.plus,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(
                          controller.isAddingUser
                              ? "Close Form"
                              : "Create User",
                        ),
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
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchUsers(),
                color: AppColors.primaryRed,
                child: Scrollbar(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (controller.isAddingUser) ...[
                        _buildUserForm(context, controller, teamMembers),
                        const SizedBox(height: 48),
                        Divider(
                          height: 1,
                          thickness: 1.0,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Existing Users",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.softBlack,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildUserList(context, controller),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserForm(
    BuildContext context,
    ManagementController controller,
    List<dynamic> teamMembers,
  ) {
    bool isMobile = Responsive.isMobile(context);
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
          Text(
            controller.editingUser == null
                ? "Create New User"
                : "Edit User Account",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Main Form Row (Stacks on Mobile)
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _buildUserImagePicker(controller),
              SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 24 : 0),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  children: [
                    // Row 1: Role, Name, Email
                    Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isMobile ? 0 : 1,
                          child: _buildRoleSelector(controller),
                        ),
                        SizedBox(
                          width: isMobile ? 0 : 16,
                          height: isMobile ? 16 : 0,
                        ),
                        Expanded(
                          flex: isMobile ? 0 : 1,
                          child: _buildNameInput(
                            context,
                            controller,
                            teamMembers,
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 0 : 16,
                          height: isMobile ? 16 : 0,
                        ),
                        Expanded(
                          flex: isMobile ? 0 : 1,
                          child: _buildField(
                            "Email Address",
                            controller.userEmailController,
                            "e.g. john@example.com",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Row 2: Password, Phone, Status
                    Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isMobile ? 0 : 1,
                          child: PasswordField(
                            label: "Password",
                            controller: controller.userPasswordController,
                            hint: controller.editingUser != null
                                ? "Leave blank to keep current"
                                : "Enter secret password",
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 0 : 16,
                          height: isMobile ? 16 : 0,
                        ),
                        Expanded(
                          flex: isMobile ? 0 : 1,
                          child: _buildField(
                            "Phone Number",
                            controller.userPhoneController,
                            "e.g. +123456789",
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 0 : 16,
                          height: isMobile ? 16 : 0,
                        ),
                        if (!controller.isEditingAdmin)
                          Expanded(
                            flex: isMobile ? 0 : 1,
                            child: _buildStatusToggle(controller),
                          )
                        else if (!isMobile)
                          const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!controller.isEditingAdmin) ...[
            const SizedBox(height: 24),
            Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: isMobile
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: _buildWorkCategorySelector(controller),
                ),
                SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 24 : 0),
                buildFormActionButtons(
                  onDiscard: () => controller.setAddingUser(false),
                  onSave: () async {
                    final auth = Provider.of<AuthController>(
                      context,
                      listen: false,
                    );
                    // ✅ password validation
                    if (controller.userPasswordController.text.isNotEmpty &&
                        controller.userPasswordController.text.length < 8) {
                      SnackBarUtils.showSnackBar(
                        context,
                        "Password must be at least 8 characters long.",
                        backgroundColor: AppColors.primaryRed,
                      );
                      return;
                    }

                    final error = await controller.saveUser(auth: auth);
                    final success = error == null;

                    if (context.mounted) {
                      SnackBarUtils.showSnackBar(
                        context,
                        success ? "User saved!" : error,
                        isError: !success,
                        backgroundColor: success
                            ? AppColors.primaryRed.withValues(alpha: 0.3)
                            : AppColors.softBlack,
                      );
                    }
                  },
                  isLoading: controller.isSaving,
                  saveText: controller.editingUser == null
                      ? "CREATE USER"
                      : "UPDATE USER",
                  buttonRadius: 6,
                  savePadding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  loaderColor: AppColors.white,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                buildFormActionButtons(
                  onDiscard: () => controller.setAddingUser(false),
                  onSave: () async {
                    final auth = Provider.of<AuthController>(
                      context,
                      listen: false,
                    );
                    // ✅ password validation
                    if (controller.userPasswordController.text.isNotEmpty &&
                        controller.userPasswordController.text.length < 8) {
                      SnackBarUtils.showSnackBar(
                        context,
                        "Password must be at least 8 characters long.",
                        backgroundColor: AppColors.primaryRed,
                      );
                      return;
                    }

                    final error = await controller.saveUser(auth: auth);
                    final success = error == null;

                    if (context.mounted) {
                      SnackBarUtils.showSnackBar(
                        context,
                        success ? "User saved!" : error,
                        isError: !success,
                        backgroundColor: success
                            ? AppColors.primaryRed.withValues(alpha: 0.3)
                            : AppColors.softBlack,
                      );
                    }
                  },
                  isLoading: controller.isSaving,
                  saveText: controller.editingUser == null
                      ? "CREATE USER"
                      : "UPDATE USER",
                  buttonRadius: 6,
                  savePadding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  loaderColor: AppColors.white,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserImagePicker(ManagementController controller) {
    bool hasImage =
        controller.webImage != null ||
        (controller.editingUser?.image != null &&
            controller.editingUser!.image!.isNotEmpty);

    return Stack(
      children: [
        GestureDetector(
          onTap: controller.pickUserImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: controller.webImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      controller.webImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : controller.editingUser?.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AppNetworkImage(
                      imageUrl: ApiService.getImageUrl(
                        controller.editingUser!.image,
                      ),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: SvgPicture.asset(
                          AppIcons.upload,
                          width: 40,
                          height: 40,
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppIcons.upload,
                        width: 32,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Add Image",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasImage)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: controller.clearUserImage,
              child: SvgPicture.asset(
                AppIcons.trash,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameInput(
    BuildContext context,
    ManagementController controller,
    List<dynamic> members,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Full Name",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.softBlack,
              ),
            ),
            if (members.isNotEmpty)
              const Text(
                "(Select to Pre-fill)",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: controller.selectedTeamMemberId,
            hint: const Text(
              "Select Team Member",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.softBlack),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            dropdownColor: Colors.grey[50],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: members.map((member) {
              return DropdownMenuItem<int>(
                value: member.id,
                child: Text(member.name),
              );
            }).toList(),
            onChanged: (val) {
              controller.selectTeamMember(val, members);
            },
            validator: (val) => val == null ? "Required" : null,
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
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
          obscureText: isPassword,
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

  Widget _buildRoleSelector(ManagementController controller) {
    final bool isAdminEditing =
        (controller.editingUser?.role ?? "").toLowerCase() == "admin";

    final String roleValue =
        (controller.selectedRole == "manager" ||
            controller.selectedRole == "staff")
        ? controller.selectedRole
        : "staff";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "User Role",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.softBlack,
          ),
        ),
        const SizedBox(height: 8),

        if (isAdminEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              "Admin (Locked)",
              style: TextStyle(fontSize: 14, color: AppColors.softBlack),
            ),
          )
        else
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
                value: roleValue, // ✅ safe
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.softBlack,
                ),
                dropdownColor: Colors.grey[50],
                items: const [
                  DropdownMenuItem(value: "manager", child: Text("Manager")),
                  DropdownMenuItem(value: "staff", child: Text("Staff")),
                ],
                onChanged: (val) {
                  if (val != null) controller.setUserRole(val);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusToggle(ManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Status",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Published Button
            InkWell(
              onTap: () => controller.setUserBanned(false),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 85,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !controller.isUserBanned
                      ? AppColors.primaryRed
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: !controller.isUserBanned
                        ? AppColors.primaryRed
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  "Published",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !controller.isUserBanned
                        ? Colors.white
                        : AppColors.softBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Draft Button
            InkWell(
              onTap: () => controller.setUserBanned(true),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 85,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.isUserBanned
                      ? AppColors.grey.withValues(alpha: 0.3)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: controller.isUserBanned
                        ? AppColors.grey
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  "Draft",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.softBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkCategorySelector(ManagementController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ManagementController.availableWorkCategories.map((
              category,
            ) {
              final isSelected = controller.selectedWorkCategories.contains(
                category,
              );
              return FilterChip(
                label: Text(controller.getCategoryDisplayName(category)),
                selected: isSelected,
                onSelected: (selected) {
                  controller.toggleWorkCategory(category);
                },
                selectedColor: AppColors.primaryRed,
                checkmarkColor: AppColors.white,
                backgroundColor: AppColors.white,
                side: BorderSide(
                  color: isSelected ? AppColors.white : AppColors.grey,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(BuildContext context, ManagementController controller) {
    if (controller.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }

    if (controller.users.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.softBlack.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                "No users found. Create your first one!",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Helper method to parse assigned work from JSON array format
    List<String> parseAssignedWork(String assignedWork) {
      try {
        String cleaned = assignedWork
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .replaceAll("'", '');

        return cleaned
            .split(',')
            .map((work) => work.trim())
            .where((work) => work.isNotEmpty)
            .toList();
      } catch (e) {
        return assignedWork
            .split(',')
            .map((work) => work.trim())
            .where((work) => work.isNotEmpty)
            .toList();
      }
    }

    // ✅ SORT USERS (Admin → Manager → Staff)
    final List usersSorted = List.from(controller.users);

    int rolePriority(String role) {
      switch (role.toLowerCase()) {
        case 'admin':
          return 0;
        case 'manager':
          return 1;
        case 'staff':
          return 2;
        default:
          return 3;
      }
    }

    usersSorted.sort((a, b) {
      final pa = rolePriority(a.role);
      final pb = rolePriority(b.role);

      if (pa != pb) return pa.compareTo(pb);

      // Same role -> sort by name (optional)
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth = constraints.maxWidth > 800
            ? constraints.maxWidth
            : 800;
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
                    border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: () {
                    final nonAdmins = usersSorted.where(
                      (u) => u.role.toLowerCase() != "admin",
                    );
                    return nonAdmins.isNotEmpty &&
                        controller.selectedUserIds.length == nonAdmins.length;
                  }(),
                  onChanged: (val) => controller.selectAllUsers(val ?? false),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  flex: 2,
                  child: Text(
                    "USER",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    "ROLE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    "ACCESS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    "STATUS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    "ACTIONS",
                    textAlign: TextAlign.end,
                    style: TextStyle(
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
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),

          // List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: usersSorted.length,
            separatorBuilder: (context, index) =>
                Divider(height: 0.5, thickness: 0.3, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final user = usersSorted[index];
              final isAdmin = user.role.toLowerCase() == "admin";

              return InkWell(
                onTap: () {},
                hoverColor: AppColors.primaryRed.withValues(alpha: 0.05),
                splashColor: AppColors.primaryRed.withValues(alpha: 0.1),
                highlightColor: AppColors.primaryRed.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      if (isAdmin)
                        const SizedBox(width: 48) // Maintain spacing
                      else
                        Checkbox(
                          value: controller.selectedUserIds.contains(user.id),
                          onChanged: (val) =>
                              controller.toggleUserSelection(user.id),
                        ),
                      const SizedBox(width: 8),

                      // Name with Avatar and email
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.grey.withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child:
                                  user.image != null && user.image!.isNotEmpty
                                  ? AppNetworkImage(
                                      imageUrl: ApiService.getImageUrl(
                                        user.image,
                                      ),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child:
                                            LoadingAnimationWidget.staggeredDotsWave(
                                              color: AppColors.primaryRed,
                                              size: 20,
                                            ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.softBlack,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Role
                      Expanded(
                        flex: 1,
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: user.role.toLowerCase() == 'admin'
                                ? AppColors.grey
                                : AppColors.softBlack.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      // Access
                      Expanded(
                        flex: 1,
                        child:
                            user.assignedWork != null &&
                                user.assignedWork!.isNotEmpty
                            ? () {
                                final assigned = parseAssignedWork(
                                  user.assignedWork!,
                                );
                                final isFull =
                                    isAdmin ||
                                    assigned.length ==
                                        ManagementController
                                            .availableWorkCategories
                                            .length;

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isFull ? "Full Access" : "Limited Access",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isFull
                                            ? AppColors.primaryRed
                                            : AppColors.softBlack,
                                      ),
                                    ),
                                  ],
                                );
                              }()
                            : const Text(
                                "No Access",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.grey,
                                ),
                              ),
                      ),

                      // Status
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 85,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: !user.isBanned
                                  ? AppColors.primaryRed
                                  : AppColors.grey,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: !user.isBanned
                                    ? AppColors.primaryRed.withValues(
                                        alpha: 0.2,
                                      )
                                    : AppColors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              !user.isBanned ? "Active" : "Banned",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: !user.isBanned
                                    ? AppColors.white
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Actions
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            buildActionIcon(
                              svgPath: AppIcons.edit,
                              color: AppColors.primaryRed,
                              onTap: () {
                                _defer(() {
                                  controller.editUser(user);
                                  _scrollToTop();
                                });
                              },
                            ),
                            if (!isAdmin) ...[
                              const SizedBox(width: 16),
                              buildActionIcon(
                                svgPath: AppIcons.trash,
                                color: AppColors.primaryRed,
                                onTap: () => showDeleteConfirm(
                                  context: context,
                                  message:
                                      "Are you sure you want to delete this user ?",
                                  onDelete: () =>
                                      controller.deleteUser(user.id),
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildBulkDeleteButton(
    BuildContext context,
    ManagementController controller,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        showBulkDeleteDialog(
          context: context,
          count: controller.selectedUserIds.length,
          itemNamePlural: "Users",
          onConfirm: controller.deleteSelectedUsers,
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
      label: Text("Delete (${controller.selectedUserIds.length})"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
