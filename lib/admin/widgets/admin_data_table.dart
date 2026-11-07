import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:trapped_store/shared/constants/admin_constants.dart';

/// Column definition for [AdminDataTable].
class AdminTableColumn<T> {
  const AdminTableColumn({
    required this.label,
    required this.cell,
    this.sortValue,
    this.width,
    this.flex = 1,
    this.align = Alignment.centerLeft,
  });

  final String label;
  final Widget Function(T row) cell;
  final Comparable<dynamic> Function(T row)? sortValue;

  /// Fixed width for action/icon columns. Leave null to use [flex].
  final double? width;
  final int flex;
  final Alignment align;
}

/// Filter chip displayed above an [AdminDataTable].
class AdminTableFilter {
  const AdminTableFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// Desktop data table with search, filters, sortable headers and pagination.
///
/// The caller owns filtering (the filter callbacks update parent state and the
/// caller passes the filtered rows in). Search, sorting and paging are handled
/// locally so every admin table behaves the same way.
class AdminDataTable<T> extends StatefulWidget {
  const AdminDataTable({
    super.key,
    required this.rows,
    required this.columns,
    this.searchHint = 'Search…',
    this.searchText,
    this.filters = const [],
    this.trailing,
    this.pageSize = 10,
    this.onRowTap,
    this.emptyMessage = 'No records found.',
    this.loading = false,
    this.error,
    this.minWidth = 760,
    this.rowHeight = 64,
    this.initialSortIndex,
    this.initialSortAscending = true,
  });

  final List<T> rows;
  final List<AdminTableColumn<T>> columns;
  final String searchHint;

  /// When provided, a search box is shown and rows are filtered by this text.
  final String Function(T row)? searchText;
  final List<AdminTableFilter> filters;
  final Widget? trailing;
  final int pageSize;
  final ValueChanged<T>? onRowTap;
  final String emptyMessage;
  final bool loading;
  final String? error;
  final double minWidth;
  final double rowHeight;
  final int? initialSortIndex;
  final bool initialSortAscending;

  @override
  State<AdminDataTable<T>> createState() => _AdminDataTableState<T>();
}

class _AdminDataTableState<T> extends State<AdminDataTable<T>> {
  final _searchController = TextEditingController();
  String _query = '';
  int _page = 0;
  late int _pageSize;
  int? _sortIndex;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _sortIndex = widget.initialSortIndex;
    _sortAscending = widget.initialSortAscending;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSort(int index) {
    setState(() {
      if (_sortIndex == index) {
        _sortAscending = !_sortAscending;
      } else {
        _sortIndex = index;
        _sortAscending = true;
      }
      _page = 0;
    });
  }

