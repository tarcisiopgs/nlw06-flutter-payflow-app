import 'package:payflow/modules/barcode_scanner/barcode_scanner_controller.dart';
import 'package:payflow/modules/barcode_scanner/barcode_scanner_status.dart';
import 'package:payflow/shared/widgets/buttons/set_label_buttons.dart';
import 'package:payflow/shared/widgets/custom_bottom_sheet.dart';
import 'package:payflow/shared/themes/app_text_styles.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:flutter/material.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({Key? key}) : super(key: key);

  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final barcodeScannerController = BarcodeScannerController();

  @override
  void initState() {
    barcodeScannerController.getAvailableCameras();
    barcodeScannerController.statusNotifier.addListener(() {
      if (barcodeScannerController.status.hasBarcode) {
        Navigator.pushReplacementNamed(context, '/insert_boleto');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    barcodeScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          ValueListenableBuilder<BarcodeScannerStatus>(
              valueListenable: barcodeScannerController.statusNotifier,
              builder: (_, status, __) {
                if (status.showCamera) {
                  return Container(
                    child: status.cameraController!.buildPreview(),
                  );
                } else {
                  return Container();
                }
              }),
          RotatedBox(
            quarterTurns: 1,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.black,
                centerTitle: true,
                title: Text(
                  'Escaneie o código de barras do boleto',
                  style: AppTextStyles.buttonBackground,
                ),
                leading: BackButton(
                  color: AppColors.background,
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: Row(
                        children: [],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: Row(
                        children: [],
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar: SetLabelButtons(
                primaryLabel: 'Inserir código do boleto',
                primaryOnPressed: () {},
                secondaryLabel: 'Adicionar da galeria',
                secondaryOnPressed: () {},
              ),
            ),
          ),
          ValueListenableBuilder<BarcodeScannerStatus>(
              valueListenable: barcodeScannerController.statusNotifier,
              builder: (_, status, __) {
                if (status.hasError) {
                  return CustomBottomSheet(
                      primaryLabel: 'Escanear novamente',
                      secondaryLabel: 'Digitar código',
                      primaryOnPressed: () {
                        barcodeScannerController.getAvailableCameras();
                      },
                      secondaryOnPressed: () {},
                      title:
                          'Não foi possível identificar um código de barras.',
                      subtitle:
                          'Tente escanear novamente ou digite o código do seu boleto.');
                } else {
                  return Container();
                }
              }),
        ],
      ),
    );
  }
}
