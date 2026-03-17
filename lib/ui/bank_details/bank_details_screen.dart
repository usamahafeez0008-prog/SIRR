import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/bank_details_controller.dart';
import 'package:driver/model/bank_details_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
// import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<BankDetailsController>(
        init: BankDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
            /*appBar: AppBar(
              backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
              elevation: 0,
              centerTitle: true,
              leading: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.moroccoRed, size: 20),
              ),
              title: Text(
                "Bank Details".tr,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : AppColors.moroccoRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),*/
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: isDark)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Bank Information".tr, isDark),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Bank Name".tr, isDark),
                        const SizedBox(height: 8),
                        TextFieldThem.buildTextFiled(context, hintText: 'Enter Bank Name'.tr, controller: controller.bankNameController.value),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Branch Name".tr, isDark),
                        const SizedBox(height: 8),
                        TextFieldThem.buildTextFiled(context, hintText: 'Enter Branch Name'.tr, controller: controller.branchNameController.value),
                        const SizedBox(height: 24),
                        _buildSectionHeader("Account Details".tr, isDark),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Holder Name".tr, isDark),
                        const SizedBox(height: 8),
                        TextFieldThem.buildTextFiled(context, hintText: 'Enter Holder Name'.tr, controller: controller.holderNameController.value),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Account Number".tr, isDark),
                        const SizedBox(height: 8),
                        TextFieldThem.buildTextFiled(context, hintText: 'Enter Account Number'.tr, controller: controller.accountNumberController.value),
                        const SizedBox(height: 24),
                        _buildSectionHeader("Additional Information".tr, isDark),
                        const SizedBox(height: 16),
                        _buildFieldLabel("Other Information".tr, isDark),
                        const SizedBox(height: 8),
                        TextFieldThem.buildTextFiled(context, hintText: 'Optional notes...'.tr, controller: controller.otherInformationController.value),
                        const SizedBox(height: 48),
                        ButtonThem.buildButton(
                          context,
                          title: "Save Changes".tr,
                          textColor: Colors.white,
                          bgColors: AppColors.moroccoGreen,
                          onPress: () async {
                            if (controller.bankNameController.value.text.isEmpty) {
                              ShowToastDialog.showToast("Please enter bank name".tr);
                            } else if (controller.branchNameController.value.text.isEmpty) {
                              ShowToastDialog.showToast("Please enter branch name".tr);
                            } else if (controller.holderNameController.value.text.isEmpty) {
                              ShowToastDialog.showToast("Please enter holder name".tr);
                            } else if (controller.accountNumberController.value.text.isEmpty) {
                              ShowToastDialog.showToast("Please enter account number".tr);
                            } else {
                              ShowToastDialog.showLoader("Saving Details...".tr);
                              BankDetailsModel bankDetailsModel = controller.bankDetailsModel.value;

                              bankDetailsModel.userId = FireStoreUtils.getCurrentUid();
                              bankDetailsModel.bankName = controller.bankNameController.value.text;
                              bankDetailsModel.branchName = controller.branchNameController.value.text;
                              bankDetailsModel.holderName = controller.holderNameController.value.text;
                              bankDetailsModel.accountNumber = controller.accountNumberController.value.text;
                              bankDetailsModel.otherInformation = controller.otherInformationController.value.text;

                              await FireStoreUtils.updateBankDetails(bankDetailsModel).then((value) {
                                ShowToastDialog.closeLoader();
                                ShowToastDialog.showToast("Bank details updated successfully".tr);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          );
        });
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : AppColors.moroccoText.withOpacity(0.7),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.moroccoRed,
      ),
    );
  }
}
