MaxDefInvCap = 20

InvBlacklist = {}
InvWhitelist = {}

ConVars = {}
ConVars["KeepInv"]	= CreateConVar(  "inv_keepinv",    "0",    {FCVAR_ARCHIVE, FCVAR_PROTECTED},   "Keep inventory on death."     )
ConVars["SaveInv"]	= CreateConVar(  "inv_saveinv",    "0",    {FCVAR_ARCHIVE, FCVAR_PROTECTED},   "Save inventory on disconnect.")
