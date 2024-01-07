plugins {
    id("com.android.application")
    kotlin("android")
    id("org.jlleitschuh.gradle.ktlint")
    id("com.google.devtools.ksp") // for `Room` db framework instead of `kotlin-kapt`
}

android {
    namespace = "org.cotton.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "org.cotton"
        minSdk = 24
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
        javaCompileOptions {
            annotationProcessorOptions {
                arguments += mapOf(
                    "room.schemaLocation" to "$projectDir/schemas",
                    "room.incremental" to "true"
                )
            }
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

dependencies {
    implementation(project(mapOf("path" to ":browser-content")))
    implementation("org.cotton.base:cotton-base:0.1-SNAPSHOT")

    val lifecycle_version = rootProject.extra.get("lifecycle_version") as String
    val android_x_activity = rootProject.extra.get("android_x_activity") as String
    val compose_version = rootProject.extra.get("compose_version") as String
    val android_x_navigation = rootProject.extra.get("android_x_navigation") as String
    val android_x_core_ktx = rootProject.extra.get("android_x_core_ktx") as String
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:$lifecycle_version")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:$lifecycle_version")
    implementation("androidx.core:core-ktx:$android_x_core_ktx")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:$lifecycle_version")
    implementation("androidx.activity:activity-compose:$android_x_activity")
    implementation("androidx.activity:activity-ktx:$android_x_activity")
    implementation("androidx.compose.ui:ui:$compose_version")
    implementation("androidx.compose.ui:ui-tooling-preview:$compose_version")
    implementation("androidx.compose.material:material:1.5.4")
    implementation("androidx.navigation:navigation-runtime-ktx:$android_x_navigation")
    implementation("androidx.navigation:navigation-compose:$android_x_navigation")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:$compose_version")
    debugImplementation("androidx.compose.ui:ui-tooling:$compose_version")
    debugImplementation("androidx.compose.ui:ui-test-manifest:$compose_version")

    val room_version = rootProject.extra.get("room_version") as String
    implementation("androidx.room:room-runtime:$room_version")
    ksp("androidx.room:room-compiler:$room_version") /// `ksp` is better than `kapt`
    implementation("androidx.room:room-ktx:$room_version")
}
