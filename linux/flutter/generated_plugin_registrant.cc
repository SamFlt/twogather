//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <pcmtowave/pcmtowave_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) pcmtowave_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PcmtowavePlugin");
  pcmtowave_plugin_register_with_registrar(pcmtowave_registrar);
}
