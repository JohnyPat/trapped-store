import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/site_content.dart';
import '../../services/site_content_service.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/responsive.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SiteContent>(
      stream: SiteContentService().watchSite(),
      initialData: SiteContent.defaults,
      builder: (context, snapshot) {
        final site = snapshot.data ?? SiteContent.defaults;
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
                    maxWidth: 900,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        _HeroImage(),
                        const SizedBox(height: 38),
                        const Text(
                          'ABOUT US',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 5,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          site.aboutHeadline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 34,
                            height: 1.18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.lineDark, height: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                '[trapped]',
                                style: const TextStyle(
                                  fontFamily: 'SpaceMono',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.lineDark, height: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ...site.aboutBody.split('\n\n').map(
                              (paragraph) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                child: Text(
                                  paragraph.trim(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'SpaceMono',
                                    fontSize: 13,
                                    height: 1.75,
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 10),
                        Text(
                          site.signoffLine1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          site.signoffLine2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          site.closing,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 12,
                            letterSpacing: 0.6,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          site.footer,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SpaceMono',
                            fontSize: 14,
                            letterSpacing: 3,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 46),
                        // Contact rows (screenshot 1)
                        _ContactRow(
                          icon: Icons.phone,
                          label: 'PHONE',
                          value: site.phoneDisplay,
                          actionLabel: 'Call Now',
                          onTap: () => _launch('tel:${site.phoneNumber}'),
                        ),
                        const SizedBox(height: 14),
                        _ContactRow(
                          icon: Icons.mail,
                          label: 'EMAIL',
                          value: site.email,
                          actionLabel: 'Send Email',
                          onTap: () => _launch(
                            'mailto:${site.email}?subject=Hello%20from%20the%20site',
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FollowRow(site: site),
                        const SizedBox(height: 14),
                        _QuoteBlock(site: site),
                        const SizedBox(height: 56),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launch(String uri) async {
    final parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    }
  }
}

/// Full-width hero photo strip with the [trapped] wordmark centred.
class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/editorial/about_us.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.inkSoft),
          ),
          const Center(child: BrandLogo(fontSize: 54, color: AppColors.paper)),
        ],
      ),
    );
  }
}

/// Reusable PHONE / EMAIL row with a trailing action pill.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineDark),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.canvas,
            child: Icon(icon, color: AppColors.ink, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.ink,
                    fontSize: 10,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.paper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

/// FOLLOW US row with Facebook / Instagram launch links.
class _FollowRow extends StatelessWidget {
  const _FollowRow({required this.site});

  final SiteContent site;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineDark),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.ink,
            child: Icon(Icons.public, color: AppColors.paper, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOLLOW US',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.ink,
                    fontSize: 10,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  site.followText,
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Facebook',
            onPressed: () => _launch(site.facebookUrl),
            icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
          ),
          IconButton(
            tooltip: 'Instagram',
            onPressed: () => _launch(site.instagramUrl),
            icon: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFFE1306C)),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    }
  }
}

/// The bordered quote block with the trapped wordmark.
class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.site});

  final SiteContent site;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineDark),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _quoteLine(site.quoteLine1),
                  _quoteLine(site.quoteLine2),
                  _quoteLine(site.quoteLine3),
                  const SizedBox(height: 6),
                  Text(
                    site.quoteHighlight,
                    style: const TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Trapped logo box
          Container(
            width: 84,
            height: 96,
            color: AppColors.ink,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'TM',
                    style: TextStyle(
                      color: AppColors.paper,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                BrandLogo(fontSize: 15, color: AppColors.paper),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quoteLine(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12.5,
            height: 1.6,
            color: AppColors.muted,
          ),
        ),
      );
}