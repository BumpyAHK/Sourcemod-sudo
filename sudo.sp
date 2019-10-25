
#include <sourcemod>

#pragma semicolon 1
#define PLUGIN_VERSION "1.0.0.4"

public Plugin myinfo =
{
    name = "sudo",
    author = "dubbeh ; Bumpy", //original by dubbeh, updated by Bumpy <3
    description = "Execute commands on clients for SourceMod",
    version = PLUGIN_VERSION,
    url = ""
};


public OnPluginStart()
{
    CreateConVar("sm_sudo_version", PLUGIN_VERSION, "sudo version", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
    /* register the sm_cexec console command */
    RegAdminCmd("sm_sudo", ClientExec, ADMFLAG_RCON);
}

public Action ClientExec(client, args)
{
    char szClient[MAX_NAME_LENGTH] = "";
    char szCommand[80] = "";
    static iClient = -1, iMaxClients = 0;

    iMaxClients = MaxClients;

    if(args == 2)
    {
        GetCmdArg(1, szClient, sizeof(szClient));
        GetCmdArg(2, szCommand, sizeof(szCommand));

        if(!strcmp(szClient, "#all", false))
        {
            for(iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if(IsClientConnected(iClient) && IsClientInGame(iClient))
                {
                    if(IsFakeClient (iClient))
                        FakeClientCommand(iClient, szCommand);
                    else
                        ClientCommand(iClient, szCommand);
                }
            }
        }
        else if(!strcmp (szClient, "#bots", false))
        {
            for(iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected(iClient) && IsClientInGame(iClient) && IsFakeClient(iClient))
                    FakeClientCommand(iClient, szCommand);
            }
        }
        else if((iClient = FindTarget(client, szClient, false, true)) != -1)
        {
            if (IsFakeClient(iClient))
                FakeClientCommand(iClient, szCommand);
            else
                ClientCommand(iClient, szCommand);
        }
    }
    else
    {
        ReplyToCommand(client, "sm_sudo invalid format");
        ReplyToCommand(client, "Usage: sm_sudo \"<user>\" \"<command>\"");
    }

    return Plugin_Handled;
}
