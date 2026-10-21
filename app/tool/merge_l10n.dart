// Сборка lib/l10n/app_{ru,tr}.arb из фрагментов l10n_parts/<часть>_{ru,tr}.arb.
// Каждая фича (сабагент) правит только свой фрагмент — без конфликтов в общем файле.
//
// Запуск из app/:  dart run tool/merge_l10n.dart && flutter gen-l10n
//
// Правила: ключ может встречаться только в одном фрагменте (иначе ошибка);
// метаданные "@ключ" идут вместе с ключом; "@@locale" берётся из имени файла.
// Битый фрагмент (например, недописанный) — ошибка с именем файла, общий файл не трогается.
import 'dart:convert';
import 'dart:io';

const locales = ['ru', 'tr'];

void main() {
  final partsDir = Directory('l10n_parts');
  if (!partsDir.existsSync()) {
    stderr.writeln('Нет каталога l10n_parts — запускайте из app/');
    exit(2);
  }
  var failed = false;
  for (final locale in locales) {
    final files = partsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('_$locale.arb'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    // core — первым, чтобы порядок ключей в общем файле был стабильным.
    files.sort((a, b) => _rank(a).compareTo(_rank(b)));

    final merged = <String, Object?>{'@@locale': locale};
    final owner = <String, String>{};
    for (final f in files) {
      final name = f.uri.pathSegments.last;
      Map<String, Object?> data;
      try {
        final decoded = jsonDecode(f.readAsStringSync());
        if (decoded is! Map<String, Object?>) throw const FormatException('ожидался JSON-объект');
        data = decoded;
      } on FormatException catch (e) {
        stderr.writeln('$name: невалидный JSON — ${e.message}');
        failed = true;
        continue;
      }
      for (final e in data.entries) {
        if (e.key == '@@locale') continue;
        final key = e.key.startsWith('@') ? e.key.substring(1) : e.key;
        final prev = owner[key];
        if (prev != null && prev != name) {
          stderr.writeln('Ключ "$key" есть и в $prev, и в $name');
          failed = true;
          continue;
        }
        owner[key] = name;
        merged[e.key] = e.value;
      }
    }
    if (failed) continue;
    final out = File('lib/l10n/app_$locale.arb');
    final tmp = File('${out.path}.tmp');
    tmp.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(merged)}\n');
    tmp.renameSync(out.path);
    stdout.writeln('${out.path}: ${owner.length} ключей из ${files.length} фрагментов');
  }
  if (failed) exit(1);
}

int _rank(File f) => f.uri.pathSegments.last.startsWith('core_') ? 0 : 1;