  int _compareValues(Comparable<dynamic> a, Comparable<dynamic> b) {
    if (a is num && b is num) return a.compareTo(b);
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  List<T> _visibleRows() {
    var rows = widget.rows;

    final searchText = widget.searchText;
    if (searchText != null && _query.isNotEmpty) {
      rows = rows
          .where((row) => searchText(row).toLowerCase().contains(_query))
          .toList();
    }

    final sortIndex = _sortIndex;
    if (sortIndex != null && sortIndex < widget.columns.length) {
      final sortValue = widget.columns[sortIndex].sortValue;
      if (sortValue != null) {
        rows = [...rows]
          ..sort((a, b) {
            final result = _compareValues(sortValue(a), sortValue(b));
            return _sortAscending ? result : -result;
          });
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows();
    final total = rows.length;
    final totalPages = math.max(1, (total / _pageSize).ceil());
    final page = _page.clamp(0, totalPages - 1);
    final start = page * _pageSize;
    final end = math.min(start + _pageSize, total);
    final pageRows = total == 0 ? <T>[] : rows.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(),
        if (_hasToolbar) const SizedBox(height: 14),
        Expanded(
          child: Material(
            color: AdminColors.paper,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AdminColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tableWidth = math.max(
                        constraints.maxWidth,
                        widget.minWidth,
                      );
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          height: constraints.maxHeight,
                          child: Column(
                            children: [
                              _buildHeaderRow(),
                              const Divider(height: 1, color: AdminColors.line),
                              Expanded(child: _buildBody(pageRows, total)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!widget.loading && widget.error == null && total > 0) ...[
                  const Divider(height: 1, color: AdminColors.line),
                  _buildFooter(start, end, total, page, totalPages),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool get _hasToolbar =>
      widget.searchText != null ||
      widget.filters.isNotEmpty ||
      widget.trailing != null;

  Widget _buildToolbar() {
    final children = <Widget>[];

    if (widget.searchText != null) {
      children.add(
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {
                  _query = value.trim().toLowerCase();
                  _page = 0;
                }),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 19),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, size: 17),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _page = 0;
                            });
                          },
                        ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AdminColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AdminColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AdminColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.trailing != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 16));
      children.add(widget.trailing!);
    }

    final topRow = children.isEmpty
        ? const SizedBox.shrink()
        : Row(children: children);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (children.isNotEmpty) topRow,
        if (widget.filters.isNotEmpty) ...[
          if (children.isNotEmpty) const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in widget.filters)
                ChoiceChip(
                  label: Text(filter.label),
                  selected: filter.selected,
                  onSelected: (_) => filter.onTap(),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AdminColors.paper,
                  selectedColor: AdminColors.ink,
                  side: BorderSide(
                    color: filter.selected ? AdminColors.ink : AdminColors.line,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: filter.selected
                        ? AdminColors.paper
                        : AdminColors.ink,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 44,
      color: AdminColors.canvas,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < widget.columns.length; i++)
            _wrapCell(widget.columns[i], _headerCell(i, widget.columns[i])),
        ],
      ),
    );
  }

  Widget _headerCell(int index, AdminTableColumn<T> column) {
    final sortable = column.sortValue != null;
    final sorted = _sortIndex == index;
    final label = Text(
      column.label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: AdminColors.muted,
      ),
    );

    if (!sortable) return label;

    return InkWell(
      onTap: () => _toggleSort(index),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: label),
            const SizedBox(width: 4),
            Icon(
              sorted
                  ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 13,
              color: sorted ? AdminColors.ink : AdminColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<T> pageRows, int total) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AdminColors.muted),
          ),
        ),
      );
    }
    if (total == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 36,
                color: AdminColors.muted,
              ),
              const SizedBox(height: 10),
              Text(
                widget.emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AdminColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: pageRows.length,
      itemBuilder: (context, index) {
        final row = pageRows[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(row),
            hoverColor: AdminColors.canvas.withValues(alpha: 0.7),
            child: Container(
              height: widget.rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminColors.line)),
              ),
              child: Row(
                children: [
                  for (final column in widget.columns)
                    _wrapCell(column, column.cell(row)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wrapCell(AdminTableColumn<T> column, Widget child) {
    final content = Align(alignment: column.align, child: child);
    if (column.width != null) {
      return SizedBox(width: column.width, child: content);
    }
    return Expanded(flex: column.flex, child: content);
  }

  Widget _buildFooter(int start, int end, int total, int page, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Showing ${start + 1}–$end of $total',
            style: const TextStyle(fontSize: 12, color: AdminColors.muted),
          ),
          const Spacer(),
          const Text(
            'Rows',
            style: TextStyle(fontSize: 12, color: AdminColors.muted),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _pageSize,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: AdminColors.ink),
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 25, child: Text('25')),
                DropdownMenuItem(value: 50, child: Text('50')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _pageSize = value;
                  _page = 0;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Previous page',
            child: IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: page > 0
                  ? () => setState(() => _page = page - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
          ),
          Text(
            'Page ${page + 1} of $totalPages',
            style: const TextStyle(fontSize: 12, color: AdminColors.ink),
          ),
          Tooltip(
            message: 'Next page',
            child: IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: page < totalPages - 1
                  ? () => setState(() => _page = page + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}
