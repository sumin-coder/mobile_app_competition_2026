import 'ui.dart';
import 'my_products.dart';
import 'product_form.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  Widget build(BuildContext context) {
    final state = context.moduleA;
    return AppPage(
      title: '마이페이지',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: AssetIcon(
                  'assets/Common/002. icons/person.png',
                  color: AppColors.onPrimary,
                ),
              ),
              title: Text(state.user.name, style: AppTextStyles.bold),
              subtitle: Text(state.user.email),
            ),
          ),
          vGap12,
          for (final (index, (icon, title, page))
              in <(String, String, Widget?)>[
                (commonIcon('add'), '상품 등록', const AddProductScreen()),
                (
                  moduleIcon('C', 'inventory'),
                  '내 등록 상품',
                  const MyProductsScreen(),
                ),
                for (final (icon, title) in const [
                  ('history', '판매 내역'),
                  ('shopping-bag', '구매 내역'),
                  ('help', '고객센터'),
                  ('info', '앱 정보'),
                ])
                  (moduleIcon('C', icon), title, null),
              ].indexed) ...[
            if (index == 2) const Divider(),
            ListTile(
              leading: AssetIcon(icon),
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => page == null
                  ? context.notify('$title 기능은 준비 중입니다.')
                  : context.openPage(page),
            ),
          ],
          OutlinedButton(
            onPressed: () async {
              if (await confirmAction(
                context,
                title: '로그아웃',
                message: '정말 로그아웃 하시겠습니까?',
                confirmLabel: '로그아웃',
              )) {
                await state.logout();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              shape: const StadiumBorder(),
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
