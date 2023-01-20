pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "Cotton"
include("app")
include("browser-content")
// TODO: fix module path
// include("CoreHttpKit")
// project("CoreHttpKit").projectDir = File("./../CoreHttpKit")