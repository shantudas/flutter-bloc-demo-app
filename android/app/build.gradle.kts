plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.example.flutter_bloc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Base application ID - will be suffixed by flavor
        applicationId = "com.example.flutter_bloc"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Set flavor dimensions BEFORE productFlavors
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Social App Dev")
            // Make dev the default flavor
            isDefault = true
        }

        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Social App")
        }
    }

    buildTypes {
        debug {
            // Default debug build - no special signing needed
        }

        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Task to help Flutter find flavor-specific APKs
// This copies the APK to the location Flutter expects and creates a symlink
tasks.register("copyFlutterApk") {
    doLast {
        val sourceDir = file("${layout.buildDirectory.get()}/outputs/flutter-apk")
        val targetDir = file("../../build/app/outputs/flutter-apk")

        if (sourceDir.exists()) {
            targetDir.mkdirs()
            sourceDir.listFiles()?.forEach { file ->
                if (file.extension == "apk") {
                    val targetFile = File(targetDir, file.name)
                    file.copyTo(targetFile, overwrite = true)
                    println("✓ Copied ${file.name} to ${targetFile.absolutePath}")

                    // Also create a symlink without the flavor name for Flutter tooling
                    // app-dev-debug.apk -> app-debug.apk
                    val standardName = file.name.replace(Regex("-[a-z]+-(debug|release)"), "-$1")
                    if (standardName != file.name) {
                        val linkFile = File(targetDir, standardName)
                        if (linkFile.exists()) linkFile.delete()
                        file.copyTo(linkFile, overwrite = true)
                        println("✓ Created ${standardName} for Flutter tooling")
                    }
                }
            }
        }
    }
}

// Run copyFlutterApk after APK assembly
tasks.whenTaskAdded {
    if (name.matches(Regex("assemble.*"))) {
        finalizedBy("copyFlutterApk")
    }
}

