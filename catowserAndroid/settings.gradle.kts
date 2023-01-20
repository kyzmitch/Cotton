pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

rootProject.name = "Cotton"
include("app")
include("browser-content")
include(":CoreHttpKit")
project(":CoreHttpKit").projectDir = File("../CoreHttpKit")