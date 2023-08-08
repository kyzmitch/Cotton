import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

val groupValue = "org.cotton.base"
val versionValue = "0.1-SNAPSHOT"
group = groupValue
version = versionValue

plugins {
    kotlin("multiplatform") version "1.7.20"
    id("com.android.library") version "7.3.0"
    kotlin("plugin.serialization") version "1.7.20"
    id("com.chromaticnoise.multiplatform-swiftpackage") version "2.0.3"
    id("org.jlleitschuh.gradle.ktlint") version "11.5.0"
    id("org.jlleitschuh.gradle.ktlint-idea") version "11.5.0"
    id("maven-publish")
}

buildscript {
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
    }
}

dependencies {
    commonMainImplementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")
    commonMainImplementation(kotlin("stdlib"))
    commonMainImplementation(kotlin("stdlib-common"))
    commonTestImplementation(kotlin("test"))
    commonTestImplementation(kotlin("test-common"))
    commonTestImplementation(kotlin("test-annotations-common"))
}

val frameworkName = "CottonBase"

kotlin {
    val xcf = XCFramework(frameworkName)
    ios {
        sourceSets {
            commonMain {
                kotlin {
                    include("**/*.kt")
                }
            }
        }
        binaries.framework {
            embedBitcode(BitcodeEmbeddingMode.BITCODE)
            baseName = frameworkName
            xcf.add(this)
        }
    }
    macosX64 {
        sourceSets {
            commonMain {
                kotlin {
                    include("**/*.kt")
                }
            }
        }
        binaries.framework {
            baseName = frameworkName
            xcf.add(this)
        }
    }
    android {
        publishLibraryVariants("release", "debug")
        sourceSets {
            commonMain {
                kotlin {
                    // Exclude doesn't work, using `expect` functions
                    // instead for each platform
                    // exclude ("ByteArrayNativeUtils.kt")
                }
            }
        }
    }
}

android {
    namespace = groupValue
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
