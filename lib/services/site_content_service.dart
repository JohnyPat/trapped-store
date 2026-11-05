import 'package:trapped_store/services/database_service.dart';

import '../models/site_content.dart';
import '../utils/parse.dart';

/// Reads and writes the editable About/Contact page content at `settings/site`.
///
/// Read access is public (per the database rules), write access is limited
/// to the admin account. The app falls back to built-in defaults when the
/// node is missing, so the page never breaks.
class SiteContentService {
  SiteContentService({DatabaseService? database})
      : _database = database ?? DatabaseService();

  final DatabaseService _database;

  static const SiteContent defaults = SiteContent.defaults;

  /// Live stream of the site content (falls back to defaults while loading).
  Stream<SiteContent> watchSite() {
    return _database.settingsRef.child('site').onValue.map((event) {
      final data = asStringMap(event.snapshot.value);
      return SiteContent.fromMap(data);
    });
  }

  /// One-shot read for saving flows (always returns defaults if missing).
  Future<SiteContent> fetchOnce() async {
    final snapshot = await _database.settingsRef.child('site').get();
    final data = asStringMap(snapshot.value);
    return SiteContent.fromMap(data);
  }

  /// Save (overwrite) the site content. Admin-only per the database rules.
  Future<void> saveSite(SiteContent content) async {
    await _database.settingsRef.child('site').set(content.toMap());
  }
}