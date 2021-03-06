####### The starting point for the script is the bottom #######

###############################################################
########################## FUNCTIONS ##########################
###############################################################
function All-Command 
{
	Dependencies-Command 
	$msBuild = FindMSBuild
	$msBuildArguments = "/t:Rebuild /nr:false"
	if ($msBuild -eq $null)
	{
		echo "Unable to locate an appropriate version of MSBuild."
	}
	else
	{
		$proc = Start-Process $msBuild $msBuildArguments -NoNewWindow -PassThru -Wait
		if ($proc.ExitCode -ne 0)
		{
			echo "Build failed. If just the development tools failed to build, try installing Visual Studio. You may also still be able to run the game."
		}
		else
		{
			echo "Build succeeded."
		}
	}
}

function Clean-Command 
{
	$msBuild = FindMSBuild
	$msBuildArguments = "/t:Clean /nr:false"
	if ($msBuild -eq $null)
	{
		echo "Unable to locate an appropriate version of MSBuild."
	}
	else
	{
		$proc = Start-Process $msBuild $msBuildArguments -NoNewWindow -PassThru -Wait
		rm *.dll
		rm *.dll.config
		rm mods/*/*.dll
		rm *.pdb
		rm mods/*/*.pdb
		rm *.exe
		rm ./*/bin -r
		rm ./*/obj -r
		if (Test-Path thirdparty/download/)
		{
			rmdir thirdparty/download -Recurse -Force
		}
		echo "Clean complete."
	}
}
<<<<<<< HEAD
elseif ($command -eq "version")
=======

function Version-Command 
>>>>>>> 285e9a803067ddf8bbfee3b89f487029d6118833
{
	if ($command.Length -gt 1)
	{
		$version = $command[1]
	}
	elseif (Get-Command 'git' -ErrorAction SilentlyContinue)
	{
		$version = git name-rev --name-only --tags --no-undefined HEAD 2>$null
		if ($version -eq $null)
		{
			$version = "git-" + (git rev-parse --short HEAD)
		}
	}
	else
	{
		echo "Unable to locate Git. The version will remain unchanged."
	}

	if ($version -ne $null)
	{
<<<<<<< HEAD
		$mods = @("mods/ra/mod.yaml", "mods/ra2/mod.yaml", "mods/cnc/mod.yaml", "mods/d2k/mod.yaml", "mods/ts/mod.yaml", "mods/modchooser/mod.yaml", "mods/all/mod.yaml")
=======
		$mods = @("mods/ra/mod.yaml", "mods/cnc/mod.yaml", "mods/d2k/mod.yaml", "mods/ts/mod.yaml", "mods/modcontent/mod.yaml", "mods/all/mod.yaml")
>>>>>>> 60bc114e391dea7a3e0525b73182b6ece5921de6
		foreach ($mod in $mods)
		{
			$replacement = (gc $mod) -Replace "Version:.*", ("Version: {0}" -f $version)
			sc $mod $replacement

			$prefix = $(gc $mod) | Where { $_.ToString().EndsWith(": User") }
			if ($prefix -and $prefix.LastIndexOf("/") -ne -1)
			{
				$prefix = $prefix.Substring(0, $prefix.LastIndexOf("/"))
			}
			$replacement = (gc $mod) -Replace ".*: User", ("{0}/{1}: User" -f $prefix, $version)
			sc $mod $replacement
		}
		echo ("Version strings set to '{0}'." -f $version)
	}
}

