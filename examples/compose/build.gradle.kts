import org.jetbrains.compose.desktop.application.dsl.TargetFormat
import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    kotlin("multiplatform")
    id("org.jetbrains.kotlin.plugin.compose")
    id("org.jetbrains.compose")
    id("com.android.application")
}

kotlin {
    jvmToolchain(17)
    androidTarget()
    jvm("desktop")
    @OptIn(ExperimentalWasmDsl::class)
    wasmJs {
        browser()
        binaries.executable()
    }
    sourceSets {
        commonMain.dependencies { implementation(project(":fluent-compose")) }
        androidMain.dependencies { implementation("androidx.activity:activity-compose:1.11.0") }
        getByName("desktopMain").dependencies { implementation(compose.desktop.currentOs) }
    }
}

android {
    namespace = "dev.fluent2.catalog.compose"
    compileSdk = 36
    defaultConfig {
        applicationId = "dev.fluent2.catalog.compose"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "0.1.0"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

compose.desktop {
    application {
        mainClass = "dev.fluent2.catalog.MainKt"
        nativeDistributions {
            targetFormats(TargetFormat.Dmg, TargetFormat.Msi, TargetFormat.Deb)
            packageName = "Fluent 2 Compose"
            packageVersion = "0.1.0"
            macOS.packageVersion = "1.0.0"
        }
    }
}
