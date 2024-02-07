part of yandex_mapkit;

MapObjectUpdates mapObjectsFromStatic(
    MapObjects$Input input) {
  return MapObjectUpdates.from(input.current, input.previous);
}

class MapObjects$Input<T extends MapObject> {
  const MapObjects$Input(this.previous, this.current);

  final Set<T> previous;
  final Set<T> current;
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
