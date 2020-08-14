import os, options, sequtils, streams, strutils, tables
import neverwinter/[erf, gff, resfile, resman, tlk, twoda]

template findIt*(s, pred: untyped): untyped =
  var result: Option[type(s[0])]
  for it {.inject.} in s.items:
    if result.isNone and pred:
      result = some it
  result

proc addFiles*(rm: ResMan, files: seq[string], filterExtensions = newSeq[string]()) =
  let filesToAdd =
    if filterExtensions.len == 0:
      files
    else:
      files.filterIt filterExtensions.any do (ext: string) -> bool: it.endsWith(ext)
  if filesToAdd.len > 0:
    echo "Adding files:"
    for f in filesToAdd:
      echo "  " & f
      rm.add f.newResFile

proc flatten*(list: GffList): GffList =
  for li in list:
    if li.hasField("LIST", GffList):
      result.insert li["LIST", GffList].flatten
    else:
      result &= li

proc get2da*(name: string, rm: ResMan): TwoDA =
  if rm.contains(newResRef(name, "2da".getResType)):
    result = rm[newResRef(name, "2da".getResType)].get.readAll.newStringStream.readTwoDA
  else:
    echo name & ".2da not found"
    quit(QuitFailure)

proc getDataFiles*(dataDirs: seq[string]): seq[string] =
  for dir in dataDirs:
    if not dir.dirExists:
      echo "Directory not found: " & dir
      quit(QuitFailure)
    for file in dir.joinPath("*").walkFiles:
      if file.splitFile.ext in [".2da", ".bif", ".hak", ".key", ".tlk"]:
        result &= file

proc getErf*(file, erfType: string): Erf =
  try:
    result = file.openFileStream.readErf
  except:
    echo "Could not read file. Is it a valid ERF/" & erfType.strip & " file?"
    quit(QuitFailure)
  if result.fileType != erfType:
    echo "Not a " & erfType & " file: " & result.fileType
    quit(QuitFailure)

proc getGffRoot*(resref, restype: string, module: Erf, rm: ResMan): GffRoot =
  let resref = newResRef(resref, restype.getResType)
  # get from module first, then from resman
  var gffContent = ""
  if module[resref].isSome:
    gffContent = module[resref].get.readAll
  elif rm[resref].isSome:
    gffContent = rm[resref].get.readAll
  else:
    echo "Error: GFF " & $resref & " not found."
    quit(QuitFailure)
  gffContent.newStringStream.readGffRoot

proc tlkText*(strref: StrRef, dlg: SingleTlk, tlk: Option[SingleTlk]): string =
  if strref < 0x01_000_000:
    if dlg[strref].isSome:
      return dlg[strref].get.text
  elif tlk.isSome:
    let entry = tlk.get[strref - 0x01_000_000]
    if entry.isSome:
      return entry.get.text

proc tlkText*(strref: string, dlg: SingleTlk, tlk: Option[SingleTlk]): string =
  tlkText(strref.parseInt.StrRef , dlg, tlk)

proc getStr*(locstr: GffCExoLocString, dlg: SingleTlk, tlk: Option[SingleTlk]): string =
  if locstr.strRef != BadStrRef:
    return locstr.strRef.tlkText(dlg, tlk)
  if locstr.entries.hasKey(dlg.language.ord):
    return locstr.entries[dlg.language.ord]
  if locstr.entries.hasKey(Language.English.ord):
    return locstr.entries[Language.English.ord]
  for value in locstr.entries.values:
    if value != "": return value
