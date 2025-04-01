import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/features/select-users/offline_user_input.dart';
import 'package:receipt_split/features/select-users/select_users_provider.dart';
import 'package:receipt_split/features/select-users/selected_pdf_info.dart';
import 'package:receipt_split/features/select-users/user_list_section.dart';
import 'package:receipt_split/features/splitting/receipt_split_page.dart';
import 'package:receipt_split/widgets/page_layout.dart';
import 'package:receipt_split/widgets/styled_button.dart';

const minRequiredUsers = 2;

class SelectUsersPage extends StatelessWidget {
  const SelectUsersPage({super.key, required this.selectedPdf});

  final String selectedPdf;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SelectUsersProvider(),
      child: Consumer<SelectUsersProvider>(
        builder: (context, provider, _) {
          return (RsLayout(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 15.0,
              children: [
                SelectedPdfInfo(pdf: selectedPdf),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: provider.isOffline
                        ? OfflineUserInput()
                        : UserListSection(provider),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: StyledButton(
                    label: "Split",
                    onTap: () {
                      if (provider.selectedUsers.length < minRequiredUsers) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select at least 2 users"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptSplitPage(
                              pdf: selectedPdf,
                              users: provider.selectedUsers,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
