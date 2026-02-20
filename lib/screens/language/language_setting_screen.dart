import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:myapp/models/language_model.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AppLanguage> languages = [
      AppLanguage('English', const Locale('en')),
      AppLanguage('اردو', const Locale('ur')),
      AppLanguage('العربية', const Locale('ar')),
      AppLanguage('Português', const Locale('pt')),
      AppLanguage('Chinese', const Locale('zh')),
      AppLanguage('Russia', const Locale('ru')),
      AppLanguage('Spanish', const Locale('es')),
      AppLanguage('French', const Locale('fr')),
      AppLanguage('Deutsch', const Locale('de')),
      // new languages
      AppLanguage('Hindi', const Locale('hi')),
      AppLanguage('Thai', const Locale('th')),
      AppLanguage('Vietnamese', const Locale('vi')),
      AppLanguage('Bengali', const Locale('bn')),
      AppLanguage('Persian', const Locale('fa')),
      AppLanguage('Polish', const Locale('pl')),
      AppLanguage('Persian', const Locale('fa')),
      AppLanguage('Indonesian', const Locale('id')),
      AppLanguage('Italian', const Locale('it')),
      AppLanguage('Korean', const Locale('ko')),
      AppLanguage('Turkish', const Locale('tr')),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('language'.tr())),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = context.locale == lang.locale;

          return ListTile(
            title: Text(lang.title),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () async {
              await context.setLocale(lang.locale);
            },
          );
        },
      ),
    );
  }
}
