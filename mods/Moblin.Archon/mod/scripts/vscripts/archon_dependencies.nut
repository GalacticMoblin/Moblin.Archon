global function Archon_CheckDependencies

struct
{
    string currentMod
    string currentDependency
    string currentURL
} file

void function Archon_CheckDependencies()
{
    #if ARCHON_HAS_TITANFRAMEWORK

    #elseif UI
        Archon_CreateDependencyDialog( "Moblin.Archon", "Peepee.TitanFramework", "https://northstar.thunderstore.io/package/The_Peepeepoopoo_man/Titanframework/" )
    #endif
}

void function Archon_CreateDependencyDialog( string mod, string dependency, string url )
{
    file.currentMod = mod
    file.currentDependency = dependency
    file.currentURL = url
    DialogData dialogData
    dialogData.forceChoice = true
    dialogData.header = Localize("#MISSING_DEPENDENCY_HEADER")
    dialogData.image = $"ui/menu/common/dialog_error"

    array<ModInfo> mods = NSGetModInformation(dependency)
    // mod is installed but disabled
    if ( mods.len() > 0 )
    {
        dialogData.message = Localize( "#MISSING_DEPENDENCY_BODY_DISABLED", mod, dependency )
        AddDialogButton( dialogData, Localize("#ENABLE_MOD", dependency), Archon_EnableMod )
    }
    else
    {
        dialogData.message = Localize( "#MISSING_DEPENDENCY_BODY_INSTALL", mod, dependency, url )
        AddDialogButton( dialogData, "#OPEN_THUNDERSTORE", Archon_InstallMod )
    }

    AddDialogButton( dialogData, Localize("#DISABLE_MOD", mod), Archon_DisableMod )
    AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	OpenDialog( dialogData )
}

void function Archon_EnableMod()
{
    NSSetModEnabled( file.currentDependency, true )
    ReloadMods()
}

void function Archon_InstallMod()
{
    LaunchExternalWebBrowser(file.currentURL, WEBBROWSER_FLAG_FORCEEXTERNAL)
    ReloadMods()
}

void function Archon_DisableMod()
{
    NSSetModEnabled( file.currentMod, false )
    ReloadMods()
}
