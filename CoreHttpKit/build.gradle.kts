import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode

plugins {
    kotlin("multiplatform") version "1.6.10"
}

group = "org.cottonweb"
version = "0.1-SNAPSHOT"

repositories {
    mavenCentral()
}

// https://kotlinlang.org/docs/mpp-build-native-binaries.html#build-xcframeworks

kotlin {
    val xcf = XCFramework()
    val frameworkName = "CoreHttpKit"
    ios {
        binaries.framework {
            embedBitcode(BitcodeEmbeddingMode.BITCODE)
            baseName = frameworkName
            xcf.add(this)
        }
    }
}
