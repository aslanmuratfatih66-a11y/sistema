// Package defaults — файлы конфигурации по умолчанию (ai.yaml, characters/*.yaml), вшитые в бинарник.
// На сервере их можно переопределить копиями в SISTEMA_CONFIG_DIR (по умолчанию /opt/sistema/config):
// install.sh копирует эту папку туда один раз и больше не перезаписывает (правки владельца сохраняются).
// Загрузка и слияние — пакет internal/aicfg.
package defaults

import "embed"

// FS — ai.yaml и characters/<id>.yaml.
//
//go:embed ai.yaml characters/*.yaml
var FS embed.FS
