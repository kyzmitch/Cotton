buildscript {
    extra.apply{
        set("compose_version", "1.1.1")
    }
}// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    id("com.android.application") version "7.0.2" apply false
    id("com.android.library") version "7.0.2" apply false
    kotlin("android") version "1.8.0" apply false
    kotlin("multiplatform") version "1.8.0" apply false
}
