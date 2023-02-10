plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    namespace = "com.cotton"
    compileSdk = 33

    defaultConfig {
        applicationId = "com.cotton"
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

dependencies {
    implementation(project(mapOf("path" to ":browser-content")))
    implementation("org.cotton.base:CottonCoreBaseKit:0.1-SNAPSHOT")
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.3.1")
    implementation("androidx.activity:activity-compose:1.3.1")
    implementation("androidx.compose.ui:ui:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.ui:ui-tooling-preview:${rootProject.extra.get("compose_version") as String}")
    implementation("androidx.compose.material:material:1.1.1")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-tooling:${rootProject.extra.get("compose_version") as String}")
    debugImplementation("androidx.compose.ui:ui-test-manifest:${rootProject.extra.get("compose_version") as String}")
}