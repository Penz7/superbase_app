import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.penz.superbase_app"
    compileSdk = 36
    ndkVersion = "29.0.13113456 rc1"

    val dartEnvironmentVariables = mutableMapOf(
        "APP_NAME" to "SuperBase App",
        "APP_SUFFIX" to null as String?
    )

    if (project.hasProperty("dart-defines")) {
        val dartDefines = project.property("dart-defines") as String
        val definesMap = dartDefines.split(",").associate {
            val decoded = String(Base64.getDecoder().decode(it))
            val pair = decoded.split("=")
            pair[0] to pair.getOrNull(1)
        }
        dartEnvironmentVariables.putAll(definesMap)
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.penz.superbase_app"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        applicationIdSuffix = dartEnvironmentVariables["APP_SUFFIX"]
        resValue("string", "app_name", dartEnvironmentVariables["APP_NAME"] as String)
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "app"

    productFlavors {
        create("production") {
            dimension = "app"
        }
        create("develop") {
            dimension = "app"
            applicationId = "com.penz.superbase_app"
            versionNameSuffix = ".dev"
        }
    }
}

dependencies {}

flutter {
    source = "../.."
}
