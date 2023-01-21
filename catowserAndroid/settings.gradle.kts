pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "Cotton"
include("app")
include("browser-content")
include(":CottonCoreBaseKit")
project(":CottonCoreBaseKit").projectDir = File("../CottonCoreBaseKit")