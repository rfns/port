#include %occStatus
#include %occMessages
#include %occErrors

#include portmd

#define NULL                             $s($$$isWINDOWS : "//./nul", 1: "/dev/null")
#define PathTypes                        $listbuild("inc", "int", "cls", "mac", "mvi", "mvb", "bas", "public", "dfi")
#define ImportTypes                      $listbuild("INC", "INT", "CLS", "MAC", "MVI", "MVB", "BAS", "CSR", "CSP")
#define ImportTypeDescriptions           $listbuild("include files", "intermediate routines", "classes", "macro routines",  "MV Intermediate routines", "MV Basic routines", "Basic routines", "DFI XML", "CSP Rules", "files")
#define RoutineExtensions                $listbuild(".MAC", ".INT", ".INC", ".MVB", ".MVI", ".BAS", ".DFI")
#define RoutineGroups                   "MAC,INT,INC,MVB,MVI,BAS,DFI"
#define IsRoutine(%type)                 ($$$RoutineGroups[%type)
#define GetTypeDescription(%type)        $select($$$IsRoutine(%type)=1:$$$RoutineType,(%type = "CLS"):$$$ClassType,(%type = "PRJ"):$$$ProjectType,1:$$$FileType)
#define GetGroupTypeDescription(%type)   $case(%type,"MAC":$$$MACGroupType,"INC":$$$INCGroupType,"INT":$$$INTGroupType,"BAS":$$$BASGroupType,"MVB":$$$MVBGroupType,"MVI":$$$MVIGroupType,"DFI":$$$DFIGroupType,"CLS":$$$CLSGroupType,:$$$FileGroupType)
#def1arg PERROR(%errorArgs)              $$$ERROR($$$GeneralError, $$$FormatMsg("Port Errors", %errorArgs))
#def1arg FormatWizardMsg(%args)          $$$FormatMsg("Port Configuration Wizard", %args)
#define RemoveClassExtension(%iname)     $select($piece(%iname, ".", $$$ucase(%iname), *) [ "CLS" :  $piece(%iname, ".", 1, *-1), 1: %iname)
#define Slash(%path)                     $select($$$IsRemoteAware : $select(%path [ "\" : "\", 1: "/"), 1: $$$OSSlash)
#define OSSlash                          $select($$$isWINDOWS : "\", 1: "/")
#define OSFromSlash(%path)               $select(%path [ "\" : 2, 1: 3)
#define PathSlash(%path)                 $select(%path [ "\" : "\", 1: "/")
#define NFN(%path)                       $select($$$IsRemoteAware : ##class(Port.Util).TranslatePath(%path, $$$OSFromSlash(%path)), 1: ##class(Port.Util).TranslatePath(%path))
#define IsRemoteAware                    $get(^||Port.Internals.Configuration("remote")) = 1
#define LTrimSlash(%p)                   $s($e(%p) = $$$Slash(%p) : $e(%p, 2, *), 1: %p)
#define RTrimSlash(%p)                   $s($e(%p, *) = $$$Slash(%p) : $e(%p, 1, *-1), 1: %p)
#define LTrimProvidedSlash(%p, %slash)   $s($e(%p) = %slash : $e(%p, 2, *), 1: %p)
#define RTrimProvidedSlash(%p, %slash)   $s($e(%p, *) = %slash : $e(%p, 1, *-1), 1: %p)
#define LPadSlash(%p)                    $s($e(%p) '= $$$Slash(%p) : $$$Slash(%p)_%p, 1: %p)
#define RPadSlash(%p)                    $s($e(%p, *) '= $$$Slash(%p) : %p_$$$Slash(%p), 1: %p)
#define LPadProvidedSlash(%p, %slash)    $s($e(%p) '= %slash : %slash_%p, 1: %p)
#define RPadProvidedSlash(%p, %slash)    $s($e(%p, *) '= %slash : %p_%slash, 1: %p)
