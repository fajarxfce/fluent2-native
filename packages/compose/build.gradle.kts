import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
    kotlin("multiplatform")
    id("org.jetbrains.kotlin.plugin.compose")
    id("org.jetbrains.compose")
    id("com.android.library")
    `maven-publish`
}

group = "dev.fluent2"
version = "0.1.0"

kotlin {
    jvmToolchain(17)
    androidTarget { publishLibraryVariants("release") }
    jvm("desktop")
    iosArm64()
    iosSimulatorArm64()
    @OptIn(ExperimentalWasmDsl::class)
    wasmJs { browser() }

    sourceSets {
        commonMain.dependencies {
            api(compose.runtime)
            api(compose.foundation)
            api(compose.ui)
        }
        commonTest.dependencies { implementation(kotlin("test")) }
        getByName("desktopTest").dependencies {
            implementation(compose.desktop.currentOs)
            implementation("org.jetbrains.compose.ui:ui-test-junit4:1.9.3")
        }
    }
}

android {
    namespace = "dev.fluent2.core"
    compileSdk = 36
    defaultConfig { minSdk = 24 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
