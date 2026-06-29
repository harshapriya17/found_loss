import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';

class StatusTracker extends StatelessWidget {
  final ItemModel item;

  const StatusTracker({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == 'lost';
    final List<String> statuses = isLost ? ['Lost', 'Matched', 'Returned'] : ['Found', 'Claimed', 'Returned'];

    final currentIdx = statuses.indexOf(item.status);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12.0, bottom: 12.0),
            child: Text(
              'Status Lifecycle',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
          ),
          Row(
            children: List.generate(statuses.length, (index) {
              final stepName = statuses[index];
              final isPassed = index <= currentIdx;
              final isCurrent = index == currentIdx;
              
              Color stepColor;
              if (isCurrent) {
                if (item.status == 'Returned') {
                  stepColor = AppTheme.statusReturned;
                } else if (isLost) {
                  stepColor = AppTheme.statusLost;
                } else {
                  stepColor = AppTheme.statusFound;
                }
              } else if (isPassed) {
                stepColor = AppTheme.primaryColor;
              } else {
                stepColor = Colors.grey[300]!;
              }

              return Expanded(
                child: Row(
                  children: [
                    // Node
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isPassed ? stepColor : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stepColor,
                                width: isPassed ? 0 : 2,
                              ),
                            ),
                            child: Icon(
                              isPassed ? Icons.check : Icons.circle_outlined,
                              size: 14,
                              color: isPassed ? Colors.white : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stepName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? stepColor : (isPassed ? AppTheme.textDark : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Line
                    if (index < statuses.length - 1)
                      Container(
                        width: 30,
                        height: 3,
                        color: index < currentIdx ? AppTheme.primaryColor : Colors.grey[200],
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
