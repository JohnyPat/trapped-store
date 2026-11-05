/// Editable site content for the public About page.
/// Stored at `settings/site` in the Realtime Database so the admin
/// can edit it without a rebuild, and every customer reads the same content.
class SiteContent {
  const SiteContent({
    this.aboutHeadline = 'We Were Never Meant To Fit Inside The Boxes.',
    this.aboutBody =
        'TRAPPED was created for those who refuse to stay silent. We stand '
        'for independent thinking, freedom of expression, and the courage to '
        'question systems that demand conformity.\n\n'
        'Every piece is more than clothing — it\'s a statement against '
        'injustice, corruption, and abuse of power.\n\n'
        'Inspired by underground street culture and protest art, our designs '
        'turn frustration into expression and resistance into identity.',
    this.signoffLine1 = 'We don\'t follow the system.',
    this.signoffLine2 = 'We question it.',
    this.closing = 'Not made to obey. Made to awaken.',
    this.footer = '[WE ARE TRAPPED.]',
    this.phoneDisplay = '(+63) 926.078.0626',
    this.phoneNumber = '09260780626',
    this.email = 'weararetrapped@email.com',
    this.facebookUrl = 'https://www.facebook.com/weararetrapped',
    this.instagramUrl = 'https://www.instagram.com/weararetrapped',
    this.followText = 'stay updated on new drops and announcements',
    this.quoteLine1 = 'We don\'t follow the system.',
    this.quoteLine2 = 'We question it.',
    this.quoteLine3 = "We don't fit in.",
    this.quoteHighlight = 'WE ARE TRAPPED.',
  });

  static const defaults = SiteContent();

  final String aboutHeadline;
  final String aboutBody;
  final String signoffLine1;
  final String signoffLine2;
  final String closing;
  final String footer;
  final String phoneDisplay;
  final String phoneNumber;
  final String email;
  final String facebookUrl;
  final String instagramUrl;
  final String followText;
  final String quoteLine1;
  final String quoteLine2;
  final String quoteLine3;
  final String quoteHighlight;

  factory SiteContent.fromMap(Map<String, dynamic>? map) {
    if (map == null) return defaults;
    return SiteContent(
      aboutHeadline: map['aboutHeadline'] as String? ?? defaults.aboutHeadline,
      aboutBody: map['aboutBody'] as String? ?? defaults.aboutBody,
      signoffLine1: map['signoffLine1'] as String? ?? defaults.signoffLine1,
      signoffLine2: map['signoffLine2'] as String? ?? defaults.signoffLine2,
      closing: map['closing'] as String? ?? defaults.closing,
      footer: map['footer'] as String? ?? defaults.footer,
      phoneDisplay: map['phoneDisplay'] as String? ?? defaults.phoneDisplay,
      phoneNumber: map['phoneNumber'] as String? ?? defaults.phoneNumber,
      email: map['email'] as String? ?? defaults.email,
      facebookUrl: map['facebookUrl'] as String? ?? defaults.facebookUrl,
      instagramUrl: map['instagramUrl'] as String? ?? defaults.instagramUrl,
      followText: map['followText'] as String? ?? defaults.followText,
      quoteLine1: map['quoteLine1'] as String? ?? defaults.quoteLine1,
      quoteLine2: map['quoteLine2'] as String? ?? defaults.quoteLine2,
      quoteLine3: map['quoteLine3'] as String? ?? defaults.quoteLine3,
      quoteHighlight:
          map['quoteHighlight'] as String? ?? defaults.quoteHighlight,
    );
  }

  Map<String, dynamic> toMap() => {
        'aboutHeadline': aboutHeadline,
        'aboutBody': aboutBody,
        'signoffLine1': signoffLine1,
        'signoffLine2': signoffLine2,
        'closing': closing,
        'footer': footer,
        'phoneDisplay': phoneDisplay,
        'phoneNumber': phoneNumber,
        'email': email,
        'facebookUrl': facebookUrl,
        'instagramUrl': instagramUrl,
        'followText': followText,
        'quoteLine1': quoteLine1,
        'quoteLine2': quoteLine2,
        'quoteLine3': quoteLine3,
        'quoteHighlight': quoteHighlight,
      };

  SiteContent copyWith({
    String? aboutHeadline,
    String? aboutBody,
    String? signoffLine1,
    String? signoffLine2,
    String? closing,
    String? footer,
    String? phoneDisplay,
    String? phoneNumber,
    String? email,
    String? facebookUrl,
    String? instagramUrl,
    String? followText,
    String? quoteLine1,
    String? quoteLine2,
    String? quoteLine3,
    String? quoteHighlight,
  }) {
    return SiteContent(
      aboutHeadline: aboutHeadline ?? this.aboutHeadline,
      aboutBody: aboutBody ?? this.aboutBody,
      signoffLine1: signoffLine1 ?? this.signoffLine1,
      signoffLine2: signoffLine2 ?? this.signoffLine2,
      closing: closing ?? this.closing,
      footer: footer ?? this.footer,
      phoneDisplay: phoneDisplay ?? this.phoneDisplay,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      followText: followText ?? this.followText,
      quoteLine1: quoteLine1 ?? this.quoteLine1,
      quoteLine2: quoteLine2 ?? this.quoteLine2,
      quoteLine3: quoteLine3 ?? this.quoteLine3,
      quoteHighlight: quoteHighlight ?? this.quoteHighlight,
    );
  }
}