import 'main_c.dart' as module_c;

const defaultBaseUrl = module_c.defaultBaseUrl;
Future<void> main() => start();
Future<void> start([String baseUrl = defaultBaseUrl]) =>
    module_c.startModuleC(baseUrl);
