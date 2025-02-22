import 'package:flutter/material.dart';
import 'keys_setting.dart';
import 'mcp_server.dart';
import 'general_setting.dart';
import 'package:chatmcp/generated/app_localizations.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<SettingTab> _getTabs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SettingTab(
          title: l10n.general,
          icon: Icons.settings,
          content: GeneralSettings()),
      SettingTab(
          title: l10n.providers, icon: Icons.api, content: KeysSettings()),
      SettingTab(
          title: l10n.mcpServer, icon: Icons.storage, content: McpServer()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs(context);

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            tabs: tabs
                .map((tab) => Tab(
                      icon: Icon(tab.icon),
                      text: tab.title,
                    ))
                .toList(),
            onTap: (index) {
              setState(() {});
            },
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) => tab.content).toList(),
        ),
      ),
    );
  }
}

// 选项卡数据模型
class SettingTab {
  final String title;
  final IconData icon;
  final Widget content;

  SettingTab({
    required this.title,
    required this.icon,
    required this.content,
  });
}
