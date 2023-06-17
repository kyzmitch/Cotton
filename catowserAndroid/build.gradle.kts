buildscript {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    extra.apply{
        set("compose_version", "1.3.3")
        set("ktor_version", "2.2.3")
        set("lifecycle_version", "2.5.1")
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10")
        classpath("com.android.tools.build:gradle:7.3.0")
    }
} // Top-level build file where you can add configuration options common to all sub-projects/modules.

// Jetpack Lifecycle of version 2.5.1 uses Kotlin 1.7.20 which we need
// https://developer.android.com/jetpack/androidx/releases/lifecycle#2.5.1

plugins {
    kotlin("android") version "1.7.20" apply false
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}