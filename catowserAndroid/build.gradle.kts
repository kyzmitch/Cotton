buildscript {
    extra.apply{
        set("compose_version", "1.1.1")
    }
    dependencies {
        classpath("com.android.tools.build:gradle:3.2")
    }
}// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    id("com.android.application") version "7.4"
    id("com.android.library") version "7.4" apply false
    kotlin("android") version "1.8.0" apply false
    kotlin("multiplatform") version "1.8.0" apply false
}