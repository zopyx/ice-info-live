package com.nruge.iceinfo

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color as AndroidColor
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.PredictiveBackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Snackbar
import androidx.compose.material3.SnackbarDuration
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.runtime.*
import androidx.compose.runtime.getValue
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import kotlinx.coroutines.launch
import com.nruge.iceinfo.model.*
import com.nruge.iceinfo.ui.AppFloatingNavBar
import com.nruge.iceinfo.ui.AppNavigation
import com.nruge.iceinfo.ui.AppTopBar
import com.nruge.iceinfo.ui.ChangelogDialog
import com.nruge.iceinfo.ui.CrashReportingConsentDialog
import com.nruge.iceinfo.ui.DebugDialog
import com.nruge.iceinfo.ui.InfoDialog
import com.nruge.iceinfo.ui.MainViewModel
import com.nruge.iceinfo.ui.OnboardingDialog
import com.nruge.iceinfo.ui.SettingsSheet
import com.nruge.iceinfo.ui.StopSelectionDialog
import com.nruge.iceinfo.ui.components.NoWifiScreen
import com.nruge.iceinfo.ui.theme.ICEInfoTheme
import com.nruge.iceinfo.util.isWIFIonICE as checkWIFIonICE
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {

    private lateinit var appUpdateManager: AppUpdateManager
    private val snackbarHostState = SnackbarHostState()

    private val installStateListener = InstallStateUpdatedListener { state ->
        if (state.installStatus() == InstallStatus.DOWNLOADED) {
            lifecycleScope.launch {
                val result = snackbarHostState.showSnackbar(
                    message = getString(R.string.update_downloaded),
                    actionLabel = getString(R.string.update_install),
                    duration = SnackbarDuration.Indefinite
                )
                if (result == SnackbarResult.ActionPerformed) {
                    appUpdateManager.completeUpdate()
                }
            }
        }
    }

    @SuppressLint("InvalidFragmentVersionForActivityResult")
    val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            startForegroundService(Intent(this, IceNotificationService::class.java))
        }
    }

    @SuppressLint("InvalidFragmentVersionForActivityResult")
    private val updateResultLauncher = registerForActivityResult(
        ActivityResultContracts.StartIntentSenderForResult()
    ) { result ->
        if (result.resultCode != RESULT_OK) {
            Log.w("AppUpdate", "Update flow cancelled: ${result.resultCode}")
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        appUpdateManager.appUpdateInfo.addOnSuccessListener { info ->
            // Resume an IMMEDIATE update that was interrupted (e.g. user
            // backgrounded the app during the update flow). Without this,
            // a half-finished high-priority update would be silently
            // dropped on the floor.
            if (info.updateAvailability() ==
                UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS &&
                info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
            ) {
                appUpdateManager.startUpdateFlowForResult(
                    info,
                    updateResultLauncher,
                    AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build()
                )
                return@addOnSuccessListener
            }
            if (info.installStatus() == InstallStatus.DOWNLOADED) {
                lifecycleScope.launch {
                    val result = snackbarHostState.showSnackbar(
                        message = getString(R.string.update_downloaded),
                        actionLabel = getString(R.string.update_install),
                        duration = SnackbarDuration.Indefinite
                    )
                    if (result == SnackbarResult.ActionPerformed) {
                        appUpdateManager.completeUpdate()
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        appUpdateManager.unregisterListener(installStateListener)
    }

    private fun checkForUpdate() {
        appUpdateManager.appUpdateInfo.addOnSuccessListener { info ->
            if (info.updateAvailability() != UpdateAvailability.UPDATE_AVAILABLE) return@addOnSuccessListener

            // High-priority updates (set via Play Publishing API, priority >= 4)
            // are pushed as IMMEDIATE — the user must update before continuing.
            // Used for critical hotfixes. Everything else stays FLEXIBLE.
            val highPriority = info.updatePriority() >= 4
            val type = when {
                highPriority && info.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE) ->
                    AppUpdateType.IMMEDIATE
                info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE) ->
                    AppUpdateType.FLEXIBLE
                else -> return@addOnSuccessListener
            }
            appUpdateManager.startUpdateFlowForResult(
                info,
                updateResultLauncher,
                AppUpdateOptions.newBuilder(type).build()
            )
        }.addOnFailureListener {
            Log.w("AppUpdate", "Update check failed: ${it.message}")
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        appUpdateManager = AppUpdateManagerFactory.create(this)
        appUpdateManager.registerListener(installStateListener)
        checkForUpdate()
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(
                AndroidColor.TRANSPARENT,
                AndroidColor.TRANSPARENT
            ),
            navigationBarStyle = SystemBarStyle.auto(
                AndroidColor.TRANSPARENT,
                AndroidColor.TRANSPARENT
            )
        )
        setContent {
            val viewModel: MainViewModel = viewModel()
            val trainStatus: TrainStatus by viewModel.trainStatus.collectAsStateWithLifecycle()
            val pois: List<PoiItem> by viewModel.pois.collectAsStateWithLifecycle()
            val isMockMode: Boolean by viewModel.isMockMode.collectAsStateWithLifecycle()
            val demoSpeed: Int by viewModel.demoSpeed.collectAsStateWithLifecycle()
            val reducedMotion: Boolean by viewModel.reducedMotion.collectAsStateWithLifecycle()
            val connections: List<ConnectingTrain> by viewModel.connections.collectAsStateWithLifecycle()
            val departures: List<Departure> by viewModel.departures.collectAsStateWithLifecycle()
            val weather by viewModel.weather.collectAsStateWithLifecycle()
            val isWIFIonICEStatus: Boolean by viewModel.isWIFIonICE.collectAsStateWithLifecycle()

            val initialContext = LocalContext.current
            var appTheme by rememberSaveable {
                mutableStateOf(
                    runCatching {
                        AppTheme.valueOf(com.nruge.iceinfo.util.SettingsManager.getAppTheme(initialContext))
                    }.getOrDefault(AppTheme.SYSTEM)
                )
            }
            val isDark = when (appTheme) {
                AppTheme.LIGHT -> false
                AppTheme.DARK -> true
                AppTheme.SYSTEM -> isSystemInDarkTheme()
            }

            ICEInfoTheme(darkTheme = isDark) {
                val view = LocalView.current
                val context = LocalContext.current

                val lifecycleOwner = LocalLifecycleOwner.current
                LaunchedEffect(lifecycleOwner) {
                    lifecycleOwner.lifecycle.repeatOnLifecycle(Lifecycle.State.STARTED) {
                        while (true) {
                            viewModel.updateWifiStatus(checkWIFIonICE(context))
                            delay(5000)
                        }
                    }
                }
                SideEffect {
                    val window = (view.context as Activity).window
                    val controller = WindowCompat.getInsetsController(window, view)
                    controller.isAppearanceLightStatusBars = !isDark
                    controller.isAppearanceLightNavigationBars = !isDark
                }

                val serviceRunning by IceNotificationService.isRunning.collectAsStateWithLifecycle()
                var showInfo by remember { mutableStateOf(false) }
                var showChangelog by remember { mutableStateOf(false) }
                var showSettings by remember { mutableStateOf(false) }
                var showDebug by remember { mutableStateOf(false) }
                var showDemoSpeed by remember { mutableStateOf(false) }
                
                var showOnboarding by remember {
                    mutableStateOf(!com.nruge.iceinfo.util.SettingsManager.isOnboardingShown(context))
                }
                var showCrashConsent by remember {
                    mutableStateOf(
                        com.nruge.iceinfo.util.SettingsManager.getCrashConsentVersion(context)
                            != com.nruge.iceinfo.BuildConfig.VERSION_CODE
                    )
                }

                LaunchedEffect(intent) {
                    // Action select target is now handled by dropdown in HomeScreen
                }
                val navController = rememberNavController()
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentRoute = navBackStackEntry?.destination?.route
                val scrollBehavior = TopAppBarDefaults.pinnedScrollBehavior()

                LaunchedEffect(currentRoute) {
                    scrollBehavior.state.contentOffset = 0f
                }

                Scaffold(
                    modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
                    containerColor = MaterialTheme.colorScheme.surfaceContainer,
                    snackbarHost = {
                        SnackbarHost(snackbarHostState) { data ->
                            Snackbar(snackbarData = data)
                        }
                    },
                    topBar = {
                        AppTopBar(
                            isMockMode = isMockMode,
                            isConnected = trainStatus.isConnected,
                            isOnTrainWifi = isWIFIonICEStatus,
                            serviceRunning = serviceRunning,
                            onToggleService = {
                                if (serviceRunning) {
                                    val stopIntent = Intent(context, IceNotificationService::class.java).apply {
                                        action = IceNotificationService.ACTION_STOP
                                    }
                                    context.startService(stopIntent)
                                } else {
                                    if (context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS)
                                        == PackageManager.PERMISSION_GRANTED) {
                                        val intent = Intent(context, IceNotificationService::class.java).apply {
                                            if (isMockMode) {
                                                putExtra(IceNotificationService.EXTRA_DEMO_SPEED, demoSpeed)
                                            }
                                            trainStatus.targetStopEva?.let {
                                                putExtra(IceNotificationService.EXTRA_TARGET_EVA, it)
                                            }
                                        }
                                        context.startForegroundService(intent)
                                    } else {
                                        requestPermissionLauncher.launch(
                                            android.Manifest.permission.POST_NOTIFICATIONS
                                        )
                                    }
                                }
                            },
                            onExitDemo = { viewModel.setMockMode(false) },
                            onShowSettings = { showSettings = true },
                            onShowInfo = { showInfo = true },
                            onShowChangelog = { showChangelog = true },
                            scrollBehavior = scrollBehavior
                        )
                    },
                ) { innerPadding ->
                    var demoBackProgress by remember { mutableFloatStateOf(0f) }
                    var demoBackInProgress by remember { mutableStateOf(false) }

                    PredictiveBackHandler(enabled = isMockMode) { events ->
                        try {
                            events.collect { e ->
                                demoBackInProgress = true
                                demoBackProgress = e.progress
                            }
                            viewModel.setMockMode(false)
                        } catch (_: kotlinx.coroutines.CancellationException) {
                        } finally {
                            demoBackInProgress = false
                            demoBackProgress = 0f
                        }
                    }

                    Box(modifier = Modifier.fillMaxSize()) {
                        if (demoBackInProgress) {
                            NoWifiScreen(
                                modifier = Modifier.padding(innerPadding),
                                status = trainStatus,
                                isWIFIonICE = isWIFIonICEStatus,
                                onRetry = {},
                                onMockMode = {}
                            )
                        }

                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .graphicsLayer {
                                    if (demoBackInProgress) {
                                        val s = 1f - (demoBackProgress * 0.15f)
                                        scaleX = s
                                        scaleY = s
                                        alpha = 1f - demoBackProgress * 0.9f
                                    }
                                }
                        ) {
                            if (!trainStatus.isConnected && !isMockMode && !isWIFIonICEStatus) {
                                NoWifiScreen(
                                    modifier = Modifier.padding(innerPadding),
                                    status = trainStatus,
                                    isWIFIonICE = isWIFIonICEStatus,
                                    onRetry = { viewModel.retryConnection() },
                                    onMockMode = { viewModel.setMockMode(true) }
                                )
                            } else {
                                AppNavigation(
                                    navController = navController,
                                    innerPadding = innerPadding,
                                    trainStatus = trainStatus,
                                    pois = pois,
                                    connections = connections,
                                    departures = departures,
                                    weather = weather,
                                    isMockMode = isMockMode,
                                    demoSpeed = demoSpeed,
                                    showDemoSpeed = showDemoSpeed,
                                    reducedMotion = reducedMotion,
                                    onDemoSpeedChange = {
                                        viewModel.setDemoSpeed(it)
                                        if (serviceRunning && isMockMode) {
                                            val intent = Intent(context, IceNotificationService::class.java).apply {
                                                putExtra(IceNotificationService.EXTRA_DEMO_SPEED, it)
                                            }
                                            context.startForegroundService(intent)
                                        }
                                    },
                                    onTargetStopChange = { viewModel.setTargetStop(it) }
                                )
                            }
                        }

                        if ((trainStatus.isConnected || isMockMode || isWIFIonICEStatus) && !demoBackInProgress)
                        AppFloatingNavBar(
                            currentRoute = currentRoute,
                            enabled = true,
                            onNavigate = { route ->
                                navController.navigate(route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .navigationBarsPadding()
                                .padding(bottom = 16.dp)
                        )
                    }
                }

                if (showInfo) {
                    InfoDialog(onDismiss = { showInfo = false })
                }

                if (showChangelog) {
                    ChangelogDialog(onDismiss = { showChangelog = false })
                }

                if (showSettings) {
                    var crashReportingEnabled by remember {
                        mutableStateOf(com.nruge.iceinfo.util.SettingsManager.isCrashReportingEnabled(context))
                    }
                    SettingsSheet(
                        appTheme = appTheme,
                        onThemeChange = {
                            appTheme = it
                            com.nruge.iceinfo.util.SettingsManager.setAppTheme(context, it.name)
                        },
                        isMockMode = isMockMode,
                        showDemoSpeed = showDemoSpeed,
                        onToggleDemoSpeed = { showDemoSpeed = it },
                        reducedMotion = reducedMotion,
                        onToggleReducedMotion = { viewModel.setReducedMotion(it) },
                        crashReportingEnabled = crashReportingEnabled,
                        onToggleCrashReporting = { enabled ->
                            crashReportingEnabled = enabled
                            com.nruge.iceinfo.util.SettingsManager.setCrashReportingEnabled(context, enabled)
                            com.google.firebase.crashlytics.FirebaseCrashlytics.getInstance()
                                .isCrashlyticsCollectionEnabled = enabled
                        },
                        language = com.nruge.iceinfo.util.SettingsManager.getLanguage(context),
                        onLanguageChange = {
                            com.nruge.iceinfo.util.SettingsManager.setLanguage(context, it)
                            showSettings = false
                        },
                        onDebug = {
                            showSettings = false
                            showDebug = true
                        },
                        onDismiss = { showSettings = false }
                    )
                }

                if (showDebug) {
                    DebugDialog(onDismiss = { showDebug = false })
                }

                if (showOnboarding) {
                    OnboardingDialog(onDismiss = {
                        com.nruge.iceinfo.util.SettingsManager.setOnboardingShown(context)
                        showOnboarding = false
                    })
                } else if (showCrashConsent) {
                    CrashReportingConsentDialog(
                        onAccept = {
                            com.nruge.iceinfo.util.SettingsManager.setCrashReportingEnabled(context, true)
                            com.nruge.iceinfo.util.SettingsManager.setCrashConsentVersion(
                                context, com.nruge.iceinfo.BuildConfig.VERSION_CODE
                            )
                            com.google.firebase.crashlytics.FirebaseCrashlytics.getInstance()
                                .isCrashlyticsCollectionEnabled = true
                            showCrashConsent = false
                        },
                        onDecline = {
                            com.nruge.iceinfo.util.SettingsManager.setCrashReportingEnabled(context, false)
                            com.nruge.iceinfo.util.SettingsManager.setCrashConsentVersion(
                                context, com.nruge.iceinfo.BuildConfig.VERSION_CODE
                            )
                            com.google.firebase.crashlytics.FirebaseCrashlytics.getInstance()
                                .isCrashlyticsCollectionEnabled = false
                            showCrashConsent = false
                        }
                    )
                }
            }
        }
    }
}
