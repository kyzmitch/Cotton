plugins {
    id("com.android.application")
    kotlin("android")
    id("org.jlleitschuh.gradle.ktlint")
}

android {
    namespace = "org.cotton.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "org.cotton"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"

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

dependencies {
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:${rootProject.extra.get("lifecycle_version") as String}")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:${rootProject.extra.get("lifecycle_version") as String}")
    implementation(project(mapOf("path" to ":browser-content")))
    implementation("org.cotton.base:cotton-base:0.1-SNAPSHOT")
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.3.1")
    implementation("androidx.activity:activity-compose:${rootProject.extra.get("android_x_activity") as String}")
    implementation("androidx.activity:activity-ktx:${rootProject.extra.get("android_x_activity") as String}")
    implementation("androidx.compose.ui:ui:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.ui:ui-tooling-preview:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.material:material:1.1.1")
    val navigationVersion = rootProject.extra.get("android_x_navigation") as String
    implementation("androidx.navigation:navigation-runtime-ktx:${navigationVersion}")
    implementation("androidx.navigation:navigation-compose:${navigationVersion}")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-tooling:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-test-manifest:${rootProject.extra.get("compose_version") as String}")
}
