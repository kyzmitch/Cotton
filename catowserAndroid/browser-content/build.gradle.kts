plugins {
    id("com.android.library")
    kotlin("android")
    id("org.jlleitschuh.gradle.ktlint")
}

android {
    namespace = "org.cotton.browser.content"
    compileSdk = 34

    defaultConfig {
        minSdk = 21
        // `targetSdk` has no effect for libraries. This could be only used for the test APK
        targetSdk = 33

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
    packagingOptions {
        resources {
            excludes.add("/META-INF/{AL2.0,LGPL2.1}")
        }
    }
}

val ktor_version: String by project

dependencies {
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:${rootProject.extra.get("lifecycle_version") as String}")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:${rootProject.extra.get("lifecycle_version") as String}")
    implementation("org.cotton.base:cotton-base:0.1-SNAPSHOT")
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.3.1")
    implementation("androidx.activity:activity-compose:${rootProject.extra.get("android_x_activity") as String}")
    implementation("androidx.activity:activity-ktx:${rootProject.extra.get("android_x_activity") as String}")
    implementation("androidx.compose.ui:ui:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.ui:ui-tooling-preview:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.material:material:1.5.4")
    implementation("androidx.compose.material:material-android:1.5.4")
    implementation("com.google.accompanist:accompanist-webview:0.28.0")
    implementation("io.ktor:ktor:$ktor_version")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-tooling:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-test-manifest:${rootProject.extra.get("compose_version") as String}")
    implementation("io.coil-kt:coil-compose:2.4.0")
}

/**
 * Coil - image view with remote source https://github.com/coil-kt/coil#jetpack-compose
 * */
