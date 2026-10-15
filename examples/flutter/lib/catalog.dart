import 'package:fluent2_flutter/fluent2_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FluentCatalog extends StatefulWidget {
  const FluentCatalog({super.key});
  @override
  State<FluentCatalog> createState() => _FluentCatalogState();
}

class _FluentCatalogState extends State<FluentCatalog> {
  bool dark = false, compact = false, teams = false;
  @override
  Widget build(BuildContext context) {
    final tokens = dark
        ? (teams ? FluentTokens.teamsDark : FluentTokens.dark)
        : (teams ? FluentTokens.teamsLight : FluentTokens.light);
    final theme = FluentThemeData(
      tokens: tokens,
      size: compact ? FluentSize.small : FluentSize.middle,
    );
    return MaterialApp(
      title: 'Fluent 2 Native · Flutter',
      debugShowCheckedModeBanner: false,
      theme: theme.materialTheme,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: FluentTheme(
          data: theme.copyWith(
            minimumTouchTarget: MediaQuery.sizeOf(context).width < 700 ? 44 : 0,
          ),
          child: child!,
        ),
      ),
      home: _CatalogScreen(
        dark: dark,
        teams: teams,
        onTeams: () => setState(() => teams = !teams),
        compact: compact,
        onDark: () => setState(() => dark = !dark),
        onCompact: (value) => setState(() => compact = value),
      ),
    );
  }
}

const _categories = [
  'All components',
  'General',
  'Data entry',
  'Navigation',
  'Data display',
  'Feedback',
];

