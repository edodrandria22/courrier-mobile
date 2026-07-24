/// Classe utilitaire générique pour retourner le résultat d'une opération
class ServiceResult<T> {
  final bool success;
  final String? error;
  final T? data;

  ServiceResult({
    required this.success,
    this.error,
    this.data,
  });
}