part of yandex_mapkit;

List<Set<MapObject>> _computeUpdates(MapUpdatesMessage message) {
  final previousObjects = Map<MapObjectId, MapObject>.fromEntries(message
      .previous
      .map((MapObject object) => MapEntry(object.mapId, object)));
  final currentObjects = Map<MapObjectId, MapObject>.fromEntries(message.current
      .map((MapObject object) => MapEntry(object.mapId, object)));
  final previousObjectIds = previousObjects.keys.toSet();
  final currentObjectIds = currentObjects.keys.toSet();

  final _objectsToRemove = previousObjectIds
      .difference(currentObjectIds)
      .map((MapObjectId id) => previousObjects[id]!)
      .toSet();

  final _objectsToAdd = currentObjectIds
      .difference(previousObjectIds)
      .map((MapObjectId id) => currentObjects[id]!)
      .toSet();

  final _objectsToChange = currentObjectIds
      .intersection(previousObjectIds)
      .map((MapObjectId id) => currentObjects[id]!)
      .where((MapObject current) => current != previousObjects[current.mapId])
      .toSet();
  return [_objectsToAdd, _objectsToChange, _objectsToRemove];
}

class MapUpdatesMessage {
  MapUpdatesMessage({required this.previous, required this.current});
  final Set<MapObject> previous;
  final Set<MapObject> current;
}

/// Update specification for a set of objects.
class MapObjectUpdates<T extends MapObject> extends Equatable {
  MapObjectUpdates.from(this.previous, this.current) {
    final previousObjects = Map<MapObjectId, T>.fromEntries(
        previous.map((T object) => MapEntry(object.mapId, object)));
    final currentObjects = Map<MapObjectId, T>.fromEntries(
        current.map((T object) => MapEntry(object.mapId, object)));
    final previousObjectIds = previousObjects.keys.toSet();
    final currentObjectIds = currentObjects.keys.toSet();

    _objectsToRemove = previousObjectIds
        .difference(currentObjectIds)
        .map((MapObjectId id) => previousObjects[id]!)
        .toSet();

    _objectsToAdd = currentObjectIds
        .difference(previousObjectIds)
        .map((MapObjectId id) => currentObjects[id]!)
        .toSet();

    _objectsToChange = currentObjectIds
        .intersection(previousObjectIds)
        .map((MapObjectId id) => currentObjects[id]!)
        .where((T current) => current != previousObjects[current.mapId])
        .toSet();
  }
  MapObjectUpdates.fromObjects(this.previous, this.current,
      Set<T> _objectsToRemove, Set<T> _objectsToAdd, Set<T> _objectsToChange) {
    _objectsToRemove = _objectsToRemove;
    _objectsToAdd = _objectsToAdd;
    _objectsToChange = _objectsToChange;
  }

  static Future<MapObjectUpdates> fromCompute(Set<MapObject> previous, Set<MapObject> current) async {
    final res = await compute(
      _computeUpdates,
      MapUpdatesMessage(
        previous: previous,
        current: current,
      ),
    );
    return MapObjectUpdates.fromObjects(
      previous,
      current,
      res[0],
      res[1],
      res[2],
    );
  }

  /// Set of objects to be added in this update.
  Set<T> get objectsToAdd => _objectsToAdd;
  late final Set<T> _objectsToAdd;

  /// Set of objects to be changed in this update.
  Set<T> get objectsToChange => _objectsToChange;
  late final Set<T> _objectsToChange;

  /// Set of objects to be removed in this update.
  Set<T> get objectsToRemove => _objectsToRemove;
  late final Set<T> _objectsToRemove;

  /// Set of objects before update
  final Set<T> previous;

  /// Set of objects after update
  final Set<T> current;

  @override
  List<Object> get props => <Object>[
        _objectsToAdd,
        _objectsToChange,
        _objectsToRemove,
      ];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      'toAdd': _objectsToAdd.map((MapObject el) => el._createJson()).toList(),
      'toChange': _objectsToChange
          .map((MapObject el) => el._updateJson(previous
              .firstWhere((MapObject prevEl) => prevEl.mapId == el.mapId)))
          .toList(),
      'toRemove':
          _objectsToRemove.map((MapObject el) => el._removeJson()).toList(),
    };
  }
}