class _CatalogScreen extends StatefulWidget {
  const _CatalogScreen({
    required this.dark,
    required this.teams,
    required this.onTeams,
    required this.compact,
    required this.onDark,
    required this.onCompact,
  });
  final bool dark, compact, teams;
  final VoidCallback onDark, onTeams;
  final ValueChanged<bool> onCompact;
  @override
  State<_CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<_CatalogScreen> {
  final _search = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  Set<String> expanded = {"design"};
  String location = "Components";
  final _scroll = ScrollController();
  String category = 'All components',
      query = '',
      role = 'designer',
      period = 'Week',
      tab = 'Overview',
      radio = 'Design';
  String? message;
  bool? checked;
  bool notifications = true,
      loading = false,
      validated = false,
      alertVisible = true,
      skeleton = true,
      created = false;
  int count = 5;
  double percent = 62;

  @override
  void dispose() {
    _search.dispose();
    _email.dispose();
    _notes.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _category(String value) {
    setState(() {
      category = value;
      query = '';
      _search.clear();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _runTask() async {
    setState(() {
      loading = true;
      message = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        loading = false;
        message = 'Project created. You’re ready to build.';
      });
    }
  }

  Future<void> _openModal() async {
    final confirmed = await showFluentDialog(
      context: context,
      title: 'Create a workspace?',
      confirmText: 'Create workspace',
      builder: (context) => const FluentText(
        'Your new workspace will use the shared Fluent 2 theme. You can change its settings any time.',
      ),
      onConfirm: () => Future<void>.delayed(const Duration(milliseconds: 700)),
    );
    if (mounted && confirmed) setState(() => created = true);
  }

  List<_Demo> _demos() {
    final emailError =
        validated &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text);
    return [
      _Demo(
        'Button',
        'General',
        'A clear action for every level of emphasis.',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FluentStack(
              children: [
                FluentButton(
                  type: FluentButtonType.primary,
                  icon: FluentIconType.plus,
                  loading: loading,
                  onPressed: _runTask,
                  child: const FluentText('Create project'),
                ),
                FluentButton(
                  onPressed: () =>
                      setState(() => message = 'Secondary action selected.'),
                  child: const FluentText('Secondary'),
                ),
                FluentButton(
                  type: FluentButtonType.outline,
                  onPressed: () =>
                      setState(() => message = 'Outline action selected.'),
                  child: const FluentText('Outline'),
                ),
                FluentButton(
                  type: FluentButtonType.subtle,
                  onPressed: () =>
                      setState(() => message = 'Subtle action selected.'),
                  child: const FluentText('Subtle'),
                ),
                FluentButton(
                  type: FluentButtonType.transparent,
                  onPressed: () =>
                      setState(() => message = 'Transparent action selected.'),
                  child: const FluentText('Transparent'),
                ),
                FluentButton(
                  danger: true,
                  onPressed: () =>
                      setState(() => message = 'Danger action selected.'),
                  child: const FluentText('Danger'),
                ),
                const FluentButton(child: FluentText('Disabled')),
              ],
            ),
            const FluentDivider(),
            FluentStack(
              children: [
                for (final size in FluentSize.values)
                  FluentButton(
                    size: size,
                    onPressed: () => setState(
                      () => message = '${size.name} button pressed.',
                    ),
                    child: FluentText(size.name),
                  ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              FluentMessageBar(
                message: message!,
                type: FluentStatus.success,
                onClose: () => setState(() => message = null),
              ),
            ],
          ],
        ),
      ),
      const _Demo(
        'Typography',
        'General',
        'A familiar hierarchy, with native text rendering.',
        FluentStack(
          vertical: true,
          gap: 8,
          children: [
            FluentTitle('Good design feels familiar.', level: 4),
            FluentText(
              'Build a consistent experience with considered defaults.',
            ),
            FluentText(
              'Secondary text supports the main story.',
              type: FluentTextType.secondary,
            ),
            FluentStack(
              children: [
                FluentText('Success', type: FluentTextType.success),
                FluentText('Warning', type: FluentTextType.warning),
                FluentText('Error', type: FluentTextType.danger),
              ],
            ),
            FluentStack(
              children: [
                FluentText('Semibold', strong: true),
                FluentText('Underlined', underline: true),
                FluentText('FluentTheme', code: true),
              ],
            ),
          ],
        ),
      ),
      _Demo(
        'Icon',
        'General',
        '26 official Fluent 2 vectors, shared across runtimes.',
        FluentStack(
          gap: 20,
          children: [
            for (final icon in FluentIconType.values)
              Tooltip(
                message: icon.name,
                child: FluentIcon(icon, size: 22, semanticLabel: icon.name),
              ),
          ],
        ),
      ),
      _Demo(
        'Input & Field',
        'Data entry',
        'Clear labels, helpful feedback, and platform text editing.',
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FluentField(
              label: 'Email address',
              required: true,
              status: emailError ? FluentStatus.error : FluentStatus.none,
              help: emailError
                  ? 'Enter a valid email address.'
                  : validated
                  ? 'Email looks good.'
                  : 'We’ll use this for workspace updates.',
              child: FluentInput(
                controller: _email,
                label: 'Email address',
                placeholder: 'you@example.com',
                allowClear: true,
                status: emailError ? FluentStatus.error : FluentStatus.none,
                errorMessage: emailError
                    ? 'Enter a valid email address.'
                    : null,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            const FluentInput(
              label: 'Password',
              placeholder: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FluentButton(
                type: FluentButtonType.primary,
                onPressed: () => setState(() => validated = true),
                child: const FluentText('Validate'),
              ),
            ),
          ],
        ),
      ),
      _Demo(
        'Checkbox & Radio',
        'Data entry',
        'Controlled values with clear selected and mixed states.',
        FluentStack(
          vertical: true,
          gap: 12,
          children: [
            FluentCheckbox(
              value: checked,
              label: 'Select all components',
              onChanged: (value) => setState(() => checked = value),
            ),
            const FluentCheckbox(value: true, label: 'Disabled selection'),
            FluentStack(
              gap: 20,
              children: [
                for (final item in ['Design', 'Develop'])
                  FluentRadio(
                    value: item,
                    groupValue: radio,
                    label: item,
                    onChanged: (value) => setState(() => radio = value),
                  ),
              ],
            ),
            FluentText('Selected: $radio', type: FluentTextType.secondary),
          ],
        ),
      ),
      _Demo(
        'Switch',
        'Data entry',
        'A small control for an immediate change.',
        FluentStack(
          vertical: true,
          gap: 12,
          children: [
            FluentStack(
              children: [
                FluentSwitch(
                  value: notifications,
                  label: 'Notifications',
                  onChanged: (value) => setState(() => notifications = value),
                ),
                FluentText('Notifications ${notifications ? 'on' : 'off'}'),
              ],
            ),
            FluentStack(
              gap: 20,
              children: [
                FluentSwitch(
                  value: notifications,
                  size: FluentSize.small,
                  label: 'Small notifications switch',
                  onChanged: (value) => setState(() => notifications = value),
                ),
                const FluentSwitch(
                  value: true,
                  loading: true,
                  label: 'Loading switch',
                ),
                const FluentSwitch(value: false, label: 'Disabled switch'),
              ],
            ),
          ],
        ),
      ),
      _Demo(
        'Dropdown',
        'Data entry',
        'Single selection with keyboard navigation and disabled options.',
        FluentStack(
          vertical: true,
          gap: 12,
          children: [
            FluentDropdown(
              value: role,
              label: 'Workspace role',
              options: const [
                FluentOption('designer', 'Designer'),
                FluentOption('developer', 'Developer'),
                FluentOption('viewer', 'Viewer'),
                FluentOption('archived', 'Archived role', enabled: false),
              ],
              onChanged: (value) => setState(() => role = value),
            ),
            FluentText('Current role: $role', type: FluentTextType.secondary),
          ],
        ),
      ),
      _Demo(
        'TabList',
        'Navigation',
        'Move between views without losing your place.',
        FluentStack(
          vertical: true,
          gap: 16,
          children: [
            FluentToggleGroup(
              value: period,
              options: const [
                FluentOption('Day', 'Day'),
                FluentOption('Week', 'Week'),
                FluentOption('Month', 'Month'),
              ],
              onChanged: (value) => setState(() => period = value),
            ),
            FluentTabList(
              value: tab,
              options: const [
                FluentOption('Overview', 'Overview'),
                FluentOption('Activity', 'Activity'),
                FluentOption('Settings', 'Settings', enabled: false),
              ],
              onChanged: (value) => setState(() => tab = value),
              builder: (context, value) => FluentText(
                value == 'Overview'
                    ? 'Your $period overview is ready.'
                    : 'Your recent workspace activity appears here.',
              ),
            ),
          ],
        ),
      ),
      const _Demo(
        'Card & Statistic',
        'Data display',
        'Give related information a place of its own.',
        FluentCard(
          title: 'Workspace overview',
          size: FluentSize.small,
          extra: FluentBadge('Live', status: FluentStatus.success),
          child: FluentStack(
            gap: 40,
            children: [
              FluentStatistic(title: 'Active projects', value: '24'),
              FluentStatistic(title: 'Completion', value: '93', suffix: '%'),
            ],
          ),
        ),
      ),
      _Demo(
        'Avatar & CounterBadge',
        'Data display',
        'Identity and updates, at a glance.',
        FluentStack(
          vertical: true,
          gap: 20,
          children: [
            FluentStack(
              gap: 24,
              children: [
                FluentCounterBadge(
                  count: count,
                  child: const FluentAvatar(text: 'FA', label: 'Fajar'),
                ),
                const FluentCounterBadge(
                  dot: true,
                  child: FluentAvatar(square: true),
                ),
                const FluentAvatar(text: 'FL', size: 48),
                const FluentAvatar(size: 32),
              ],
            ),
            FluentStack(
              children: [
                FluentButton(
                  onPressed: () => setState(() => count++),
                  icon: FluentIconType.plus,
                  child: const FluentText('Add'),
                ),
                FluentButton(
                  onPressed: () => setState(() => count = 0),
                  child: const FluentText('Clear notifications'),
                ),
              ],
            ),
          ],
        ),
      ),
      _Demo(
        'Badge',
        'Data display',
        'Compact labels for status and categorization.',
        FluentStack(
          children: [
            const FluentBadge('Default'),
            const FluentBadge(
              'Processing',
              status: FluentStatus.info,
              icon: FluentIconType.loading,
            ),
            const FluentBadge(
              'Success',
              status: FluentStatus.success,
              icon: FluentIconType.check,
            ),
            const FluentBadge('Warning', status: FluentStatus.warning),
            const FluentBadge('Error', status: FluentStatus.error),
            const FluentBadge(
              'Outline',
              status: FluentStatus.info,
              appearance: FluentBadgeAppearance.outline,
            ),
          ],
        ),
      ),
      const _Demo(
        'Stack & Divider',
        'Data display',
        'Consistent rhythm, built on the four-point grid.',
        Column(
          children: [
            FluentStack(
              gap: 16,
              children: [
                FluentBadge('First'),
                FluentBadge('Second'),
                FluentBadge('Third'),
              ],
            ),
            FluentDivider(text: 'A little breathing room'),
            FluentText(
              'Spacing is part of the system.',
              type: FluentTextType.secondary,
            ),
          ],
        ),
      ),
      _Demo(
        'MessageBar',
        'Feedback',
        'Give timely, contextual feedback.',
        FluentStack(
          vertical: true,
          gap: 12,
          children: [
            const FluentMessageBar(
              message: 'Your changes are saved.',
              type: FluentStatus.success,
            ),
            const FluentMessageBar(
              message: 'A new version is available.',
              type: FluentStatus.info,
            ),
            const FluentMessageBar(
              message: 'Your trial ends in 3 days.',
              type: FluentStatus.warning,
            ),
            if (alertVisible)
              FluentMessageBar(
                message: 'Couldn’t connect.',
                description: 'Check your connection and try again.',
                type: FluentStatus.error,
                onClose: () => setState(() => alertVisible = false),
              )
            else
              FluentButton(
                type: FluentButtonType.transparent,
                onPressed: () => setState(() => alertVisible = true),
                child: const FluentText('Restore alert'),
              ),
          ],
        ),
      ),
      _Demo(
        'ProgressBar',
        'Feedback',
        'Make progress visible, from the first step to done.',
        FluentStack(
          vertical: true,
          gap: 16,
          children: [
            FluentProgressBar(percent: percent),
            const FluentProgressBar(percent: 100),
            FluentStack(
              gap: 20,
              children: [
                FluentProgressBar(
                  percent: percent,
                  type: FluentProgressType.circle,
                ),
                FluentButton(
                  onPressed: () =>
                      setState(() => percent = (percent - 10).clamp(0, 100)),
                  semanticLabel: 'Decrease progress',
                  child: const FluentIcon(FluentIconType.minus),
                ),
                FluentButton(
                  onPressed: () =>
                      setState(() => percent = (percent + 10).clamp(0, 100)),
                  semanticLabel: 'Increase progress',
                  child: const FluentIcon(FluentIconType.plus),
                ),
              ],
            ),
          ],
        ),
      ),
      _Demo(
        'Spinner & Skeleton',
        'Feedback',
        'Considered loading states while content is on its way.',
        FluentStack(
          vertical: true,
          gap: 20,
          children: [
            const FluentStack(
              gap: 16,
              children: [
                FluentSpinner(size: 16),
                FluentSpinner(size: 24),
                FluentSpinner(size: 32),
                FluentText(
                  'Loading workspace…',
                  type: FluentTextType.secondary,
                ),
              ],
            ),
            if (skeleton)
              const FluentSkeleton(avatar: true)
            else
              const FluentMessageBar(
                message: 'Content is ready.',
                type: FluentStatus.success,
              ),
            FluentButton(
              onPressed: () => setState(() => skeleton = !skeleton),
              child: FluentText(skeleton ? 'Finish loading' : 'Show skeleton'),
            ),
          ],
        ),
      ),
      _Demo(
        'Textarea',
        'Data entry',
        'Room for a longer thought, with native text editing.',
        FluentField(
          label: 'Project notes',
          help: '${_notes.text.length} characters',
          child: FluentTextarea(
            controller: _notes,
            label: 'Project notes',
            placeholder: 'What are you building?',
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      _Demo(
        'Accordion',
        'Data display',
        'Reveal one section at a time. Use arrow keys between headers.',
        FluentAccordion(
          items: const [
            FluentAccordionItem(
              id: 'design',
              title: 'Designed for clarity',
              child: FluentText(
                'Fluent brings color, typography, depth and motion into one consistent system.',
              ),
            ),
            FluentAccordionItem(
              id: 'native',
              title: 'Built for your platform',
              child: FluentText(
                'Compose and Flutter render these components with their native UI toolkits.',
              ),
            ),
            FluentAccordionItem(
              id: 'soon',
              title: 'More patterns soon',
              enabled: false,
              child: SizedBox.shrink(),
            ),
          ],
          expanded: expanded,
          onChanged: (value) => setState(() => expanded = value),
        ),
      ),
      _Demo(
        'Breadcrumb & Link',
        'Navigation',
        'Show where you are and offer a clear way back.',
        FluentStack(
          vertical: true,
          children: [
            FluentBreadcrumb(
              items: [
                const FluentBreadcrumbItem('home', 'Home'),
                const FluentBreadcrumbItem('library', 'Library'),
                FluentBreadcrumbItem('components', location),
              ],
              onNavigate: (value) => setState(
                () => location = value == 'home' ? 'Home' : 'Library',
              ),
            ),
            FluentLink(
              'Explore component guidance',
              onPressed: () => setState(() => location = 'Guidance'),
            ),
            FluentText(
              'Current page: $location',
              type: FluentTextType.secondary,
            ),
          ],
        ),
      ),
      _Demo(
        'Dialog',
        'Feedback',
        'Useful empty states and focused confirmation dialogs.',
        created
            ? FluentStack(
                vertical: true,
                children: [
                  const FluentMessageBar(
                    message: 'Workspace created.',
                    type: FluentStatus.success,
                  ),
                  FluentButton(
                    onPressed: () => setState(() => created = false),
                    child: const FluentText('Reset demo'),
                  ),
                ],
              )
            : FluentEmptyState(
                description: 'Your next idea starts here.',
                action: FluentButton(
                  type: FluentButtonType.primary,
                  icon: FluentIconType.plus,
                  onPressed: _openModal,
                  child: const FluentText('New workspace'),
                ),
              ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    final demos = _demos()
        .where(
          (demo) =>
              (category == 'All components' || category == demo.group) &&
              '${demo.title} ${demo.description}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: t.colorNeutralBackground1,
                    border: Border(
                      bottom: BorderSide(color: t.colorNeutralStroke2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: t.colorBrandBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: FluentIcon(
                            FluentIconType.grid,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: FluentText(
                          'Fluent 2',
                          strong: true,
                          maxLines: 1,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      FluentButton(
                        type: FluentButtonType.subtle,
                        semanticLabel: widget.teams
                            ? 'Switch to Web theme'
                            : 'Switch to Teams theme',
                        onPressed: widget.onTeams,
                        child: FluentText(widget.teams ? 'Teams' : 'Web'),
                      ),
                      const FluentBadge('Flutter', status: FluentStatus.info),
                      const SizedBox(width: 8),
                      FluentButton(
                        type: FluentButtonType.subtle,
                        semanticLabel: widget.dark
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                        onPressed: widget.onDark,
                        child: FluentIcon(
                          widget.dark
                              ? FluentIconType.sun
                              : FluentIconType.moon,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (wide)
                        Container(
                          width: 220,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: t.colorNeutralBackground1,
                            border: BorderDirectional(
                              end: BorderSide(color: t.colorNeutralStroke2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const FluentText(
                                'EXPLORE',
                                type: FluentTextType.tertiary,
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              for (final item in _categories)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: FluentButton(
                                    block: true,
                                    type: item == category
                                        ? FluentButtonType.primary
                                        : FluentButtonType.subtle,
                                    onPressed: () => _category(item),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: FluentText(item),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              const FluentText(
                                'BUILT ON FLUENT 2',
                                type: FluentTextType.tertiary,
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const FluentText(
                                'Microsoft tokens · Native port',
                                type: FluentTextType.secondary,
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scroll,
                          padding: EdgeInsets.all(wide ? 32 : 20),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1240),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const FluentText(
                                    'FLUENT 2 · NATIVE COMPONENTS',
                                    type: FluentTextType.secondary,
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FluentTitle(
                                    'Fluent 2.\nNative by nature.',
                                    level: wide ? 1 : 2,
                                  ),
                                  const SizedBox(height: 12),
                                  const FluentText(
                                    'Thoughtful defaults. Familiar interactions.\nExplore the components. Make them yours.',
                                    type: FluentTextType.secondary,
                                  ),
                                  const SizedBox(height: 20),
                                  const FluentStack(
                                    gap: 8,
                                    children: [
                                      FluentBadge('24 components'),
                                      FluentBadge('4 theme modes'),
                                      FluentBadge('26 official icons'),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FluentInput(
                                          controller: _search,
                                          prefix: FluentIconType.search,
                                          placeholder: 'Search components…',
                                          label: 'Search components',
                                          allowClear: true,
                                          onChanged: (value) =>
                                              setState(() => query = value),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      FluentSwitch(
                                        value: widget.compact,
                                        label: 'Compact density',
                                        onChanged: widget.onCompact,
                                      ),
                                      const SizedBox(width: 4),
                                      const FluentText('Compact'),
                                    ],
                                  ),
                                  if (!wide) ...[
                                    const SizedBox(height: 16),
                                    FluentToggleGroup(
                                      value: category,
                                      options: [
                                        for (final item in _categories)
                                          FluentOption(item, item),
                                      ],
                                      onChanged: _category,
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FluentTitle(category, level: 4),
                                      ),
                                      FluentBadge(
                                        '${demos.length} previews',
                                        status: FluentStatus.info,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (demos.isEmpty)
                                    const FluentEmptyState(
                                      description:
                                          'No matching components. Try another search.',
                                    ),
                                  LayoutBuilder(
                                    builder: (context, area) {
                                      final columns = area.maxWidth >= 800
                                          ? 2
                                          : 1;
                                      final width =
                                          (area.maxWidth - (columns - 1) * 20) /
                                          columns;
                                      return Wrap(
                                        spacing: 20,
                                        runSpacing: 20,
                                        children: [
                                          for (final demo in demos)
                                            SizedBox(
                                              width: width,
                                              child: FluentCard(
                                                title: demo.title,
                                                size: FluentSize.small,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    FluentText(
                                                      demo.description,
                                                      type: FluentTextType
                                                          .secondary,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    demo.child,
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  const FluentText(
                                    'Crafted for Compose Multiplatform & Flutter.\nAn independent community port of Microsoft Fluent 2.',
                                    type: FluentTextType.tertiary,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Demo {
  const _Demo(this.title, this.group, this.description, this.child);
  final String title, group, description;
  final Widget child;
}
