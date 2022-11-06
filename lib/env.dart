import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(obfuscate: true)
  static final HASH = _Env.HASH;

  @EnviedField(obfuscate: true)
  static final SALT = _Env.SALT;

  @EnviedField()
  static const SUPABASE_URL = _Env.SUPABASE_URL;

  @EnviedField()
  static const SUPABASE_ANON_KEY = _Env.SUPABASE_ANON_KEY;
}
