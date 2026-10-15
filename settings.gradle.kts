pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "fluent2-native"
include(":fluent-compose", ":compose-catalog")
project(":fluent-compose").projectDir = file("packages/compose")
project(":compose-catalog").projectDir = file("examples/compose")
