import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/domain/entities.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/export_service.dart';
import 'entity_configuration.dart';

class EntityListPage<T extends BaseEntity> extends StatefulWidget {
  const EntityListPage({super.key, required this.configuration});

  final EntityConfiguration<T> configuration;

  @override
  State<EntityListPage<T>> createState() => _EntityListPageState<T>();
}

class _EntityListPageState<T extends BaseEntity> extends State<EntityListPage<T>> {
  final _searchController = TextEditingController();
  final _exportService = ExportService();
  final _backupService = BackupService();

  late Future<List<T>> _entitiesFuture;

  @override
  void initState() {
    super.initState();
    _entitiesFuture = _loadEntities();
  }

  Future<List<T>> _loadEntities({String? search}) {
    return widget.configuration.repository.all(searchTerm: search);
  }

  Future<void> _refresh() async {
    final search = _searchController.text.trim();
    setState(() {
      _entitiesFuture = _loadEntities(search: search.isEmpty ? null : search);
    });
  }

  Future<void> _deleteEntity(T entity) async {
    final id = widget.configuration.toFormValues(entity)[widget.configuration.idKey] as int;
    await widget.configuration.repository.remove(id);
    await _refresh();
  }

  Future<void> _showForm({T? entity}) async {
    final configuration = widget.configuration;
    final isNew = entity == null;
    final Map<String, dynamic> baseValues = entity != null
        ? Map<String, dynamic>.from(configuration.toFormValues(entity))
        : <String, dynamic>{};
    final Map<String, Set<int>> relationValues = entity != null
        ? Map<String, Set<int>>.fromEntries(
            configuration.toRelationValues(entity).entries.map(
                  (entry) => MapEntry(entry.key, <int>{...entry.value}),
                ),
          )
        : <String, Set<int>>{};
    final relationFutures = <String, Future<List<RelationOption>>>{};
    if (isNew) {
      baseValues[configuration.idKey] = await configuration.repository.nextId();
    }
    final formKey = GlobalKey<FormState>();
    final controllers = <String, TextEditingController>{};
    for (final field in configuration.fields) {
      controllers[field.key] = TextEditingController(
        text: baseValues[field.key]?.toString() ?? '',
      );
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('${isNew ? 'Create' : 'Edit'} ${configuration.singularName}'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...configuration.fields.map((field) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextFormField(
                              controller: controllers[field.key],
                              readOnly: field.readOnly || (field.key == configuration.idKey && !isNew),
                              decoration: InputDecoration(
                                labelText: field.label,
                                hintText: field.hint,
                              ),
                              keyboardType: _keyboardType(field.inputType),
                              maxLines: field.inputType == FieldInputType.multiline ? null : 1,
                              validator: (value) {
                                if (!field.required) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                        ...configuration.relations.map(
                          (relation) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FutureBuilder<List<RelationOption>>(
                              future: relationFutures.putIfAbsent(
                                relation.key,
                                relation.loadOptions,
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final options = snapshot.data!;
                                final selected = relationValues[relation.key] ?? <int>{};
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(relation.label, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: options.map((option) {
                                        final isSelected = selected.contains(option.id);
                                        return FilterChip(
                                          label: Text(option.label),
                                          selected: isSelected,
                                          onSelected: (value) {
                                            setModalState(() {
                                              final items = relationValues.putIfAbsent(
                                                relation.key,
                                                () => <int>{},
                                              );
                                              if (value) {
                                                items.add(option.id);
                                              } else {
                                                items.remove(option.id);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    final values = <String, dynamic>{};
                    for (final field in configuration.fields) {
                      final raw = controllers[field.key]!.text.trim();
                      if (raw.isEmpty) {
                        values[field.key] = null;
                        continue;
                      }
                      switch (field.inputType) {
                        case FieldInputType.number:
                          values[field.key] = int.tryParse(raw) ?? int.parse(raw);
                          break;
                        default:
                          values[field.key] = raw;
                      }
                    }
                    final entity = configuration.fromForm(values, relationValues);
                    await configuration.repository.save(entity);
                    if (mounted) {
                      Navigator.of(context).pop();
                      await _refresh();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TextInputType _keyboardType(FieldInputType type) {
    switch (type) {
      case FieldInputType.number:
        return TextInputType.number;
      case FieldInputType.phone:
        return TextInputType.phone;
      case FieldInputType.email:
        return TextInputType.emailAddress;
      case FieldInputType.date:
        return TextInputType.datetime;
      case FieldInputType.multiline:
        return TextInputType.multiline;
      case FieldInputType.text:
      default:
        return TextInputType.text;
    }
  }

  Future<void> _exportToPdf(List<T> entities) async {
    if (entities.isEmpty) {
      return;
    }
    final columns = widget.configuration.fields.map((field) => field.label).toList();
    final rows = _exportService.buildRowsFromEntities(entities);
    await _exportService.exportToPdf(
      filename: widget.configuration.name.replaceAll(' ', '_').toLowerCase(),
      entities: entities,
      columns: columns,
      rows: rows,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF exported to the documents directory.')),
      );
    }
  }

  Future<void> _exportToExcel(List<T> entities) async {
    if (entities.isEmpty) {
      return;
    }
    final columns = widget.configuration.fields.map((field) => field.label).toList();
    final rows = _exportService.buildRowsFromEntities(entities);
    await _exportService.exportToExcel(
      filename: widget.configuration.name.replaceAll(' ', '_').toLowerCase(),
      entities: entities,
      columns: columns,
      rows: rows,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel exported to the documents directory.')),
      );
    }
  }

  Future<void> _exportJsonBackup() async {
    final file = await _backupService.exportDatabaseToJson('ziso_backup');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved to ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.configuration.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: () async {
              final entities = await _entitiesFuture;
              await _exportToPdf(entities);
            },
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Export Excel',
            onPressed: () async {
              final entities = await _entitiesFuture;
              await _exportToExcel(entities);
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'Export JSON Backup',
            onPressed: _exportJsonBackup,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search ${widget.configuration.name.toLowerCase()}',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _refresh,
                ),
              ),
              onSubmitted: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<T>>(
                future: _entitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final entities = snapshot.data ?? const [];
                  if (entities.isEmpty) {
                    return const Center(child: Text('No records yet. Tap + to add one.'));
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      itemCount: entities.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final entity = entities[index];
                        final title = widget.configuration.listTitleBuilder?.call(entity) ??
                            widget.configuration.toFormValues(entity)[widget.configuration.fields.first.key].toString();
                        final subtitle = widget.configuration.listSubtitleBuilder?.call(entity);
                        return ListTile(
                          title: Text(title),
                          subtitle: subtitle != null ? Text(subtitle) : null,
                          onTap: () => _showForm(entity: entity),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Confirm delete'),
                                      content: const Text('Are you sure you want to delete this record?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (confirmed) {
                                await _deleteEntity(entity);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
