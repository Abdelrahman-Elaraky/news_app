allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    // Optional: Change the build directory per subproject (if really needed)
    buildDir = file("../build/${project.name}")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
