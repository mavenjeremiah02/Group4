import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/healthcare_models.dart';

const primaryTeal = Color(0xFF0BA5A4);
const deepBlue = Color(0xFF073B4C);
const accentRed = Color(0xFFEF476F);

/// Dark brand green used for the status bar and app bars.
const brandAppBarGreen = deepBlue;

/// Taller app bar so the Welcome + name title fits comfortably.
const brandAppBarHeight = 76.0;

const SystemUiOverlayStyle brandSystemUiOverlay = SystemUiOverlayStyle(
  statusBarColor: brandAppBarGreen,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: brandAppBarGreen,
  systemNavigationBarIconBrightness: Brightness.light,
);

final AppBarTheme brandAppBarTheme = AppBarTheme(
  backgroundColor: brandAppBarGreen,
  foregroundColor: Colors.white,
  surfaceTintColor: brandAppBarGreen,
  toolbarHeight: brandAppBarHeight,
  elevation: 0,
  centerTitle: false,
  iconTheme: const IconThemeData(color: Colors.white),
  actionsIconTheme: const IconThemeData(color: Colors.white),
  titleTextStyle: const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  ),
  systemOverlayStyle: brandSystemUiOverlay,
);

/// Horizontal padding for dashboard tab content (not the bottom nav).
const dashboardContentPadding = EdgeInsets.fromLTRB(20, 20, 20, 12);

/// App bar title: "Welcome" on top, user name below (white on dark green bar).
class WelcomeAppBarTitle extends StatelessWidget {
  const WelcomeAppBarTitle({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

/// Full-width bottom navigation pinned to the screen edge.
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  static const double barHeight = 56;

  static double bottomInset(BuildContext context) {
    return barHeight + MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final navTheme = NavigationBarThemeData(
      backgroundColor: brandAppBarGreen,
      surfaceTintColor: brandAppBarGreen,
      indicatorColor: Colors.white.withValues(alpha: 0.22),
      height: barHeight,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.72),
          fontSize: 11,
          height: 1.1,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.72),
          size: 22,
        );
      }),
    );

    return Material(
      color: brandAppBarGreen,
      elevation: 0,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: navTheme,
            visualDensity: VisualDensity.compact,
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
            height: barHeight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 250),
          ),
        ),
      ),
    );
  }
}

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE7FFFB), Color(0xFFF6FBFF), Color(0xFFDDF4FF)],
        ),
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.action,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: deepBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(color: Color(0xFF5B7280)),
                ),
              ],
            ],
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.color = primaryTeal,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1200737A),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Color(0xFF5B7280))),
        ],
      ),
    );

    return Expanded(
      child: onTap == null
          ? tile
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: tile,
              ),
            ),
    );
  }
}

class ImageInfoCard extends StatelessWidget {
  const ImageInfoCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.badge,
    super.key,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1200737A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(24),
            ),
            child: Image.network(
              imageUrl,
              width: 104,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 104,
                height: 112,
                color: const Color(0xFFE0F4F5),
                child: const Icon(Icons.local_hospital, color: primaryTeal),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FFF9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: primaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  if (badge != null) const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF5B7280)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trailing,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionPill extends StatelessWidget {
  const ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = primaryTeal,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1F1F4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: deepBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class HospitalPickerField extends StatelessWidget {
  const HospitalPickerField({
    required this.hospitals,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Hospital> hospitals;
  final Hospital? selected;
  final ValueChanged<Hospital> onSelected;

  Future<void> _openPicker(BuildContext context) async {
    if (hospitals.isEmpty) {
      showSimulationSnack(
        context,
        'Upload a hospital first, then assign staff to it.',
      );
      return;
    }

    final picked = await showModalBottomSheet<Hospital>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _HospitalPickerSheet(
        hospitals: hospitals,
        selected: selected,
      ),
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Assigned hospital from uploads',
          prefixIcon: Icon(Icons.local_hospital_rounded),
          suffixIcon: Icon(Icons.unfold_more_rounded),
        ),
        child: Text(
          selected?.name ?? 'Tap to choose hospital',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected == null
                ? const Color(0xFF5B7280)
                : deepBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HospitalPickerSheet extends StatefulWidget {
  const _HospitalPickerSheet({
    required this.hospitals,
    required this.selected,
  });

  final List<Hospital> hospitals;
  final Hospital? selected;

  @override
  State<_HospitalPickerSheet> createState() => _HospitalPickerSheetState();
}

class _HospitalPickerSheetState extends State<_HospitalPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hospital> get _filtered {
    final lowerQuery = _query.toLowerCase();
    if (lowerQuery.isEmpty) {
      return widget.hospitals;
    }
    return widget.hospitals.where((hospital) {
      return hospital.name.toLowerCase().contains(lowerQuery) ||
          hospital.location.toLowerCase().contains(lowerQuery) ||
          hospital.specialty.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.78;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD7E5EA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choose hospital',
              style: TextStyle(
                color: deepBlue,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search hospitals',
                hintText: 'Name, location, or specialty',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hospitals match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final hospital = _filtered[index];
                      final isSelected =
                          widget.selected?.id == hospital.id ||
                          widget.selected?.name == hospital.name;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: isSelected
                            ? const Color(0xFFE8FFF9)
                            : Colors.white,
                        leading: const Icon(
                          Icons.local_hospital_rounded,
                          color: primaryTeal,
                        ),
                        title: Text(
                          hospital.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: deepBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          '${hospital.location} • ${hospital.specialty}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: primaryTeal,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, hospital),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void showSimulationSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
