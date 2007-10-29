#region License
/* ****************************************************************************
 * Copyright (c) Llewellyn Pritchard. 
 *
 * This source code is subject to terms and conditions of the Microsoft Public License. 
 * A copy of the license can be found in the License.html file at the root of this distribution. 
 * By using this source code in any fashion, you are agreeing to be bound by the terms of the 
 * Microsoft Public License.
 *
 * You must not remove this notice, or any other, from this software.
 * ***************************************************************************/
#endregion

using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Scripting.Hosting;
using Microsoft.Scripting;

namespace IronScheme.Hosting
{
  public class IronSchemeConsoleHost : ConsoleHost
  {
    public IronSchemeConsoleHost()
    {
       ScriptDomainManager.Options.AssemblyGenAttributes |=

        Microsoft.Scripting.Generation.AssemblyGenAttributes.EmitDebugInfo |
        Microsoft.Scripting.Generation.AssemblyGenAttributes.GenerateDebugAssemblies

#if DEBUG
        | Microsoft.Scripting.Generation.AssemblyGenAttributes.DisableOptimizations |
        //Microsoft.Scripting.Generation.AssemblyGenAttributes.VerifyAssemblies|
         Microsoft.Scripting.Generation.AssemblyGenAttributes.SaveAndReloadAssemblies
#endif
      ;

      ScriptDomainManager.Options.DynamicStackTraceSupport = false;
    }

    protected override void Initialize()
    {
      base.Initialize();
      this.Options.LanguageProvider = ScriptEnvironment.GetEnvironment().GetLanguageProvider(typeof(IronSchemeLanguageProvider));

    }

    protected override void PrintLogo()
    {
      Console.WriteLine(string.Format("IronScheme {0} http://www.codeplex.com/IronScheme Copyright � leppie 2007", 
      typeof(IronSchemeConsoleHost).Assembly.GetName().Version), Microsoft.Scripting.Shell.Style.Out);
      //Console.WriteLine("Ctrl+Z (or F6) then Enter to quit. On error, hit Enter to return to prompt.");
    }

    protected override void PrintHelp()
    {
      base.PrintHelp();
    }

    protected override void UnhandledException(IScriptEngine engine, Exception e)
    {
      base.UnhandledException(engine, e);
      Console.ReadLine();
    }
  }
}