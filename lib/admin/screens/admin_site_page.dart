import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';
import 'package:trapped_store/utils/app_snack.dart';

import '../../models/site_content.dart';
import '../../services/site_content_service.dart';
import '../widgets/admin_breakpoints.dart';
import '../widgets/admin_page_container.dart';
import '../widgets/admin_section_card.dart';

/// Admin editor for the public About page (and its contact band).
/// Everything editable here is stored at `settings/site` in Firebase.
class AdminSitePage extends StatefulWidget {
  const AdminSitePage({super.key});

  @override
  State<AdminSitePage> createState() => _AdminSitePageState();
}

class _AdminSitePageState extends State<AdminSitePage> {
  final _service = SiteContentService();

  final _headline = TextEditingController();
  final _body = TextEditingController();
  final _closing = TextEditingController();
  final _signoff1 = TextEditingController();
  final _signoff2 = TextEditingController();
  final _footer = TextEditingController();
  final _phoneDisplay = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _email = TextEditingController();
  final _fbUrl = TextEditingController();
  final _igUrl = TextEditingController();
  final _followText = TextEditingController();
  final _quote1 = TextEditingController();
  final _quote2 = TextEditingController();
  final _quote3 = TextEditingController();
  final _quoteHighlight = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final site = await _service.fetchOnce();
      _headline.text = site.aboutHeadline;
      _body.text = site.aboutBody;
      _closing.text = site.closing;
      _signoff1.text = site.signoffLine1;
      _signoff2.text = site.signoffLine2;
      _footer.text = site.footer;
      _phoneDisplay.text = site.phoneDisplay;
      _phoneNumber.text = site.phoneNumber;
      _email.text = site.email;
      _fbUrl.text = site.facebookUrl;
      _igUrl.text = site.instagramUrl;
      _followText.text = site.followText;
      _quote1.text = site.quoteLine1;
      _quote2.text = site.quoteLine2;
      _quote3.text = site.quoteLine3;
      _quoteHighlight.text = site.quoteHighlight;
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '$e';
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _headline,
      _body,
      _closing,
      _signoff1,
      _signoff2,
      _footer,
      _phoneDisplay,
      _phoneNumber,
      _email,
      _fbUrl,
      _igUrl,
      _followText,
      _quote1,
      _quote2,
      _quote3,
      _quoteHighlight,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  SiteContent _currentFromForm() => SiteContent(
    aboutHeadline: _headline.text.trim(),
    aboutBody: _body.text.trim(),
    signoffLine1: _signoff1.text.trim(),
    signoffLine2: _signoff2.text.trim(),
    closing: _closing.text.trim(),
    footer: _footer.text.trim(),
    phoneDisplay: _phoneDisplay.text.trim(),
    phoneNumber: _phoneNumber.text.replaceAll(RegExp(r'\D'), ''),
    email: _email.text.trim(),
    facebookUrl: _fbUrl.text.trim(),
    instagramUrl: _igUrl.text.trim(),
    followText: _followText.text.trim(),
    quoteLine1: _quote1.text.trim(),
    quoteLine2: _quote2.text.trim(),
    quoteLine3: _quote3.text.trim(),
    quoteHighlight: _quoteHighlight.text.trim(),
  );

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.saveSite(_currentFromForm());
      if (!mounted) return;
      AppSnack.success(context, 'About page updated.');
    } catch (e) {
      if (!mounted) return;
      AppSnack.error(context, 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to defaults?'),
        content: const Text(
          'This overwrites your About page with the original built-in copy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AdminColors.danger),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _fillForm(const SiteContent());
    AppSnack.success(context, 'Defaults loaded — press SAVE to publish.');
  }

  void _fillForm(SiteContent site) {
    _headline.text = site.aboutHeadline;
    _body.text = site.aboutBody;
    _closing.text = site.closing;
    _signoff1.text = site.signoffLine1;
    _signoff2.text = site.signoffLine2;
    _footer.text = site.footer;
    _phoneDisplay.text = site.phoneDisplay;
    _phoneNumber.text = site.phoneNumber;
    _email.text = site.email;
    _fbUrl.text = site.facebookUrl;
    _igUrl.text = site.instagramUrl;
    _followText.text = site.followText;
    _quote1.text = site.quoteLine1;
    _quote2.text = site.quoteLine2;
    _quote3.text = site.quoteLine3;
    _quoteHighlight.text = site.quoteHighlight;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final desktop = AdminBreakpoints.isDesktop(context);
    return Scaffold(
      backgroundColor: desktop ? AdminColors.canvas : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load site content:\n$_loadError',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('RETRY')),
                  ],
                ),
              ),
            )
          : desktop
          ? _buildDesktopContent()
          : _buildMobileContent(),
    );
  }

  // ── Mobile (unchanged layout) ───────────────────────────────────────

  Widget _buildMobileContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            const Text(
              'Site Content',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AdminColors.ink,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _resetDefaults,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('RESET'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? 'SAVING…' : 'SAVE'),
              style: FilledButton.styleFrom(
                backgroundColor: AdminColors.ink,
                foregroundColor: AdminColors.paper,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Everything below is public on the About page.',
          style: TextStyle(color: AdminColors.muted),
        ),
        const SizedBox(height: 18),
        _sectionTitle('PREVIEW'),
        const SizedBox(height: 8),
        _previewCard(),
        const SizedBox(height: 20),
        _sectionTitle('ABOUT PAGE'),
        const SizedBox(height: 8),
        _field(_headline, 'Headline'),
        const SizedBox(height: 10),
        _field(_body, 'Body text (blank line = new paragraph)', maxLines: 8),
        const SizedBox(height: 10),
        _field(_signoff1, 'Signoff line 1'),
        const SizedBox(height: 10),
        _field(_signoff2, 'Signoff line 2'),
        const SizedBox(height: 10),
        _field(_closing, 'Closing line'),
        const SizedBox(height: 10),
        _field(_footer, 'Footer tagline'),
        const SizedBox(height: 20),
        _sectionTitle('CONTACT ROWS'),
        const SizedBox(height: 8),
        _field(_phoneDisplay, 'Phone (displayed)'),
        const SizedBox(height: 10),
        _field(
          _phoneNumber,
          'Phone (dialled — digits only)',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _field(_fbUrl, 'Facebook URL'),
        const SizedBox(height: 10),
        _field(_igUrl, 'Instagram URL'),
        const SizedBox(height: 10),
        _field(_followText, 'Follow-us tagline'),
        const SizedBox(height: 20),
        _sectionTitle('QUOTE BLOCK (BOTTOM)'),
        const SizedBox(height: 8),
        _field(_quote1, 'Quote line 1'),
        const SizedBox(height: 10),
        _field(_quote2, 'Quote line 2'),
        const SizedBox(height: 10),
        _field(_quote3, 'Quote line 3'),
        const SizedBox(height: 10),
        _field(_quoteHighlight, 'Highlighted phrase'),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Desktop two-column editor ───────────────────────────────────────

  Widget _buildDesktopContent() {
    return AdminPageContainer(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            title: 'Site content',
            subtitle: 'Everything below is public on the About page.',
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: _resetDefaults,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_saving ? 'Saving…' : 'Save changes'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminColors.ink,
                    foregroundColor: AdminColors.paper,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    AdminSectionCard(
                      title: 'Live preview',
                      subtitle: 'How the About page header will look.',
                      child: _previewCard(),
                    ),
                    const SizedBox(height: 16),
                    AdminSectionCard(
                      title: 'About page',
                      subtitle: 'Main copy shown on the public About page.',
                      child: Column(
                        children: [
                          _field(_headline, 'Headline'),
                          const SizedBox(height: 10),
                          _field(
                            _body,
                            'Body text (blank line = new paragraph)',
                            maxLines: 8,
                          ),
                          const SizedBox(height: 10),
                          _field(_signoff1, 'Signoff line 1'),
                          const SizedBox(height: 10),
                          _field(_signoff2, 'Signoff line 2'),
                          const SizedBox(height: 10),
                          _field(_closing, 'Closing line'),
                          const SizedBox(height: 10),
                          _field(_footer, 'Footer tagline'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    AdminSectionCard(
                      title: 'Contact rows',
                      subtitle: 'Phone, email and social links.',
                      child: Column(
                        children: [
                          _field(_phoneDisplay, 'Phone (displayed)'),
                          const SizedBox(height: 10),
                          _field(
                            _phoneNumber,
                            'Phone (dialled — digits only)',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _field(
                            _email,
                            'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          _field(_fbUrl, 'Facebook URL'),
                          const SizedBox(height: 10),
                          _field(_igUrl, 'Instagram URL'),
                          const SizedBox(height: 10),
                          _field(_followText, 'Follow-us tagline'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AdminSectionCard(
                      title: 'Quote block (bottom)',
                      subtitle: 'Closing quote shown below the contact band.',
                      child: Column(
                        children: [
                          _field(_quote1, 'Quote line 1'),
                          const SizedBox(height: 10),
                          _field(_quote2, 'Quote line 2'),
                          const SizedBox(height: 10),
                          _field(_quote3, 'Quote line 3'),
                          const SizedBox(height: 10),
                          _field(_quoteHighlight, 'Highlighted phrase'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: AdminColors.muted,
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _previewCard() {
    final site = _currentFromForm();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.canvas,
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            'ABOUT US',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            site.aboutHeadline.isEmpty ? '(headline)' : site.aboutHeadline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AdminColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Divider(color: AdminColors.line)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '[trapped]',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Expanded(child: Divider(color: AdminColors.line)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            site.aboutBody.split('\n\n').first.trim(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AdminColors.line),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          site.phoneDisplay,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AdminColors.line),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.mail, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'weararetrapped@email.com',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
