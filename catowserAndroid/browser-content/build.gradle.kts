plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    namespace = "org.cotton.browser.content"
    compileSdk = 33

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
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        // compose compiler should be 1.3.2 because project uses kotlin 1.7.20
        kotlinCompilerExtensionVersion = "1.3.2"
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
    implementation("org.cotton.base:CottonCoreBaseKit:0.1-SNAPSHOT")
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.3.1")
    implementation("androidx.activity:activity-compose:${rootProject.extra.get("android_x_activity") as String}")
    implementation("androidx.activity:activity-ktx:${rootProject.extra.get("android_x_activity") as String}")
    implementation("androidx.compose.ui:ui:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.ui:ui-tooling-preview:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.material:material:1.1.1")
    implementation("com.google.accompanist:accompanist-webview:0.28.0")
    implementation("io.ktor:ktor:$ktor_version")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-tooling:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-test-manifest:${rootProject.extra.get("compose_version") as String}")
}