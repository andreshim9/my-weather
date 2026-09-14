import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/location_item.dart';
import '../providers/app_state_provider.dart';
import '../services/location_service.dart';

class LocationSelectDialog extends StatefulWidget {
  const LocationSelectDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationSelectDialog(),
    );
  }

  @override
  State<LocationSelectDialog> createState() => _LocationSelectDialogState();
}

class _LocationSelectDialogState extends State<LocationSelectDialog> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  List<LocationItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _locationService.searchLocations(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(
          top: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '위치 검색 & 저장된 위치',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: textSecondary, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Current GPS Location Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await provider.useCurrentGpsLocation();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📍 내 현재 GPS 위치(${provider.currentLocationName})로 변경되었습니다.'),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.my_location, size: 22),
              label: const Text(
                '📍 내 현재 GPS 위치로 설정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isCustomLocation
                    ? (isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight)
                    : AppColors.primary,
                foregroundColor: provider.isCustomLocation
                    ? textPrimary
                    : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: AppColors.primary.withOpacity(0.6), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Search Input Box
          TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 17, color: textPrimary, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '원하는 지역/동네 이름 검색 (예: 해운대, 속초, 강남, 제주)',
              hintStyle: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, fontSize: 14),
              filled: true,
              fillColor: surfaceColor,
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 26),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12, width: 1.5),
              ),
            ),
            onSubmitted: (val) => _performSearch(val),
          ),
          const SizedBox(height: 16),

          // 3. Search Results or Saved Locations List
          if (_isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_searchResults.isNotEmpty) ...[
            Text(
              '🔍 검색 결과 (${_searchResults.length}개)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                itemBuilder: (context, index) {
                  final loc = _searchResults[index];
                  return _buildSearchResultTile(loc, provider, textPrimary, textSecondary);
                },
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '💾 내가 저장한 위치 (${provider.savedLocations.length})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                if (provider.savedLocations.isNotEmpty)
                  Text(
                    '터치하여 변경 / 🗑️ 삭제',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: provider.savedLocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 48, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          const SizedBox(height: 12),
                          Text(
                            '저장된 위치가 없습니다.\n위 검색창에서 원하는 지역을 검색하여 선택하면\n자동으로 이곳에 저장됩니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.savedLocations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final loc = provider.savedLocations[index];
                        final isCurrent = provider.currentLocationName == loc.name;

                        return Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : (isDark ? Colors.white12 : Colors.black12),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isCurrent ? Icons.place : Icons.bookmark,
                              color: isCurrent ? AppColors.accentSun : AppColors.primary,
                              size: 26,
                            ),
                            title: Text(
                              loc.name,
                              style: TextStyle(
                                color: isCurrent ? AppColors.primary : textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(
                              loc.description,
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.accentRed, size: 22),
                              onPressed: () => provider.removeSavedLocation(loc),
                              tooltip: '삭제',
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              provider.setCustomLocation(
                                latitude: loc.latitude,
                                longitude: loc.longitude,
                                locationName: loc.name,
                                description: loc.description,
                                autoSave: false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('📍 ${loc.name}(으)로 위치가 변경되었습니다.'),
                                  backgroundColor: AppColors.accentGreen,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResultTile(
    LocationItem loc,
    AppStateProvider provider,
    Color textPrimary,
    Color textSecondary,
  ) {
    return ListTile(
      leading: const Icon(Icons.add_location_alt_outlined, color: AppColors.accentSun, size: 26),
      title: Text(
        loc.name,
        style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        loc.description,
        style: TextStyle(color: textSecondary, fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary),
        ),
        child: const Text(
          '선택 및 저장',
          style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        provider.setCustomLocation(
          latitude: loc.latitude,
          longitude: loc.longitude,
          locationName: loc.name,
          description: loc.description,
          autoSave: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 ${loc.name}(으)로 위치가 변경 및 저장되었습니다.'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      },
    );
  }
}
