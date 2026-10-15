package dev.fluent2.catalog

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.fluent2.core.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private val categories = listOf("All components", "General", "Data entry", "Navigation", "Data display", "Feedback")
private data class Demo(val title: String, val group: String, val description: String, val content: @Composable () -> Unit)

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun FluentCatalog(onThemeChanged: (Boolean) -> Unit = {}) {
    var dark by rememberSaveable { mutableStateOf(false) }
    var compact by rememberSaveable { mutableStateOf(false) }
    var teams by rememberSaveable { mutableStateOf(false) }
    var notes by rememberSaveable { mutableStateOf("") }
    var expanded by remember { mutableStateOf(setOf("design")) }
    var location by rememberSaveable { mutableStateOf("Components") }
    var category by rememberSaveable { mutableStateOf("All components") }
    var query by rememberSaveable { mutableStateOf("") }
    var email by rememberSaveable { mutableStateOf("") }
    var password by rememberSaveable { mutableStateOf("") }
    var checked by rememberSaveable { mutableStateOf<Boolean?>(null) }
    var radio by rememberSaveable { mutableStateOf("Design") }
    var notifications by rememberSaveable { mutableStateOf(true) }
    var role by rememberSaveable { mutableStateOf("designer") }
    var period by rememberSaveable { mutableStateOf("Week") }
    var tab by rememberSaveable { mutableStateOf("Overview") }
    var count by rememberSaveable { mutableIntStateOf(5) }
    var percent by rememberSaveable { mutableFloatStateOf(62f) }
    var message by remember { mutableStateOf<String?>(null) }
    var loading by remember { mutableStateOf(false) }
    var validated by rememberSaveable { mutableStateOf(false) }
    var alertVisible by rememberSaveable { mutableStateOf(true) }
    var skeleton by rememberSaveable { mutableStateOf(true) }
    var created by rememberSaveable { mutableStateOf(false) }
    var modalOpen by rememberSaveable { mutableStateOf(false) }
    var modalLoading by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val grid = rememberLazyGridState()
    val tokens = when { teams && dark -> FluentTokens.teamsDark; teams -> FluentTokens.teamsLight; dark -> FluentTokens.dark; else -> FluentTokens.light }
    LaunchedEffect(dark) { onThemeChanged(dark) }
    val selectCategory: (String) -> Unit = { category = it; query = ""; scope.launch { grid.scrollToItem(0) } }
    val emailError = validated && !Regex("""^[^\s@]+@[^\s@]+\.[^\s@]+$""").matches(email)
    val demos = listOf(
        Demo("Button", "General", "A clear action for every level of emphasis.") {
            FluentStack {
                FluentButton(onClick = { scope.launch { loading = true; message = null; delay(900); loading = false; message = "Project created. You’re ready to build." } },
                    type = FluentButtonType.Primary, icon = FluentIconType.Plus, loading = loading) { FluentText("Create project") }
                FluentButton(onClick = { message = "Secondary action selected." }) { FluentText("Secondary") }
                FluentButton(onClick = { message = "Outline action selected." }, type = FluentButtonType.Outline) { FluentText("Outline") }
                FluentButton(onClick = { message = "Subtle action selected." }, type = FluentButtonType.Subtle) { FluentText("Subtle") }
                FluentButton(onClick = { message = "Transparent action selected." }, type = FluentButtonType.Transparent) { FluentText("Transparent") }
                FluentButton(onClick = { message = "Danger action selected." }, danger = true) { FluentText("Danger") }
                FluentButton(onClick = {}, enabled = false) { FluentText("Disabled") }
            }
            FluentDivider()
            FluentStack { FluentSize.entries.forEach { size -> FluentButton(onClick = { message = "${size.name} button pressed." }, size = size) { FluentText(size.name.lowercase()) } } }
            if (message != null) FluentMessageBar(message!!, type = FluentStatus.Success, onClose = { message = null })
        },
        Demo("Typography", "General", "A familiar hierarchy, with native text rendering.") {
            FluentStack(vertical = true) {
                FluentTitle("Good design feels familiar.", level = 4)
                FluentText("Build a consistent experience with considered defaults.")
                FluentText("Secondary text supports the main story.", type = FluentTextType.Secondary)
                FluentStack { FluentText("Success", type = FluentTextType.Success); FluentText("Warning", type = FluentTextType.Warning); FluentText("Error", type = FluentTextType.Danger) }
                FluentStack { FluentText("Semibold", strong = true); FluentText("Underlined", underline = true); FluentText("FluentTheme", code = true) }
            }
        },
        Demo("Icon", "General", "26 official Fluent 2 vectors, shared across runtimes.") {
            FluentStack(gap = 20.dp) { FluentIconType.entries.forEach { FluentIcon(it, size = 22.dp, contentDescription = it.name) } }
        },
        Demo("Input & Field", "Data entry", "Clear labels, helpful feedback, and platform text editing.") {
            FluentField("Email address", required = true, status = if (emailError) FluentStatus.Error else FluentStatus.Default,
                help = if (emailError) "Enter a valid email address." else if (validated) "Email looks good." else "We’ll use this for workspace updates.") {
                FluentInput(email, { email = it }, Modifier.fillMaxWidth(), label = "Email address", placeholder = "you@example.com", allowClear = true,
                    status = if (emailError) FluentStatus.Error else FluentStatus.Default, errorMessage = if (emailError) "Enter a valid email address." else null,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email))
            }
            FluentInput(password, { password = it }, Modifier.fillMaxWidth(), label = "Password", placeholder = "Password", password = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password))
            FluentButton(onClick = { validated = true }, type = FluentButtonType.Primary) { FluentText("Validate") }
        },
        Demo("Checkbox & Radio", "Data entry", "Controlled values with clear selected and mixed states.") {
            FluentCheckbox(checked, { checked = it }, label = "Select all components")
            FluentCheckbox(true, null, label = "Disabled selection")
            FluentStack(gap = 20.dp) { listOf("Design", "Develop").forEach { item -> FluentRadio(radio == item, { radio = item }, label = item) } }
            FluentText("Selected: $radio", type = FluentTextType.Secondary)
        },
        Demo("Switch", "Data entry", "A small control for an immediate change.") {
            FluentStack {
                FluentSwitch(notifications, { notifications = it }, label = "Notifications")
                FluentText("Notifications ${if (notifications) "on" else "off"}")
            }
            FluentStack(gap = 20.dp) {
                FluentSwitch(notifications, { notifications = it }, size = FluentSize.Small, label = "Small notifications switch")
                FluentSwitch(true, {}, loading = true, label = "Loading switch")
                FluentSwitch(false, null, label = "Disabled switch")
            }
        },
        Demo("Dropdown", "Data entry", "Single selection with keyboard navigation and disabled options.") {
            FluentDropdown(role, listOf(FluentOption("designer", "Designer"), FluentOption("developer", "Developer"), FluentOption("viewer", "Viewer"), FluentOption("archived", "Archived role", false)),
                { role = it }, Modifier.fillMaxWidth(), label = "Workspace role")
            FluentText("Current role: $role", type = FluentTextType.Secondary)
        },
        Demo("TabList", "Navigation", "Move between views without losing your place.") {
            FluentToggleGroup(period, listOf("Day", "Week", "Month").map { FluentOption(it, it) }, { period = it })
            FluentTabList(tab, listOf(FluentOption("Overview", "Overview"), FluentOption("Activity", "Activity"), FluentOption("Settings", "Settings", false)), { tab = it }) { value ->
                FluentText(if (value == "Overview") "Your $period overview is ready." else "Your recent workspace activity appears here.")
            }
        },
        Demo("Card & Statistic", "Data display", "Give related information a place of its own.") {
            FluentCard(title = "Workspace overview", size = FluentSize.Small, extra = { FluentBadge("Live", status = FluentStatus.Success) }) {
                FluentStack(gap = 40.dp) { FluentStatistic("Active projects", "24"); FluentStatistic("Completion", "93", suffix = "%") }
            }
        },
        Demo("Avatar & CounterBadge", "Data display", "Identity and updates, at a glance.") {
            FluentStack(gap = 24.dp) {
                FluentCounterBadge(count) { FluentAvatar("FA", label = "Fajar") }
                FluentCounterBadge(dot = true) { FluentAvatar(square = true) }
                FluentAvatar("FL", size = 48.dp)
                FluentAvatar(size = 32.dp)
            }
            FluentStack {
                FluentButton(onClick = { count++ }, icon = FluentIconType.Plus) { FluentText("Add") }
                FluentButton(onClick = { count = 0 }) { FluentText("Clear notifications") }
            }
        },
        Demo("Badge", "Data display", "Compact labels for status and categorization.") {
            FluentStack {
                FluentBadge("Default")
                FluentBadge("Processing", status = FluentStatus.Info, icon = FluentIconType.Loading)
                FluentBadge("Success", status = FluentStatus.Success, icon = FluentIconType.Check)
                FluentBadge("Warning", status = FluentStatus.Warning)
                FluentBadge("Error", status = FluentStatus.Error)
                FluentBadge("Outline", status = FluentStatus.Info, appearance = FluentBadgeAppearance.Outline)
            }
        },
        Demo("Stack & Divider", "Data display", "Consistent rhythm, built on the four-point grid.") {
            FluentStack(gap = 16.dp) { FluentBadge("First"); FluentBadge("Second"); FluentBadge("Third") }
            FluentDivider(text = "A little breathing room")
            FluentText("Spacing is part of the system.", type = FluentTextType.Secondary)
        },
        Demo("MessageBar", "Feedback", "Give timely, contextual feedback.") {
            FluentMessageBar("Your changes are saved.", type = FluentStatus.Success)
            FluentMessageBar("A new version is available.", type = FluentStatus.Info)
            FluentMessageBar("Your trial ends in 3 days.", type = FluentStatus.Warning)
            if (alertVisible) FluentMessageBar("Couldn’t connect.", description = "Check your connection and try again.", type = FluentStatus.Error, onClose = { alertVisible = false })
            else FluentButton(onClick = { alertVisible = true }, type = FluentButtonType.Transparent) { FluentText("Restore alert") }
        },
        Demo("ProgressBar", "Feedback", "Make progress visible, from the first step to done.") {
            FluentProgressBar(percent)
            FluentProgressBar(100f)
            FluentStack(gap = 20.dp) {
                FluentProgressBar(percent, type = FluentProgressType.Circle)
                FluentButton(onClick = { percent = (percent - 10).coerceIn(0f, 100f) }, contentDescription = "Decrease progress") { FluentIcon(FluentIconType.Minus) }
                FluentButton(onClick = { percent = (percent + 10).coerceIn(0f, 100f) }, contentDescription = "Increase progress") { FluentIcon(FluentIconType.Plus) }
            }
        },
        Demo("Spinner & Skeleton", "Feedback", "Considered loading states while content is on its way.") {
            FluentStack(gap = 16.dp) { FluentSpinner(size = 16.dp); FluentSpinner(size = 24.dp); FluentSpinner(size = 32.dp); FluentText("Loading workspace…", type = FluentTextType.Secondary) }
            if (skeleton) FluentSkeleton(avatar = true) else FluentMessageBar("Content is ready.", type = FluentStatus.Success)
            FluentButton(onClick = { skeleton = !skeleton }) { FluentText(if (skeleton) "Finish loading" else "Show skeleton") }
        },
        Demo("Textarea", "Data entry", "Room for a longer thought, with native text editing.") {
            FluentField("Project notes", help = "${notes.length} characters") {
                FluentTextarea(notes, { notes = it }, Modifier.fillMaxWidth(), label = "Project notes", placeholder = "What are you building?")
            }
        },
        Demo("Accordion", "Data display", "Reveal one section at a time. Use arrow keys between headers.") {
            FluentAccordion(listOf(
                FluentAccordionItem("design", "Designed for clarity") { FluentText("Fluent brings color, typography, depth and motion into one consistent system.") },
                FluentAccordionItem("native", "Built for your platform") { FluentText("Compose and Flutter render these components with their native UI toolkits.") },
                FluentAccordionItem("soon", "More patterns soon", enabled = false) {},
            ), expanded, { expanded = it }, Modifier.fillMaxWidth())
        },
        Demo("Breadcrumb & Link", "Navigation", "Show where you are and offer a clear way back.") {
            FluentBreadcrumb(listOf(FluentBreadcrumbItem("home", "Home"), FluentBreadcrumbItem("library", "Library"), FluentBreadcrumbItem("components", location)), { location = if (it == "home") "Home" else "Library" })
            FluentLink("Explore component guidance", { message = "Open the Fluent 2 documentation from the repository README." })
            FluentText("Current page: $location", type = FluentTextType.Secondary)
        },
        Demo("Dialog", "Feedback", "Useful empty states and focused confirmation dialogs.") {
            if (created) {
                FluentMessageBar("Workspace created.", type = FluentStatus.Success)
                FluentButton(onClick = { created = false }) { FluentText("Reset demo") }
            } else FluentEmptyState(description = "Your next idea starts here.", action = {
                FluentButton(onClick = { modalOpen = true }, type = FluentButtonType.Primary, icon = FluentIconType.Plus) { FluentText("New workspace") }
            })
        },
    ).filter { (category == "All components" || it.group == category) && (it.title + " " + it.description).contains(query, ignoreCase = true) }
    BoxWithConstraints(Modifier.fillMaxSize()) {
        val wide = maxWidth >= 1000.dp
        FluentTheme(tokens, size = if (compact) FluentSize.Small else FluentSize.Middle, minimumTouchTarget = if (maxWidth < 700.dp) 44.dp else 0.dp) {
            Column(Modifier.fillMaxSize().background(tokens.colorNeutralBackground3).windowInsetsPadding(WindowInsets.safeDrawing)) {
                Row(Modifier.fillMaxWidth().background(tokens.colorNeutralBackground1).padding(horizontal = 20.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Box(Modifier.size(36.dp).background(tokens.colorBrandBackground, RoundedCornerShape(8.dp)), contentAlignment = Alignment.Center) { FluentIcon(FluentIconType.Grid, color = Color.White, size = 22.dp) }
                    Spacer(Modifier.width(10.dp))
                    FluentText("Fluent 2", Modifier.weight(1f), strong = true, maxLines = 1, style = TextStyle(fontSize = 18.sp))
                    FluentButton(onClick = { teams = !teams }, type = FluentButtonType.Subtle, contentDescription = if (teams) "Switch to Web theme" else "Switch to Teams theme") { FluentText(if (teams) "Teams" else "Web") }
                    FluentBadge("Compose", status = FluentStatus.Info)
                    Spacer(Modifier.width(8.dp))
                    FluentButton(onClick = { dark = !dark }, type = FluentButtonType.Subtle, contentDescription = if (dark) "Switch to light theme" else "Switch to dark theme") { FluentIcon(if (dark) FluentIconType.Sun else FluentIconType.Moon, size = 20.dp) }
                }
                Box(Modifier.fillMaxWidth().height(1.dp).background(tokens.colorNeutralStroke2))
                Row(Modifier.weight(1f)) {
                    if (wide) Column(Modifier.width(220.dp).fillMaxHeight().background(tokens.colorNeutralBackground1).padding(20.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        FluentText("EXPLORE", type = FluentTextType.Tertiary, style = TextStyle(fontSize = 11.sp, letterSpacing = 1.5.sp))
                        Spacer(Modifier.height(10.dp))
                        categories.forEach { item -> FluentButton(onClick = { selectCategory(item) }, block = true, type = if (item == category) FluentButtonType.Primary else FluentButtonType.Subtle) { FluentText(item, Modifier.fillMaxWidth()) } }
                        Spacer(Modifier.weight(1f))
                        FluentText("BUILT ON FLUENT 2", type = FluentTextType.Tertiary, style = TextStyle(fontSize = 10.sp, letterSpacing = 1.sp))
                        FluentText("Microsoft tokens · Native port", type = FluentTextType.Secondary)
                    }
                    LazyVerticalGrid(columns = GridCells.Adaptive(380.dp), state = grid, modifier = Modifier.weight(1f),
                        contentPadding = PaddingValues(if (wide) 32.dp else 20.dp), horizontalArrangement = Arrangement.spacedBy(20.dp), verticalArrangement = Arrangement.spacedBy(20.dp)) {
                        item(span = { GridItemSpan(maxLineSpan) }) {
                            Column {
                                FluentText("FLUENT 2 · NATIVE COMPONENTS", type = FluentTextType.Secondary, style = TextStyle(fontSize = 11.sp, letterSpacing = 1.6.sp))
                                Spacer(Modifier.height(12.dp))
                                FluentTitle("Fluent 2.\nNative by nature.", level = if (wide) 1 else 2)
                                Spacer(Modifier.height(12.dp))
                                FluentText("Thoughtful defaults. Familiar interactions.\nExplore the components. Make them yours.", type = FluentTextType.Secondary)
                                Spacer(Modifier.height(20.dp))
                                FluentStack { FluentBadge("24 components"); FluentBadge("4 theme modes"); FluentBadge("26 official icons") }
                                Spacer(Modifier.height(28.dp))
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    FluentInput(query, { query = it }, Modifier.weight(1f), label = "Search components", placeholder = "Search components…", prefix = FluentIconType.Search, allowClear = true)
                                    FluentSwitch(compact, { compact = it }, label = "Compact density")
                                    FluentText("Compact")
                                }
                                if (!wide) {
                                    Spacer(Modifier.height(16.dp))
                                    FluentToggleGroup(category, categories.map { FluentOption(it, it) }, selectCategory)
                                }
                                Spacer(Modifier.height(24.dp))
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    FluentTitle(category, Modifier.weight(1f), level = 4)
                                    FluentBadge("${demos.size} previews", status = FluentStatus.Info)
                                }
                            }
                        }
                        if (demos.isEmpty()) item(span = { GridItemSpan(maxLineSpan) }) { FluentEmptyState(description = "No matching components. Try another search.") }
                        items(demos, key = { it.title }) { demo ->
                            FluentCard(title = demo.title) { FluentText(demo.description, type = FluentTextType.Secondary); demo.content() }
                        }
                        item(span = { GridItemSpan(maxLineSpan) }) {
                            FluentText("Crafted for Compose Multiplatform & Flutter.\nAn independent community port of Microsoft Fluent 2.", Modifier.padding(vertical = 12.dp), type = FluentTextType.Tertiary)
                        }
                    }
                }
            }
            FluentDialog(open = modalOpen, title = "Create a workspace?", onDismiss = { modalOpen = false }, confirmText = "Create workspace", confirmLoading = modalLoading,
                onConfirm = { scope.launch { modalLoading = true; delay(700); modalLoading = false; modalOpen = false; created = true } }) {
                FluentText("Your new workspace will use the shared Fluent 2 theme. You can change its settings any time.")
            }
        }
    }
}
