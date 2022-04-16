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
    kotlin("multiplatform") version "1.6.10"
    id("com.chromaticnoise.multiplatform-swiftpackage") version "2.0.3"
    id("org.jlleitschuh.gradle.ktlint") version "10.2.1"
    id("org.jlleitschuh.gradle.ktlint-idea") version "10.2.1"
}

// https://kotlinlang.org/docs/multiplatform-add-dependencies.html#library-shared-for-all-source-sets
// next section could be moved to the kotlin section

val ktor_version: String by project
dependencies {
    commonMainImplementation("io.ktor:ktor-client-core:$ktor_version")
    commonMainImplementation("io.ktor:ktor-client-cio:$ktor_version")
}

multiplatformSwiftPackage {
    swiftToolsVersion("5.3")
    targetPlatforms {
        iOS { v("13") }
    }
}

// https://kotlinlang.org/docs/mpp-build-native-binaries.html#build-xcframeworks

kotlin {
    val frameworkName = "CoreHttpKit"
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
