#!/usr/bin/env kotlin

@file:DependsOn("info.picocli:picocli:4.7.7")

import picocli.CommandLine
import picocli.CommandLine.Command
import picocli.CommandLine.Option
import picocli.CommandLine.Parameters
import java.io.File
import kotlin.system.exitProcess

class ScriptContext {
    companion object {
        lateinit var currentDirectory: File
    }
}

ScriptContext.currentDirectory = __FILE__.absoluteFile.parentFile

class CliHelper {
    companion object {
        fun runCommand(command: List<String>, directory: File): Int {
            val commandString = command.joinToString(" ")

            println("> $commandString")
            val processBuilder: ProcessBuilder = ProcessBuilder(command)
                .directory(directory)
                .redirectOutput(ProcessBuilder.Redirect.INHERIT)
                .redirectError(ProcessBuilder.Redirect.INHERIT)

            val process: Process = processBuilder.start()

            process.waitFor()

            if (process.exitValue() != 0) {
                println("> ${process.exitValue()} exit code for $commandString")
            }

            return process.exitValue()
        }

        fun runCommandExitOnError(command: List<String>, directory: File) {
            val exitCode = runCommand(command, directory)

            if (exitCode != 0) {
                exitProcess(exitCode)
            }
        }
    }
}

@Command(
    name = "containerctl.main.kts",
    version = ["1.0.0"],
    mixinStandardHelpOptions = true,
    subcommands = [RestartCommand::class, StopCommand::class],
)
class CliApp : Runnable {

    override fun run() {
        CommandLine(CliApp()).usage(System.out)
    }

}

@Command(name = "restart")
class RestartCommand : Runnable {

    @Parameters(index = "0", description = ["Container name"])
    lateinit var name: String

    @Option(names = ["-f"], description = ["Follow startup logs."])
    var followLogs = false

    override fun run() {
        val dir = ScriptContext.currentDirectory

        CliHelper.runCommandExitOnError(listOf("docker", "compose", "pull", name), dir)
        CliHelper.runCommand(listOf("docker", "compose", "down", name), dir)
        CliHelper.runCommandExitOnError(listOf("docker", "compose", "up", "-d", name), dir)
        if (followLogs) {
            CliHelper.runCommand(listOf("docker", "logs", "-f", name), dir)
        }
    }

}

@Command(name = "stop")
class StopCommand : Runnable {

    @Parameters(index = "0", description = ["Container name"])
    lateinit var name: String

    override fun run() {
        val dir = ScriptContext.currentDirectory

        CliHelper.runCommandExitOnError(listOf("docker", "compose", "down", name), dir)
    }

}

val exitCode = CommandLine(CliApp()).execute(*args)
exitProcess(exitCode)
