import '../module_a/product_detail.dart';
import 'ui.dart';
import 'product_form.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.moduleC.refreshMyProducts(),
    );
  }

  Widget build(BuildContext context) {
    final state = context.moduleC;
    return RefreshPage(
      title: '내 등록 상품',
      status: state.myProductStatus,
      items: state.myProducts,
      error: state.myProductError ?? '내 상품을 불러오지 못했습니다.',
      refresh: state.refreshMyProducts,
      scrollLoading: false,
      actions: [
        IconButton(
          onPressed: () => context.openPage(const AddProductScreen()),
          icon: const Icon(Icons.add),
        ),
      ],
      empty: EmptyState(
        icon: Icons.inventory_2,
        title: '등록된 상품이 없습니다.',
        subtitle: '오른쪽 위 + 버튼으로 상품을 등록해보세요.',
      ),
      content: (items) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, _) => vGap8,
        itemBuilder: (_, index) => _item(context, state, items[index]),
      ),
    );
  }

  Widget _item(BuildContext context, ModuleCState state, Product item) =>
      ProductListCard(
        product: item,
        onTap: () => openProductDetail(context, item.id),
        details: Row(
          children: [
            InfoBadge(item.condition),
            hGap8,
            Text(formatWon(item.price), style: AppTextStyles.price),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => context.notify('상품 수정 기능은 준비 중입니다.'),
              icon: AssetIcon(moduleIcon('C', 'edit')),
            ),
            IconButton(
              key: Key('delete_product_${item.id}'),
              onPressed: () => remove(context, state, item),
              icon: const Icon(Icons.delete, color: AppColors.danger),
            ),
          ],
        ),
      );

  Future<void> remove(
    BuildContext context,
    ModuleCState state,
    Product item,
  ) async {
    final guard = context.guard;
    if (!await confirmAction(
      context,
      title: '상품 삭제',
      message: '${item.albumName}을(를) 삭제하시겠습니까?',
      confirmLabel: '삭제',
    )) {
      return;
    }
    if (await guard(() => state.deleteProduct(item.id)) && context.mounted) {
      context.notify('상품이 삭제되었습니다.');
    }
  }
}
