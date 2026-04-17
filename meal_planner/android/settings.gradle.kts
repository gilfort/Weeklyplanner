pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

// Redirect build directories outside OneDrive to avoid file-locking issues.
// Flutter expects the :app build output at <flutter_project>/build/app/,
// so we use the flutter project root (parent of android/) as the base.
gradle.beforeProject {
    val flutterProjectRoot = rootProject.projectDir.parentFile
    buildDir = File("$flutterProjectRoot/build/${project.name}")
}
