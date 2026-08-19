// 로그인·회원가입 화면과 입력값 검증 규칙을 구현합니다.

import 'step_07_ui.dart';

// 인증 폼의 이메일, 비밀번호, 이름 검증에 사용하는 규칙입니다.
final _emailPattern = RegExp(r'^(?!.*\.@)[^@\s]+@[^@\s]+\.[^@\s]+$');
final _upperCasePattern = RegExp('[A-Z]'), _lowerCasePattern = RegExp('[a-z]');
final _strongPasswordPattern = RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
);
final _namePattern = RegExp(r'^[가-힣A-Za-z ]+$');
bool _email(String value) => _emailPattern.hasMatch(value);
String? _loginEmailError(String? value) {
  final email = value?.trim() ?? '';
  return email.isEmpty
      ? '이메일을 입력해주세요.'
      : (_email(email) ? null : '올바른 이메일 형식을 입력해주세요.');
}

String? _loginPasswordError(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return '비밀번호를 입력해주세요.';
  if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
  return _upperCasePattern.hasMatch(password) &&
          _lowerCasePattern.hasMatch(password)
      ? null
      : '비밀번호는 대문자와 소문자를 각 1개 이상 포함해야 합니다.';
}

final _mail = AssetIcon(moduleIcon('A', 'email')).padAll(14);

// 로그인과 회원가입 화면이 공유하는 배경·로고 레이아웃입니다.
Widget _AuthFrame(
  BuildContext context, {
  required Widget child,
  bool back = false,
}) => Scaffold(
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          'assets/Common/003. images/background.png',
          alignment: Alignment.topCenter,
          fit: BoxFit.cover,
        ),
      ),
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: const Alignment(0, .35),
              colors: [Colors.black.withValues(alpha: .25), Colors.black],
            ),
          ),
        ),
      ),
      Stack(
        children: [
          child,
          if (back)
            IconButton(
              onPressed: context.closePage,
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
        ],
      ).safe(),
    ],
  ),
);

Widget _AuthHeader(
  String title,
  String subtitle, {
  required double logoHeight,
  required double gap,
  double titleGap = 8,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    BrandLogo(height: logoHeight, centered: true),
    const Text(
      'Vinyl Record Secondhand Marketplace',
      textAlign: TextAlign.center,
      style: AppTextStyles.caption,
    ),
    SizedBox(height: gap),
    Text(title, style: AppTextStyles.authTitle),
    SizedBox(height: titleGap),
    Text(subtitle, style: AppTextStyles.caption),
  ],
);

