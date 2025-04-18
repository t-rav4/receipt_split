import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/features/splitting/receipt_items_list.dart';
import 'package:receipt_split/features/splitting/user_chips_select.dart';
import 'package:receipt_split/features/splitting/presentation/split_summary_page.dart';
import 'package:receipt_split/shared/providers/receipt_split_provider.dart';
import 'package:receipt_split/shared/widgets/page_layout.dart';
import 'package:receipt_split/shared/widgets/styled_button.dart';

class ReceiptSplitPage extends StatefulWidget {
  const ReceiptSplitPage({super.key});

  @override
  State<ReceiptSplitPage> createState() => _ReceiptSplitPageState();
}

class _ReceiptSplitPageState extends State<ReceiptSplitPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReceiptSplitProvider>(context, listen: false)
          .loadItemsFromReceiptPdf();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReceiptSplitProvider>(builder: (context, provider, child) {
      return RsLayout(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              "Toggle user select, and split the costs",
              style: TextStyle(fontSize: 16),
            ),
            UserChipsSelect(
              users: provider.userOptions,
              selectedUser: provider.selectedUser,
              onChipSelect: (user) => provider.handleUserSelection(user),
            ),
            Expanded(
              child: provider.isExtractingText
                  ? const Center(child: CircularProgressIndicator())
                  : ReceiptItemsList(
                      items: provider.receiptItems,
                      onItemSelect: provider.toggleItem,
                    ),
            ),
            // TODO: improve design here
            Padding(
              padding: EdgeInsets.only(top: 18),
              child: SizedBox(
                child: Column(
                  children: provider.userCosts.entries.map((entry) {
                    final user = entry.key;
                    final cost = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(user.name),
                        Text("\$ ${cost.toStringAsFixed(2)}"),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Text(
              "Total shared cost split: \$ ${provider.totalSharedCostSplitBetweenUsers.toStringAsFixed(2)}",
            ),
            Text(
              "Total cost: \$ ${provider.totalCost.toStringAsFixed(2)}",
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StyledButton(
                    label: "Go to Summary",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplitSummaryPage(
                            users: provider.userOptions,
                            userCosts: provider.userCosts,
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ],
        ),
      );
    });
  }
}
