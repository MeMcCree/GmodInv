MaxDefInvCap = 999

InvBlacklist = {}
InvWhitelist = {}

ConVars = {}
ConVars["KeepInv"]	= CreateConVar(  "inv_keepinv",    "0",    {FCVAR_ARCHIVE, FCVAR_PROTECTED},   "Keep inventory on death."     )
ConVars["SaveInv"]	= CreateConVar(  "inv_saveinv",    "0",    {FCVAR_ARCHIVE, FCVAR_PROTECTED},   "Save inventory on disconnect.")
ConVars["AnyItem"]	  = CreateConVar(  "inv_anyitem",    "0",    {FCVAR_ARCHIVE, FCVAR_PROTECTED},   "Pickup any entity type."      )