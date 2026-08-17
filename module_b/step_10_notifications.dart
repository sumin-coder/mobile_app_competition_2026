import '../module_a/step_09_product_detail.dart';
import 'step_07_ui.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  Widget build(BuildContext context) {
    final state = context.moduleB;
    return RefreshPage(
      title: '알림',
      status: state.notificationStatus,
      items: state.notifications,
      error: state.notificationError ?? '알림을 불러오지 못했습니다.',
      refresh: state.refreshNotifications,
      actions: [
        PopupMenuButton<String>(
          onSelected: (v) => _action(context, v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'read', child: Text('모두 읽음')),
            PopupMenuItem(
              value: 'delete',
              child: Text('전체 삭제', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ],
      empty: EmptyState(
        icon: Icons.notifications_none,
        title: '알림이 없습니다.',
        subtitle: '관심 상품의 가격이 변경되면 알려드릴게요.',
      ),
      content: (items) => ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) => _tile(context, items[i]),
      ),
    );
  }

  Future<void> _action(BuildContext context, String value) async {
    final state = context.moduleB;
    await context.guard(() async {
      await switch (value) {
        'read' => state.markAllNotificationsRead(),
        _
            when await confirmAction(
              context,
              title: '알림 전체 삭제',
              message: '모든 알림을 삭제하시겠습니까?',
              confirmLabel: '삭제',
            ) =>
          state.deleteAllNotifications(),
        _ => Future.value(),
      };
    });
  }

  Widget _tile(BuildContext context, PriceNotification n) {
    final down = n.currentPrice < n.previousPrice;
    return InkWell(
      onTap: () async {
        await context.guard(() async {
          await context.moduleB.markNotificationRead(n.id);
          if (context.mounted) await openProductDetail(context, n.productId);
        });
      },
      child: Container(
        color: n.isRead ? null : AppColors.primary.withValues(alpha: .05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(dimension: 60, child: _image(n)),
            ),
            hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    down ? '↓ 가격 인하' : '↑ 가격 인상',
                    style: TextStyle(
                      color: down ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  vGap4,
                  singleLine('${n.albumName} - ${n.artist}'),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        formatWon(n.previousPrice),
                        style: AppTextStyles.caption.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Text('  →  ', style: AppTextStyles.caption),
                      Text(
                        formatWon(n.currentPrice),
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(_ago(n.createdAt), style: AppTextStyles.caption),
                if (!n.isRead)
                  const CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primary,
                  ).pad(const EdgeInsets.only(top: 6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(PriceNotification notice) =>
      AlbumImage(path: notice.albumImage, name: notice.albumName);
  String _ago(DateTime at) => switch (DateTime.now().difference(at)) {
    final d when d.inMinutes < 60 => '${d.inMinutes.clamp(1, 59)}분 전',
    final d when d.inHours < 24 => '${d.inHours}시간 전',
    final d => '${d.inDays}일 전',
  };
}
