allprojects {
    repositories {
        google()
        mavenCentral()
    }
    buildscript {
        configurations.all {
            resolutionStrategy.eachDependency {
                if (requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin") {
                    useVersion("2.1.0")
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.core") {
                useVersion("1.13.1")
            }
            if (requested.group == "androidx.appcompat") {
                useVersion("1.7.0")
            }
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.1.0")
            }
        }
    }

    fun applyNamespaceFallback() {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android")
            try {
                // Using reflection to be safe across different AGP versions
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                var extractedPackage: String? = null
                
                // 1. Try to extract from manifest first
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    val packageRegex = Regex("package=\"([^\"]+)\"")
                    val match = packageRegex.find(content)
                    extractedPackage = match?.groupValues?.get(1)
                    
                    if (content.contains("package=\"")) {
                        println("Torcav: Stripping package attribute from ${project.name}'s manifest...")
                        val updatedContent = content.replace(Regex("\\s+package=\"[^\"]*\""), "")
                        manifestFile.writeText(updatedContent)
                    }
                }

                // 2. If manifest fails (already stripped), crawl source files for 'package [NAME]'
                if (extractedPackage == null) {
                    val srcDir = project.file("src/main")
                    if (srcDir.exists()) {
                        srcDir.walkTopDown().filter { it.extension == "kt" || it.extension == "java" }.forEach { file ->
                            if (extractedPackage == null) {
                                val fileContent = file.readText()
                                // Find package declaration, skip generic ones like 'com.foregroundservice' 
                                // that sometimes appear in sub-files of messy plugins
                                val pkgMatch = Regex("^package\\s+([^\\s;]+)", RegexOption.MULTILINE).find(fileContent)
                                val found = pkgMatch?.groupValues?.get(1)
                                if (found != null && found != "com.foregroundservice") {
                                    extractedPackage = found
                                }
                            }
                        }
                    }
                }

                if (getNamespace.invoke(android) == null) {
                    val finalNamespace = extractedPackage ?: "com.torcav.${project.name.replace("_", ".").replace("-", ".")}"
                    println("Torcav: Setting namespace for ${project.name} to: $finalNamespace")
                    setNamespace.invoke(android, finalNamespace)
                }
            } catch (e: Exception) {
                println("Torcav: Error applying namespace to ${project.name}: ${e.message}")
            }
        }
    }

    if (project.state.executed) {
        applyNamespaceFallback()
    } else {
        project.afterEvaluate {
            applyNamespaceFallback()
            
            // Deep Path for specific broken plugins
            if (project.name == "flutter_screen_recording") {
                println("Torcav: Injecting missing dependencies into ${project.name}...")
                project.dependencies.add("implementation", "androidx.core:core-ktx:1.13.1")
                
                val srcDir = project.file("src/main/kotlin")
                if (srcDir.exists()) {
                    srcDir.walkTopDown().filter { it.name == "ForegroundService.kt" }.forEach { file ->
                        val content = file.readText()
                        if (content.contains("R.drawable.icon")) {
                            println("Torcav: Deep-patching broken resource reference in ${file.name}...")
                            file.writeText(content.replace("R.drawable.icon", "android.R.drawable.ic_dialog_info"))
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
