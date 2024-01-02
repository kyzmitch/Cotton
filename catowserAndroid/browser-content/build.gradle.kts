plugins {
    id("com.android.library")
    kotlin("android")
    id("org.jlleitschuh.gradle.ktlint")
}

android {
    namespace = "org.cotton.browser.content"
    compileSdk = 34

    defaultConfig {
        minSdk = 24

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        // compose compiler should be 1.5.4 because project uses kotlin 1.9.20
        // https://developer.android.com/jetpack/androidx/releases/compose-kotlin#kts
        kotlinCompilerExtensionVersion = "1.5.4"
    }
    packaging {
        resources {
            excludes.add("/META-INF/{AL2.0,LGPL2.1}")
        }
    }
}

val ktor_version: String by project

dependencies {
    implementation("org.cotton.base:cotton-base:0.1-SNAPSHOT")

    val android_x_core_ktx = rootProject.extra.get("android_x_core_ktx") as String
    val lifecycle_version = rootProject.extra.get("lifecycle_version") as String
    val android_x_activity = rootProject.extra.get("android_x_activity") as String
    val compose_version = rootProject.extra.get("compose_version") as String

    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:$lifecycle_version")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:$lifecycle_version")
    implementation("androidx.core:core-ktx:$android_x_core_ktx")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:$lifecycle_version")
    implementation("androidx.activity:activity-compose:$android_x_activity")
    implementation("androidx.activity:activity-ktx:$android_x_activity")
    implementation("androidx.compose.ui:ui:$compose_version")
    implementation("androidx.compose.ui:ui-tooling-preview:$compose_version")
    implementation("androidx.compose.material:material:1.5.4")
    implementation("androidx.compose.material:material-android:1.5.4")
    implementation("com.google.accompanist:accompanist-webview:0.28.0")
    implementation("io.ktor:ktor:$ktor_version")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:$compose_version")
    debugImplementation("androidx.compose.ui:ui-tooling:$compose_version")
    debugImplementation("androidx.compose.ui:ui-test-manifest:$compose_version")
    implementation("io.coil-kt:coil-compose:2.4.0")

    val room_version = rootProject.extra.get("room_version") as String
    implementation("androidx.room:room-runtime:$room_version")
    annotationProcessor("androidx.room:room-compiler:$room_version") /// kapt
    implementation("androidx.room:room-ktx:$room_version")
}

/**
 * Coil - image view with remote source https://github.com/coil-kt/coil#jetpack-compose
 * */