function Dependencies-Command
{
	cd thirdparty
	./fetch-thirdparty-deps.ps1
	cp download/*.dll ..
	cp download/GeoLite2-Country.mmdb.gz ..
	cp download/windows/*.dll ..
	cd ..
	echo "Dependencies copied."
}

function Test-Command
{
	if (Test-Path OpenRA.Utility.exe)
	{
		echo "Testing mods..."
		echo "Testing Tiberian Sun mod MiniYAML..."
		./OpenRA.Utility.exe ts --check-yaml
		echo "Testing Dune 2000 mod MiniYAML..."
		./OpenRA.Utility.exe d2k --check-yaml
		echo "Testing Tiberian Dawn mod MiniYAML..."
		./OpenRA.Utility.exe cnc --check-yaml
		echo "Testing Red Alert mod MiniYAML..."
		./OpenRA.Utility.exe ra --check-yaml
		echo "Testing Red Alert 2 mod MiniYAML..."
		./OpenRA.Utility.exe ra2 --check-yaml
	}
	else
	{
		UtilityNotFound
	}
}

function Check-Command {
	if (Test-Path OpenRA.Utility.exe)
	{
		echo "Checking for explicit interface violations..."
		./OpenRA.Utility.exe all --check-explicit-interfaces
		echo "Checking for code style violations in OpenRA.Platforms.Default..."
		./OpenRA.Utility.exe cnc --check-code-style OpenRA.Platforms.Default
		echo "Checking for code style violations in OpenRA.Game..."
		./OpenRA.Utility.exe ra --check-code-style OpenRA.Game
		echo "Checking for code style violations in OpenRA.Mods.Common..."
		./OpenRA.Utility.exe ra --check-code-style OpenRA.Mods.Common
<<<<<<< HEAD
		echo "Checking for code style violations in OpenRA.Mods.RA..."
		./OpenRA.Utility.exe ra --check-code-style OpenRA.Mods.RA
		echo "Checking for code style violations in OpenRA.Mods.RA2..."
		./OpenRA.Utility.exe ra2 --check-code-style OpenRA.Mods.RA2
=======
>>>>>>> 5999a028ad591275e84d2b8264ae13fde8150006
		echo "Checking for code style violations in OpenRA.Mods.Cnc..."
		./OpenRA.Utility.exe cnc --check-code-style OpenRA.Mods.Cnc
		echo "Checking for code style violations in OpenRA.Mods.D2k..."
		./OpenRA.Utility.exe cnc --check-code-style OpenRA.Mods.D2k
		echo "Checking for code style violations in OpenRA.Utility..."
		./OpenRA.Utility.exe cnc --check-code-style OpenRA.Utility
		echo "Checking for code style violations in OpenRA.Test..."
		./OpenRA.Utility.exe cnc --check-code-style OpenRA.Test
	}
	else
	{
		UtilityNotFound
	}
}

function Check-Scripts-Command
{
	if ((Get-Command "luac.exe" -ErrorAction SilentlyContinue) -ne $null)
	{
		echo "Testing Lua scripts..."
		foreach ($script in ls "mods/*/maps/*/*.lua")
		{
			luac -p $script
		}
		foreach ($script in ls "lua/*.lua")
		{
			luac -p $script
		}
		echo "Check completed!"
	}
	else
	{
		echo "luac.exe could not be found. Please install Lua."
	}
}

function Docs-Command
{
	if (Test-Path OpenRA.Utility.exe)
	{
		./make.ps1 version
		./OpenRA.Utility.exe all --docs | Out-File -Encoding "UTF8" DOCUMENTATION.md
		./OpenRA.Utility.exe all --lua-docs | Out-File -Encoding "UTF8" Lua-API.md
	}
	else
	{
		UtilityNotFound
	}
}

function FindMSBuild
{
	$msBuildVersions = @("4.0")
	foreach ($msBuildVersion in $msBuildVersions)
	{
		$key = "HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\{0}" -f $msBuildVersion
		$property = Get-ItemProperty $key -ErrorAction SilentlyContinue
		if ($property -eq $null -or $property.MSBuildToolsPath -eq $null)
		{
			continue
		}
		$path = Join-Path $property.MSBuildToolsPath -ChildPath "MSBuild.exe"
		if (Test-Path $path)
		{
			return $path
		}
	}
	return $null
}

function UtilityNotFound
{
	echo "OpenRA.Utility.exe could not be found. Build the project first using the `"all`" command."
}
###############################################################
############################ Main #############################
###############################################################
if ($args.Length -eq 0)
{
	echo "Command list:"
	echo ""
	echo "  all             Builds the game and its development tools."
	echo "  dependencies    Copies the game's dependencies into the main game folder."
	echo "  version         Sets the version strings for the default mods to the latest"
	echo "                  version for the current Git branch."
	echo "  clean           Removes all built and copied files. Use the 'all' and"
	echo "                  'dependencies' commands to restore removed files."
	echo "  test            Tests the default mods for errors."
	echo "  check           Checks .cs files for StyleCop violations."
	echo "  check-scripts   Checks .lua files for syntax errors."
	echo "  docs            Generates the trait and Lua API documentation."
	echo ""
	$command = (Read-Host "Enter command").Split(' ', 2)
}
else
{
	$command = $args
}

switch ($command) 
{
	"all" { All-Command }
	"dependencies" { Dependencies-Command }
	"version" { Version-Command }
	"clean" { Clean-Command }
	"test" { Test-Command }
	"check" { Check-Command }
	"check-scripts" { Check-Scripts-Command }
	"docs" { Docs-Command }
	Default { echo ("Invalid command '{0}'" -f $command) }
}

#In case the script was called without any parameters we keep the window open 
if ($args.Length -eq 0)
{
	echo "Press enter to continue."
	while ($true)
	{
		if ([System.Console]::KeyAvailable)
		{
			break
		}
		Start-Sleep -Milliseconds 50
	}
}
