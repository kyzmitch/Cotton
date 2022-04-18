import org.jetbrains.kotlin.gradle.plugin.mpp.BitcodeEmbeddingMode
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

group = "org.cottonweb"
version = "0.1-SNAPSHOT"

repositories {
    mavenCentral()
}

// https://kotlinlang.org/docs/multiplatform-discover-project.html#multiplatform-plugin
// https://github.com/ge-org/multiplatform-swiftpackage

plugins {
    kotlin("multiplatform") version "1.6.20"
    kotlin("plugin.serialization") version "1.6.20"
    id("com.chromaticnoise.multiplatform-swiftpackage") version "2.0.3"
    id("org.jlleitschuh.gradle.ktlint") version "10.2.1"
    id("org.jlleitschuh.gradle.ktlint-idea") version "10.2.1"
}

// https://kotlinlang.org/docs/multiplatform-mobile-ios-dependencies.html#workaround-to-enable-ide-support-for-the-shared-ios-source-set

// https://kotlinlang.org/docs/multiplatform-add-dependencies.html#library-shared-for-all-source-sets
// next section could be moved to the kotlin section

// https://github.com/Kotlin/kotlinx.serialization#setup

val ktorVersion: String by project
dependencies {
    commonMainImplementation("io.ktor:ktor-client-core:$ktorVersion")
    commonMainImplementation("io.ktor:ktor-client-cio:$ktorVersion")
    commonMainImplementation("io.ktor:ktor-client-content-negotiation:$ktorVersion")
    commonMainImplementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.3.2")
}

val frameworkName = "CoreHttpKit"

multiplatformSwiftPackage {
    packageName(frameworkName)
    outputDirectory(File(projectDir, "$frameworkName"))
    swiftToolsVersion("5.3")
    targetPlatforms {
        iOS { v("13") }
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
}

tasks.wrapper {
    gradleVersion = "6.7.1"
    distributionType = Wrapper.DistributionType.ALL
}

configure<org.jlleitschuh.gradle.ktlint.KtlintExtension> {
    additionalEditorconfigFile.set(file(".editorconfig"))
}