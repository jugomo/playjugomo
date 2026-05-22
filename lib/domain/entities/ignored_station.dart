/// A station the user has permanently hidden from all lists.
/// Only [id] and [name] are stored — the full station data is not needed.
class IgnoredStation {
  final String id;
  final String name;

  const IgnoredStation({required this.id, required this.name});
}
