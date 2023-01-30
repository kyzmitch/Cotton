import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

val groupValue = "org.cotton.base"
val versionValue = "0.1-SNAPSHOT"
group = groupValue
version = versionValue

plugins {
    kotlin("multiplatform") version "1.8.0"
    id("com.android.library") version "7.0.2"
    kotlin("plugin.serialization") version "1.8.0"
    id("com.chromaticnoise.multiplatform-swiftpackage") version "2.0.3"
    id("org.jlleitschuh.gradle.ktlint") version "10.2.1"
    id("org.jlleitschuh.gradle.ktlint-idea") version "10.2.1"
    id("maven-publish")
}

dependencies {
    commonMainImplementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")
    commonMainImplementation(kotlin("stdlib"))
    commonMainImplementation(kotlin("stdlib-common"))
    commonTestImplementation(kotlin("test"))
    commonTestImplementation(kotlin("test-common"))
    commonTestImplementation(kotlin("test-annotations-common"))
}

val frameworkName = "CottonCoreBaseKit"

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
    namespace = groupValue
    compileSdk = 32
}

buildscript {
    dependencies {
        classpath("com.android.tools.build:gradle:3.2")
    }
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

// https://docs.gradle.org/current/userguide/publishing_maven.html#publishing_maven:install
// only Android platform needed in maven local
publishing {
    publications {
        create<MavenPublication>("maven") {
            groupId = groupValue
            artifactId = groupValue
            version = versionValue

            pom {
                name.set("Cotton CoreBaseKit")
                description.set("It is not possible to include it by local path, so, including over maven local repo")
            }
        }
    }
}