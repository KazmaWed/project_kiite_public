import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/fee_demand/fee_demand_view_model.dart';

class FeeDemandFormView extends StatelessWidget {
  const FeeDemandFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final viewModel = ref.watch(feeDemandViewModelProvider);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text('請求フォーム'),
          ),
          const DatePickerView(),
          const SizedBox(height: 0),
          PlaceFormView(
            viewModel: viewModel,
            titleController: viewModel.fromTitleController,
            stationController: viewModel.fromStationController,
            titleFocusIndex: 0,
            stationFocusIndex: 1,
            hintText: '出発',
            iconData: KiiteIcons.startPlace,
          ),
          const SizedBox(height: 0),
          PlaceFormView(
            viewModel: viewModel,
            titleController: viewModel.toTitleController,
            stationController: viewModel.toStationController,
            titleFocusIndex: 2,
            stationFocusIndex: 3,
            hintText: '到着',
            iconData: KiiteIcons.endPlace,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const PriceFormField(focusIndex: 4),
              const SizedBox(width: 8),
              ElevatedButton(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('申請する'),
                ),
                onPressed: () => {_onSend(context, ref)},
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      );
    });
  }

  Future<void> _onSend(BuildContext context, WidgetRef ref) async {
    showNetworkingCircular(context);

    final viewModel = ref.watch(feeDemandViewModelProvider);
    await viewModel.add(context).whenComplete(() async {
      // final repository = ref.watch(transportFeeRepository);
      // ref.read(futureFeeHistoryList.state).state = repository!.getList();
      viewModel.initialize();
      Navigator.of(context).pop();
    });
  }
}

class DatePickerView extends StatefulWidget {
  const DatePickerView({Key? key}) : super(key: key);

  @override
  DatePickerViewState createState() => DatePickerViewState();
}

class DatePickerViewState extends State<DatePickerView> {
  late FeeDemandViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        viewModel = ref.watch(feeDemandViewModelProvider);

        return Card(
          clipBehavior: Clip.antiAlias,
          borderOnForeground: false,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    KiiteIcons.today,
                    // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('yyyy/MM/dd - E.').format(viewModel.datePicked),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
            onTap: () {
              _selectDate(context, ref);
            },
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: viewModel.datePicked,
        firstDate: DateTime(2022, 1),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      picked = DateTime.utc(picked.year, picked.month, picked.day, 0, 0, 0, 0, 0);
      setState(() => {viewModel.datePicked = picked!});
    }
  }
}

class PlaceFormView extends ConsumerWidget {
  const PlaceFormView(
      {Key? key,
      required this.viewModel,
      required this.titleController,
      required this.stationController,
      required this.titleFocusIndex,
      required this.stationFocusIndex,
      required this.hintText,
      required this.iconData})
      : super(key: key);
  final FeeDemandViewModel viewModel;
  final TextEditingController titleController;
  final TextEditingController stationController;
  final int titleFocusIndex;
  final int stationFocusIndex;
  final String hintText;
  final IconData iconData;

  final iconColumnWidth = 36.0;
  final iconEndMargin = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              width: iconColumnWidth,
              child: Icon(
                iconData,
                // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(width: iconEndMargin),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      focusNode: viewModel.focusNodeList[titleFocusIndex],
                      keyboardType: TextInputType.text,
                      keyboardAppearance:
                          changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
                      maxLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintText,
                      ),
                      style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
                      onEditingComplete: () =>
                          viewModel.focusNodeList[titleFocusIndex + 1].requestFocus(),
                    ),
                    TextFormField(
                      controller: stationController,
                      focusNode: viewModel.focusNodeList[stationFocusIndex],
                      keyboardType: TextInputType.text,
                      keyboardAppearance:
                          changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '駅',
                      ),
                      style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
                      onFieldSubmitted: (value) =>
                          viewModel.focusNodeList[stationFocusIndex + 1].requestFocus(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceFormField extends ConsumerWidget {
  const PriceFormField({Key? key, required this.focusIndex}) : super(key: key);
  final int focusIndex;
  final iconColumnWidth = 36.0;
  final iconEndMargin = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(feeDemandViewModelProvider);
    final changeThemeViewModel = ref.watch(changeThemeViewModelProvider);

    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SizedBox(
                width: iconColumnWidth,
                child: Icon(
                  KiiteIcons.payment,
                  color: Theme.of(context).primaryColor,
                  // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
                ),
              ),
              SizedBox(width: iconEndMargin),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: TextFormField(
                    controller: viewModel.priceController,
                    focusNode: viewModel.focusNodeList[focusIndex],
                    keyboardType: TextInputType.number,
                    keyboardAppearance:
                        changeThemeViewModel.darkMode ? Brightness.dark : Brightness.light,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '金額',
                    ),
                    style: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
