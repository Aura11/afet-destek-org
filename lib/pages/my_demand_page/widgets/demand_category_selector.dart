import 'package:collection/collection.dart';
import 'package:deprem_destek/shared/state/app_cubit.dart';
import 'package:deprem_destek/shared/theme/colors.dart';
import 'package:deprem_destek/shared/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class DemandCategorySelector extends StatefulWidget {
  const DemandCategorySelector({required this.formControl, super.key});
  final FormControl<List<String>> formControl;

  @override
  State<DemandCategorySelector> createState() => _DemandCategorySelectorState();
}

class _DemandCategorySelectorState extends State<DemandCategorySelector> {
  late List<String> _selectedCategoryIds;

  late TextEditingController controller;

  void setControllerText() {
    controller
      ..text = _selectedCategoryIds
          .map(
            (id) => context.read<AppCubit>().state.whenOrNull(
                  loaded: (currentLocation, demandCategories) =>
                      demandCategories
                          .firstWhereOrNull(
                            (category) => category.id == id,
                          )
                          ?.name,
                ),
          )
          .whereNotNull()
          .join(', ')
      ..selection = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length,
      );
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    // ignore: cast_nullable_to_non_nullable
    _selectedCategoryIds = List.from(widget.formControl.value as List<String>);
    setControllerText();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: cast_nullable_to_non_nullable
    _selectedCategoryIds = List.from(widget.formControl.value as List<String>);

    final demandCategories = context.read<AppCubit>().state.whenOrNull(
          loaded: (currentLocation, demandCategories) => demandCategories,
        );

    if (demandCategories == null) {
      return const Loader();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppFormFieldTitle(title: 'Ihtiyaç Türü'),
          const SizedBox(height: 4),
          TextFormField(
            readOnly: true,
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Ihtiyaç Türü Seçiniz',
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(width: 2, color: Colors.red),
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(width: 2, color: Colors.grey.shade200),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade500),
              suffixIcon: const Icon(Icons.arrow_forward_ios),
            ),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, setStateForAlert) {
                  return Dialog(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .5,
                        minHeight: MediaQuery.of(context).size.height * .5,
                        minWidth: MediaQuery.of(context).size.width * .8,
                        maxWidth: MediaQuery.of(context).size.width * .8,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'İhtiyaç Türü '
                                    '(${_selectedCategoryIds.length})',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                IconButton(
                                  onPressed: Navigator.of(context).pop,
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Divider(),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: demandCategories.length,
                              itemBuilder: (context, index) {
                                final category = demandCategories[index];
                                final isSelected =
                                    _selectedCategoryIds.contains(category.id);
                                return CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(
                                      () => isSelected
                                          ? _selectedCategoryIds
                                              .remove(category.id)
                                          : _selectedCategoryIds
                                              .add(category.id),
                                    );
                                    setStateForAlert(() {});

                                    widget.formControl.value =
                                        _selectedCategoryIds;

                                    setControllerText();
                                  },
                                  title: Text(category.name),
                                );
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Divider(),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Kaydet',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppFormFieldTitle extends StatelessWidget {
  const AppFormFieldTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.formFieldTitle,
            ),
      ),
    );
  }
}
