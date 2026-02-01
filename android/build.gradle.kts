
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory configuration
// This moves build outputs to the Flutter project root for better organization
// However, this can cause issues with Flutter CLI expecting default locations
// Keeping this commented out for now to ensure compatibility with Android Studio
/*
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
*/

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
