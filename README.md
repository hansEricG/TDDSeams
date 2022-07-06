# TDDSeams PowerShell Module

TDDSeams is a PowerShell module aiming to make it easier for programmers to write PowerShell code using Test Driven Develpment techniques. It complements PowerShell testing frameworks such as [Pester](https://github.com/pester/Pester) by providing small wrapper functions that make it possible to mock things in PowerShell that aren't easily mockable.

## Installation
The easiest way to install TDDSeams is to use the `Install-Module` command in PowerShell.

Open a PowerShell terminal in Administrator mode and enter the following command.

```
Install-Module TDDSeams
```

## Usage
The typical example of a function that cannot be mocked using Pester is the built in ShouldProcess feature. 

```
function Do-SomeOperation {
    [CmdletBinding(ShouldProcess)]

    if ($PSCmdlet.ShouldProcess("Some Target", 'Some Operation')) {
        # Perform operation
    } 
}
```

It's a very useful function, the problem is that it may prompt the user for consent before performing the task. This is of course not good in an automated test scenario so we want to be able to mock it. To do that, we have to write a command that wraps the ShouldProcess call. 
This is what the `Invoke-TDDShouldProcess` command does. So, instead of the above code, we can write our function like this:

```
function Do-SomeOperation {
    [CmdletBinding(ShouldProcess)]

    if (Invoke-TDDShouldProcess -Context $PSCmdlet -Target "Target" -Action "Action") {
        # Performa operation
    }
}
```

And mock it in a Pester test, like this:

```
It 'Should invoke ShouldProcess' {
    Mock Invoke-TDDSShouldProcess -ModuleName TDDSeams { $True }

    Do-SomeOperation $SomeTarget

    Should | -Invoke Invoke-TDDShouldProcess -ModuleName TDDSeams -Times 1 -Exactly
}
```

However, [the best practise implementation of the PowerShell ShouldProcess](https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess) requires a bit more than just invoking the ShouldProcess method on the context object. E.g. it's recommended that you implement a -Force flag and tampering with the ConfirmPreference variable. The `Invoke-TDDShouldProcessCode` command takes care of all this for you.

So, it's recommended that you write your ShouldProcess aware commands like this instead:

```
function Remove-Something {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [switch]$Force
    )

    Invoke-TDDShouldProcessCode -Context $PSCmdlet -Target 'Something' -Operation 'Permanently remove' -Force:$Force -Code {
        # Code to perform the destructive operation
    }
}
```

The `Invoke-TDDShouldProcessCode` invokes the `Invoke-TDDShouldProcess` command internally, so the Pester tests can be written in the same way as shown before (mocking the `Invoke-TDDShouldProcess` command).

## Credits

# Pester
I have to give a shoutout to the amazing [Pester project](https://github.com/pester/Pester). It's the absolutly best tool to ensure your PowerShell code does what you intended. It's super easy and intuitive to get started with, and if you get into the habit of writing those tests first, you get all the benefits of Test Driven Development.

# Kevin Marquette
[Kevin Marquette](https://github.com/KevinMarquette)'s wonderful blog post [Powershell: Everything you wanted to know about ShouldProcess](https://powershellexplained.com/2020-03-15-Powershell-shouldprocess-whatif-confirm-shouldcontinue-everything) is a must read if you want to know the ins and outs of the ShouldProcess and ShouldContinue features of PowerShell.

# Adam Driscoll
Big thank you to [Adam Driscoll](https://github.com/adamdriscoll) whos [How to Publish a PowerShell Module to the PowerShell Gallery tutorial video](https://www.youtube.com/watch?v=TdWWUOJ4s7A) helped a lot when i decided to make TDDUtils publicly available.
 
