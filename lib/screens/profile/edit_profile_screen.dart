import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_snack.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/responsive.dart';
import '../../widgets/trapped_button.dart';
import '../../widgets/trapped_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _barangay = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  final _postalCode = TextEditingController();
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    _name.text = profile?.fullName ?? '';
    _phone.text = profile?.phone ?? '';
    _address.text = profile?.address ?? '';
    _barangay.text = profile?.barangay ?? '';
    _city.text = profile?.city ?? '';
    _province.text = profile?.province ?? '';
    _postalCode.text = profile?.postalCode ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _barangay.dispose();
    _city.dispose();
    _province.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      barangay: _barangay.text.trim(),
      city: _city.text.trim(),
      province: _province.text.trim(),
      postalCode: _postalCode.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      AppSnack.success(context, 'Profile updated.');
      Navigator.of(context).pop();
    } else {
      AppSnack.error(context, auth.error ?? 'The profile could not be updated.');
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 34,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.lineDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'PROFILE PICTURE',
                style: AppTextStyles.micro.copyWith(
                  fontSize: 8,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              _SourceTile(
                icon: Icons.photo_camera_outlined,
                label: 'Take a photo',
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );
      if (file == null || !mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.updateProfilePicture(file);
      if (!mounted) return;
      if (success) {
        AppSnack.success(context, 'Profile picture updated.');
      } else {
        AppSnack.error(
          context,
          auth.error ?? 'The profile picture could not be uploaded.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.toString());
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final name = profile?.displayName ?? auth.displayName;
    final image = profile?.profileImage ?? '';

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          BrandHeader(
            onLeading: () => Navigator.of(context).pop(),
            leadingIcon: Icons.arrow_back,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ContentFrame(
                maxWidth: 640,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'EDIT PROFILE',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep your delivery details current for a faster checkout.',
                        style: AppTextStyles.bodyMuted.copyWith(
                          fontSize: 10.5,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.lineDark,
                                  width: 1.2,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: image.startsWith('http')
                                  ? Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _Initials(name: name),
                                    )
                                  : _Initials(name: name),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -2,
                              child: Material(
                                color: AppColors.ink,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _uploading ? null : _pickPhoto,
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child: _uploading
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.4,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.paper,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: AppColors.paper,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'TAP TO CHANGE PHOTO',
                          style: AppTextStyles.micro.copyWith(
                            fontSize: 6.8,
                            letterSpacing: 1.4,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      TrappedTextField(
                        label: 'Full name',
                        controller: _name,
                        hint: 'Your name',
                        textInputAction: TextInputAction.next,
                        validator: Validators.fullName,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'Email',
                        initialValue: profile?.email.isNotEmpty == true
                            ? profile!.email
                            : (auth.email ?? ''),
                        hint: 'you@example.com',
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'Phone',
                        controller: _phone,
                        hint: '+63 9XX XXX XXXX',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: Validators.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'Street address',
                        controller: _address,
                        hint: 'House number, street, subdivision',
                        textInputAction: TextInputAction.next,
                        validator: Validators.address,
                        autofillHints: const [
                          AutofillHints.streetAddressLine1,
                        ],
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'Barangay (optional)',
                        controller: _barangay,
                        hint: 'Barangay',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TrappedTextField(
                              label: 'City',
                              controller: _city,
                              hint: 'City',
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  Validators.required(value, field: 'City'),
                              autofillHints: const [AutofillHints.addressCity],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TrappedTextField(
                              label: 'Province',
                              controller: _province,
                              hint: 'Province',
                              textInputAction: TextInputAction.next,
                              validator: (value) => Validators.required(
                                value,
                                field: 'Province',
                              ),
                              autofillHints: const [
                                AutofillHints.addressState,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TrappedTextField(
                        label: 'Postal code',
                        controller: _postalCode,
                        hint: '1000',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: Validators.postalCode,
                        autofillHints: const [AutofillHints.postalCode],
                      ),
                      const SizedBox(height: 26),
                      TrappedButton(
                        label: 'SAVE CHANGES',
                        onPressed: _saving ? null : _save,
                        loading: _saving,
                        height: 48,
                      ),
                      const SizedBox(height: 10),
                      TrappedButton(
                        label: 'CANCEL',
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        variant: TrappedButtonVariant.outline,
                        height: 46,
                      ),
                      const SizedBox(height: 42),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Formatters.initials(name),
        style: AppTextStyles.displaySmall.copyWith(fontSize: 30),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.micro.copyWith(
                  fontSize: 8,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 13,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
