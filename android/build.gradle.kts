import com.android.build.gradle.internal.crash.afterEvaluate

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    afterEvaluate{ project ->
        if(project.hasProperty("android")){
            val androidExtension = project.extensions.findByName("android")
            if(androidExtension != null){
                val android = androidExtension as com.android.build.gradle.BaseExtension
                if(android.namespace == null){
                    android.namespace = "${project.group}"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