// 이메일과 비밀번호를 받아 Module A 로그인 상태를 갱신합니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool hidden = true;
  void dispose() {
    disposeControllers([email, password]);
    super.dispose();
  }

  Future<void> login() async {
    if (!(form.currentState?.validate() ?? false)) return;
    await context.guard(
      () => context.moduleA.login(email.text.trim(), password.text),
    );
  }

  Widget build(BuildContext context) {
    final state = context.moduleA;
    final compact = context.screenSize.height < 700;
    return _AuthFrame(
      context,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, compact ? 18 : 90, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthHeader(
              '로그인',
              '계정으로 로그인하여 다양한 서비스를 이용하세요.',
              logoHeight: compact ? 85 : 170,
              gap: compact ? 18 : 55,
            ),
            SizedBox(height: compact ? 14 : 28),
            Form(
              key: form,
              child: Column(
                children: [
                  AppField(
                    fieldKey: const Key('login_email'),
                    controller: email,
                    hint: '이메일을 입력해주세요.',
                    prefix: _mail,
                    keyboardType: TextInputType.emailAddress,
                    validator: _loginEmailError,
                  ),
                  vGap14,
                  PasswordField(
                    fieldKey: const Key('login_password'),
                    controller: password,
                    hint: '비밀번호를 입력해주세요.',
                    obscure: hidden,
                    onToggle: () => setState(() => hidden = !hidden),
                    action: TextInputAction.done,
                    onSubmitted: (_) => login(),
                    validator: _loginPasswordError,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.notify('비밀번호 찾기 기능은 준비 중입니다.'),
                child: const Text('비밀번호를 잊으셨나요?'),
              ),
            ),
            SizedBox(height: compact ? 4 : 22),
            SubmitButton(
              key: const Key('login_button'),
              label: '로그인',
              busy: state.isAuthenticating,
              onPressed: login,
            ),
            vGap26,
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('또는', style: AppTextStyles.caption),
                ),
                Expanded(child: Divider()),
              ],
            ),
            vGap20,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('계정이 없으신가요?', style: AppTextStyles.caption),
                TextButton(
                  onPressed: () => context.openPage(const SignupScreen()),
                  child: const Text('회원가입', style: AppTextStyles.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 사용자 정보를 검증해 계정을 생성하는 회원가입 화면입니다.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController(),
      name = TextEditingController();
  final phone = List.generate(3, (_) => TextEditingController());
  bool passwordHidden = true,
      confirmHidden = true,
      agreed = false,
      busy = false;
  void dispose() {
    disposeControllers([email, password, confirm, name, ...phone]);
    super.dispose();
  }

  Future<void> signup() async {
    if (!(form.currentState?.validate() ?? false))
      return context.notify('입력 항목을 올바르게 확인해주세요.');
    if (!agreed) return context.notify('이용약관 및 개인정보처리방침에 동의해주세요.');
    setState(() => busy = true);
    try {
      final success = await context.guard(
        () => context.moduleA.signup((
          email: email.text.trim(),
          password: password.text,
          name: name.text.trim(),
          phone: phone.map((field) => field.text).join('-'),
        )),
      );
      if (success && mounted) {
        context.notify('회원가입이 완료되었습니다.');
        context.closePage();
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget build(BuildContext context) => _AuthFrame(
    context,
    back: true,
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 70, 24, 35),
        children: [
          _AuthHeader(
            '회원가입',
            '회원 정보를 입력하여 계정을 만들어주세요.',
            logoHeight: 145,
            gap: 34,
            titleGap: 0,
          ),
          const SizedBox(height: 24),
          _field(
            '이메일',
            AppField(
              controller: email,
              hint: '이메일을 입력해주세요.',
              prefix: _mail,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  _email(v?.trim() ?? '') ? null : '올바른 이메일 형식을 입력해주세요.',
            ),
          ),
          _field(
            '비밀번호',
            PasswordField(
              controller: password,
              hint: '비밀번호를 입력해주세요.',
              obscure: passwordHidden,
              onToggle: () => setState(() => passwordHidden = !passwordHidden),
              validator: (v) => _strongPasswordPattern.hasMatch(v ?? '')
                  ? null
                  : '8자 이상, 대소문자, 숫자, 특수문자를 포함해주세요.',
            ),
            hint: '* 8자 이상, 대소문자, 숫자, 특수문자 포함',
          ),
          _field(
            '비밀번호 확인',
            PasswordField(
              controller: confirm,
              hint: '비밀번호를 다시 입력해주세요.',
              obscure: confirmHidden,
              onToggle: () => setState(() => confirmHidden = !confirmHidden),
              validator: (v) => v == password.text ? null : '비밀번호가 일치하지 않습니다.',
            ),
          ),
          _field(
            '이름',
            AppField(
              controller: name,
              hint: '이름을 입력해주세요.',
              icon: Icons.person_outline,
              validator: (v) => _namePattern.hasMatch(v?.trim() ?? '')
                  ? null
                  : '이름은 한글 또는 영문만 입력해주세요.',
            ),
          ),
          _requiredLabel('휴대폰 번호'),
          vGap8,
          Row(
            children: [
              for (final (index, length, hint) in const [
                (0, 3, '010'),
                (1, 4, '1234'),
                (2, 4, '5678'),
              ]) ...[
                if (index > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text('-'),
                  ),
                Expanded(
                  child: TextFormField(
                    controller: phone[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits(length),
                    onChanged: (value) {
                      if (index < 2 && value.length == length)
                        FocusScope.of(context).nextFocus();
                    },
                    decoration: AppDecor.input(hint),
                    validator: (value) =>
                        value?.length == length ? null : '번호 확인',
                  ),
                ),
              ],
            ],
          ),
          vGap20,
          CheckboxListTile(
            value: agreed,
            onChanged: (v) => setState(() => agreed = v ?? false),
            title: const Text(
              '이용약관 및 개인정보처리방침에 동의합니다.',
              style: AppTextStyles.caption,
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          SubmitButton(label: '회원가입', busy: busy, onPressed: signup),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('이미 계정이 있으신가요?', style: AppTextStyles.caption),
              TextButton(
                onPressed: context.closePage,
                child: const Text('로그인'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget _field(String label, Widget field, {String? hint}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _requiredLabel(label),
      vGap8,
      field,
      if (hint != null)
        Text(
          hint,
          style: AppTextStyles.caption,
        ).pad(const EdgeInsets.only(top: 6)),
    ],
  ).pad(const EdgeInsets.only(bottom: 18));
  Widget _requiredLabel(String label) => Text.rich(
    TextSpan(
      text: label,
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: AppColors.danger),
        ),
      ],
    ),
    style: AppTextStyles.bold,
  );
}
