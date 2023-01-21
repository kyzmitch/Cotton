import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

group = "org.cottonweb"
version = "0.1-SNAPSHOT"

plugins {
    kotlin("multiplatform") version "1.7.20"
    id("com.android.library") version "7.2.0"
    kotlin("plugin.serialization") version "1.7.20"
    id("com.chromaticnoise.multiplatform-swiftpackage") version "2.0.3"
    id("org.jlleitschuh.gradle.ktlint") version "10.2.1"
    id("org.jlleitschuh.gradle.ktlint-idea") version "10.2.1"
}

dependencies {
    commonMainImplementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")
    commonMainImplementation(kotlin("stdlib"))
    commonMainImplementation(kotlin("stdlib-common"))
    commonTestImplementation(kotlin("test"))
    commonTestImplementation(kotlin("test-common"))
    commonTestImplementation(kotlin("test-annotations-common"))
}

val frameworkName = "CoreHttpKit"

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
    android {
        sourceSets {
            commonMain {
                kotlin {
                    exclude ("ByteArrayNativeUtils.kt")
                }
            }
        }
    }
}

android {
    namespace = "org.cottonweb.CoreHttpKit"
    compileSdk = 32
}

multiplatformSwiftPackage {
    packageName(frameworkName)
    outputDirectory(File(projectDir, "$frameworkName"))
    swiftToolsVersion("5.7")
    targetPlatforms {
        iOS { v("13") }
        macOS { v("12.3") }
    }
}

tasks.withType<KotlinCompile>().configureEach {
    kotlinOptions.jvmTarget = "1.8"
}

configure<org.jlleitschuh.gradle.ktlint.KtlintExtension> {
    additionalEditorconfigFile.set(file(".editorconfig"))
}
