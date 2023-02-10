buildscript {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    extra.apply{
        set("compose_version", "1.3.3")
        set("kotlinVersion", "1.7.20")
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.10")
        classpath("com.android.tools.build:gradle:7.3.0")
    }
}// Top-level build file where you can add configuration options common to all sub-projects/modules.

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}