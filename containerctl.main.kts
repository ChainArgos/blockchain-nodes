#!/usr/bin/env kotlin

@file:DependsOn("info.picocli:picocli:4.7.6")

import picocli.CommandLine
import picocli.CommandLine.Command
import picocli.CommandLine.Option
import picocli.CommandLine.Parameters
import java.nio.charset.Charset
import kotlin.system.exitProcess

val charset: Charset = Charset.forName("UTF-8")

class CliHelper {
    companion object {
        fun runCommand(command: List<String>): Int {
            val commandString = command.joinToString(" ")

            println("> $commandString")
            val processBuilder: ProcessBuilder = ProcessBuilder(command)
                .redirectOutput(ProcessBuilder.Redirect.INHERIT)
                .redirectError(ProcessBuilder.Redirect.INHERIT)

            val process: Process = processBuilder.start()

            process.waitFor()

            if (process.exitValue() != 0) {
                println("> ${process.exitValue()} exit code for $commandString")
            }

            return process.exitValue()
        }

        fun runCommandExitOnError(command: List<String>) {
            val exitCode = runCommand(command)

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
        CliHelper.runCommandExitOnError(listOf("docker", "compose", "pull", name))
        CliHelper.runCommand(listOf("docker", "compose", "down", name))
        CliHelper.runCommandExitOnError(listOf("docker", "compose", "up", "-d", name))
        if (followLogs) {
            CliHelper.runCommand(listOf("docker", "logs", "-f", name))
        }
    }

}

@Command(name = "stop")
class StopCommand : Runnable {

    @Parameters(index = "0", description = ["Container name"])
    lateinit var name: String

    override fun run() {
        CliHelper.runCommandExitOnError(listOf("docker", "compose", "down", name))
    }

}

val exitCode = CommandLine(CliApp()).execute(*args)
exitProcess(exitCode)
