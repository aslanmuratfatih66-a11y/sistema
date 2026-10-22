# Настройка Xcode-проекта под этап 4 (Mac нет — запускается локально на Windows с гемом xcodeproj):
#   ruby ios/scripts/setup_extensions.rb   (из app/)
# Идемпотентно: добавляет файлы каналов в Runner, общий код ios/Shared в оба таргета,
# таргет расширения SistemaWidgets (виджеты + Live Activity), App Group entitlements, встраивание.
require 'xcodeproj'

PROJECT = File.expand_path('../Runner.xcodeproj', __dir__)
EXT_NAME = 'SistemaWidgets'
EXT_BUNDLE_ID = 'com.sistema.sistema.SistemaWidgets'
EXT_DEPLOYMENT = '17.0'

project = Xcodeproj::Project.open(PROJECT)
runner = project.targets.find { |t| t.name == 'Runner' } or abort('нет таргета Runner')

def group_for(project, name, path)
  project.main_group.children.find { |g| g.respond_to?(:path) && g.path == path } ||
    project.main_group.new_group(name, path)
end

def ensure_file(group, name)
  group.files.find { |f| f.path == name } || group.new_reference(name)
end

def ensure_source(target, ref)
  target.source_build_phase.add_file_reference(ref, true)
end

# --- Runner: каналы этапа 4 и entitlements ---
runner_group = project.main_group.children.find { |g| g.respond_to?(:path) && g.path == 'Runner' } or abort('нет группы Runner')
%w[MapKitChannel.swift NowPlayingChannel.swift LiveActivityChannel.swift AlarmKitChannel.swift].each do |f|
  ensure_source(runner, ensure_file(runner_group, f))
end
ensure_file(runner_group, 'Runner.entitlements')
runner.build_configurations.each do |c|
  c.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

# --- Этап 8: локализация Info.plist (ru, tr) — вариантная группа InfoPlist.strings ---
%w[ru tr].each { |r| project.root_object.known_regions << r unless project.root_object.known_regions.include?(r) }
strings = runner_group.children.find { |c| c.isa == 'PBXVariantGroup' && c.name == 'InfoPlist.strings' }
unless strings
  strings = project.new(Xcodeproj::Project::Object::PBXVariantGroup)
  strings.name = 'InfoPlist.strings'
  strings.source_tree = '<group>'
  runner_group.children << strings
end
%w[ru tr].each do |r|
  next if strings.children.any? { |f| f.path == "#{r}.lproj/InfoPlist.strings" }
  f = strings.new_reference("#{r}.lproj/InfoPlist.strings")
  f.name = r
end
runner.resources_build_phase.add_file_reference(strings, true)

# --- Общий код: оба таргета ---
shared_group = group_for(project, 'Shared', 'Shared')
shared_ref = ensure_file(shared_group, 'SistemaShared.swift')
ensure_source(runner, shared_ref)

# --- Расширение ---
ext = project.targets.find { |t| t.name == EXT_NAME }
unless ext
  ext = project.new_target(:app_extension, EXT_NAME, :ios, EXT_DEPLOYMENT, nil, :swift)
end
ext_group = group_for(project, EXT_NAME, EXT_NAME)
Dir.children(File.join(__dir__, '..', EXT_NAME)).sort.each do |f|
  ref = ensure_file(ext_group, f)
  ensure_source(ext, ref) if f.end_with?('.swift')
end
ensure_source(ext, shared_ref)

ext.build_configurations.each do |c|
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = EXT_BUNDLE_ID
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = "#{EXT_NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_ENTITLEMENTS'] = "#{EXT_NAME}/#{EXT_NAME}.entitlements"
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = EXT_DEPLOYMENT
  s['SWIFT_VERSION'] = '5.0'
  s['TARGETED_DEVICE_FAMILY'] = '1'
  s['SKIP_INSTALL'] = 'YES'
  s['MARKETING_VERSION'] = '1.0.0'
  s['CURRENT_PROJECT_VERSION'] = '1'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME'] = 'WidgetBackground'
  s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
end

# Зависимость и встраивание в Runner (фаза «Embed Foundation Extensions», dst 13 = PlugIns).
runner.add_dependency(ext) unless runner.dependencies.any? { |d| d.target == ext }
embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' }
unless embed
  embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
  embed.symbol_dst_subfolder_spec = :plug_ins
end
unless embed.files_references.include?(ext.product_reference)
  bf = embed.add_file_reference(ext.product_reference, true)
  bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end
# Известная проблема Flutter: встраивание после «Thin Binary» даёт цикл сборки — ставим фазу раньше.
phases = runner.build_phases
phases.delete(embed)
thin = phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } || phases.length
phases.insert(thin, embed)

project.save
puts 'ok'
