import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/features/select_users/offline_user_input.dart';
import 'package:receipt_split/features/select_users/selected_pdf_info.dart';
import 'package:receipt_split/features/select_users/user_list_section.dart';
import 'package:receipt_split/features/splitting/presentation/receipt_split_page.dart';
import 'package:receipt_split/shared/providers/offline_provider.dart';
import 'package:receipt_split/shared/providers/receipt_split_provider.dart';
import 'package:receipt_split/shared/widgets/page_layout.dart';
import 'package:receipt_split/shared/widgets/styled_button.dart';

const minRequiredUsers = 2;

class SelectUsersPage extends StatelessWidget {
  const SelectUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    var offlineProvider = Provider.of<OfflineProvider>(context);
    var rsProvider = Provider.of<ReceiptSplitProvider>(context);

    return (RsLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 15.0,
        children: [
          SelectedPdfInfo(pdf: rsProvider.selectedPdf.path),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: offlineProvider.isOffline
                  ? OfflineUserInput(
                      userOptions: rsProvider.userOptions,
                      selectedIds:
                          rsProvider.selectedUsers.map((u) => u.id).toList(),
                      onUserAdded: (user) => rsProvider.addUserOption(user),
                      onUserRemoved: (user) => rsProvider.removeUserOption(user),
                      onUserToggleSelect: (user) => rsProvider.toggleUserSelect(user),
                    )
                  : UserListSection(),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: StyledButton(
              label: "Split",
              onTap: () {
                if (rsProvider.selectedUsers.length < minRequiredUsers) {
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
                      builder: (context) => ReceiptSplitPage(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ));
  }
}
