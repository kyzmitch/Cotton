import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

group = "org.cottonweb"
version = "0.1-SNAPSHOT"

repositories {
    mavenCentral()
}

// https://kotlinlang.org/docs/multiplatform-discover-project.html#multiplatform-plugin
// https://github.com/ge-org/multiplatform-swiftpackage

plugins {
    kotlin("multiplatform")
    id("com.android.library")
    kotlin("plugin.serialization") version "1.7.20"
    id("com.chromaticnoise.multiplatform-swiftpackage") version "2.0.3"
    id("org.jlleitschuh.gradle.ktlint") version "10.2.1"
    id("org.jlleitschuh.gradle.ktlint-idea") version "10.2.1"
}

// https://kotlinlang.org/docs/multiplatform-mobile-ios-dependencies.html#workaround-to-enable-ide-support-for-the-shared-ios-source-set

// https://kotlinlang.org/docs/multiplatform-add-dependencies.html#library-shared-for-all-source-sets
// next section could be moved to the kotlin section

// https://github.com/Kotlin/kotlinx.serialization#setup
dependencies {
    commonMainImplementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")
    /**
     * A dependency on a standard library (stdlib) in each source set is added automatically.
     * The version of the standard library is the same as the version of the kotlin-multiplatform plugin.
     *
     * https://kotlinlang.org/docs/multiplatform-add-dependencies.html#standard-library
     * */
    commonMainImplementation(kotlin("stdlib"))
    commonMainImplementation(kotlin("stdlib-common"))
    // https://kotlinlang.org/docs/gradle.html#set-dependencies-on-test-libraries
    // JUNIT is only for java code used in kotlin or something like that
    commonTestImplementation(kotlin("test"))
    commonTestImplementation(kotlin("test-common"))
    commonTestImplementation(kotlin("test-annotations-common"))
}

/**
 * was forced to up the macOS version to 11, because original
 * `10.15` - format with a dot is not supported and
 * produces the wrong Package.swift
 *
 * And it didn't help, https://github.com/ge-org/multiplatform-swiftpackage/issues/33
 * */

val frameworkName = "CoreHttpKit"
multiplatformSwiftPackage {
    packageName(frameworkName)
    outputDirectory(File(projectDir, "$frameworkName"))
    swiftToolsVersion("5.7")
    targetPlatforms {
        iOS { v("13") }
        macOS { v("12.3") }
    }
}

// https://kotlinlang.org/docs/mpp-build-native-binaries.html#build-xcframeworks

kotlin {
    val xcf = XCFramework(frameworkName)
    ios {
        binaries.framework {
            embedBitcode(BitcodeEmbeddingMode.BITCODE)
            baseName = frameworkName
            xcf.add(this)
        }
    }
    macosX64 {
        binaries.framework {
            baseName = frameworkName
            xcf.add(this)
        }
    }
    android()
}

// config JVM target to 1.8 for kotlin compilation tasks
tasks.withType<KotlinCompile>().configureEach {
    kotlinOptions.jvmTarget = "1.8"
}

configure<org.jlleitschuh.gradle.ktlint.KtlintExtension> {
    additionalEditorconfigFile.set(file(".editorconfig"))
}

android {
    namespace = "org.cottonweb.CoreHttpKit"
    compileSdk = 32
}
