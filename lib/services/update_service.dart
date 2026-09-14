import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_theme.dart';

class UpdateInfo {
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool hasUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.hasUpdate,
  });
}

class UpdateService {
  static const String githubOwner = 'andreshim9';
  static const String githubRepo = 'my-weather';
  static const String latestReleaseApi =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  /// GitHub Releases API를 조회하여 새 버전이 있는지 확인
  static Future<UpdateInfo?> checkUpdate() async {
    if (kIsWeb) return null;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. 1.0.0
      debugPrint('[UpdateService] Current App Version: $currentVersion');

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      ));

      final response = await dio.get(latestReleaseApi);
      if (response.statusCode == 200) {
        final data = response.data;
        String tagName = data['tag_name'] ?? ''; // e.g. v1.1.0 or 1.1.0
        final cleanTag = tagName.replaceAll('v', '').replaceAll('V', '').trim();
        final body = data['body'] ?? '새로운 업데이트가 있습니다.';

        String apkUrl = '';
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null) {
          for (final asset in assets) {
            final name = asset['name'] as String? ?? '';
            if (name.endsWith('.apk')) {
              apkUrl = asset['browser_download_url'] ?? '';
              break;
            }
          }
        }

        final hasNewer = _isVersionGreater(cleanTag, currentVersion);
        debugPrint(
            '[UpdateService] Latest Release: $cleanTag (Current: $currentVersion, HasNewer: $hasNewer, ApkUrl: $apkUrl)');

        return UpdateInfo(
          latestVersion: cleanTag,
          releaseNotes: body,
          downloadUrl: apkUrl,
          hasUpdate: hasNewer && apkUrl.isNotEmpty,
        );
      }
    } catch (e, stack) {
      debugPrint('[UpdateService] Update check failed: $e\n$stack');
    }
    return null;
  }

  /// 버전 비교 (v1 > v2 인지 확인)
  static bool _isVersionGreater(String v1, String v2) {
    try {
      final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final num1 = i < parts1.length ? parts1[i] : 0;
        final num2 = i < parts2.length ? parts2[i] : 0;
        if (num1 > num2) return true;
        if (num1 < num2) return false;
      }
    } catch (_) {}
    return false;
  }

  /// 업데이트 다이얼로그 표시 및 다운로드/설치 진행
  static void showUpdateDialog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UpdateDialogWidget(info: info),
    );
  }
}

class _UpdateDialogWidget extends StatefulWidget {
  final UpdateInfo info;

  const _UpdateDialogWidget({Key? key, required this.info}) : super(key: key);

  @override
  State<_UpdateDialogWidget> createState() => _UpdateDialogWidgetState();
}

class _UpdateDialogWidgetState extends State<_UpdateDialogWidget> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _isDownloading = true;
      _statusText = '최신 APK 다운로드 중...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '/my-weather-update.apk';

      final dio = Dio();
      await dio.download(
        widget.info.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _statusText = '다운로드 중 (%)';
            });
          }
        },
      );

      setState(() {
        _statusText = '설치 패키지 실행 중...';
      });

      // 다운로드 완료 후 APK 파일 열기 (안드로이드 OS 패키지 설치 화면 띄우기)
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && mounted) {
        setState(() {
          _statusText = '설치 실행 완료 (알림창을 확인하세요)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusText = '다운로드 실패. 다시 시도해 주세요.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '새로운 버전 발견! ✨',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'v 업데이트가 가능합니다',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Text(
                widget.info.releaseNotes,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                if (!_isDownloading)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('다음에', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (!_isDownloading) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isDownloading ? null : _startDownloadAndInstall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _isDownloading ? '다운로드 중...' : '지금 업데이트',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
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
