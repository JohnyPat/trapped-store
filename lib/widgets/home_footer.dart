import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'brand_logo.dart';
import 'responsive.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({
    super.key,
    required this.onShop,
    required this.onOrders,
    required this.onWishlist,
    required this.onSizeGuide,
  });

  final VoidCallback onShop;
  final VoidCallback onOrders;
  final VoidCallback onWishlist;
  final VoidCallback onSizeGuide;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      padding: EdgeInsets.symmetric(
        vertical: Breakpoints.isMobile(context) ? 34 : 48,
      ),
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Breakpoints.isMobile(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandLogo(fontSize: 22),
                  const SizedBox(height: 12),
                  Text(
                    'WEAR YOUR CONVICTION.',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.faint,
                      fontSize: 8,
                      letterSpacing: 2.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _FooterLinks(
                    onShop: onShop,
                    onOrders: onOrders,
                    onWishlist: onWishlist,
                    onSizeGuide: onSizeGuide,
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandLogo(fontSize: 26),
                        const SizedBox(height: 14),
                        Text(
                          'WEAR YOUR CONVICTION.',
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.faint,
                            fontSize: 8,
                            letterSpacing: 2.8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Independent streetwear made for the set-apart.\nEvery piece is a statement.',
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: AppColors.faint,
                            fontSize: 10,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _FooterLinks(
                      onShop: onShop,
                      onOrders: onOrders,
                      onWishlist: onWishlist,
                      onSizeGuide: onSizeGuide,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CUSTOMER CARE',
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.paper,
                            fontSize: 8,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FooterLine(text: 'ORDERS@WEARETRAPPED.COM'),
                        _FooterLine(text: 'MON–FRI · 9AM–6PM PHT'),
                        _FooterLine(text: 'SHIPPING NATIONWIDE'),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            Divider(color: AppColors.paper.withValues(alpha: .18), height: 1),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '© ${DateTime.now().year} [TRAPPED] STUDIO',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.faint,
                      fontSize: 7,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  'MANILA, PHILIPPINES',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.faint,
                    fontSize: 7,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({
    required this.onShop,
    required this.onOrders,
    required this.onWishlist,
    required this.onSizeGuide,
  });

  final VoidCallback onShop;
  final VoidCallback onOrders;
  final VoidCallback onWishlist;
  final VoidCallback onSizeGuide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPLORE',
          style: AppTextStyles.micro.copyWith(
            color: AppColors.paper,
            fontSize: 8,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        _FooterAction(label: 'SHOP ALL', onTap: onShop),
        _FooterAction(label: 'WISHLIST', onTap: onWishlist),
        _FooterAction(label: 'TRACK ORDERS', onTap: onOrders),
        _FooterAction(label: 'SIZE GUIDE', onTap: onSizeGuide),
      ],
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label,
          style: AppTextStyles.micro.copyWith(
            color: AppColors.faint,
            fontSize: 7.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _FooterLine extends StatelessWidget {
  const _FooterLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: AppTextStyles.micro.copyWith(
          color: AppColors.faint,
          fontSize: 7.5,
          letterSpacing: 1,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
