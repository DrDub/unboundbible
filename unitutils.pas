unit UnitUtils;

interface

uses
  Classes, SysUtils, Graphics, FileUtil, Zipper, UnitLib;

const
  ApplicationName = 'Unbound Bible';
  ApplicationVersion = '5.4';
  ModulesDirectory = 'modules';
  LangDirectory = 'localization';
  Untitled = 'Untitled';
  RecentMax = 10;

var
  ApplicationUpdate : boolean = false;

function DataPath: string;
function DatabaseList: TStringArray;
function ConfigFile: string;
function ModulesFile: string;
function HistoryFile: string;

function HomeURL: string;
function DownloadsURL: string;
function IssueURL: string;
function DonateURL: string;
function BibleHubURL(book, chapter, number: integer): string;

procedure CreateDataDirectory;
procedure RemoveOldFiles;
procedure UnzipDefaultsFiles;

implementation

uses UnitLocal;

const
  BibleHubArray : array [1..66] of string = (
    'genesis','exodus','leviticus','numbers','deuteronomy','joshua','judges','ruth','1_samuel','2_samuel',
    '1_kings','2_kings','1_chronicles','2_chronicles','ezra','nehemiah','esther','job','psalms','proverbs',
    'ecclesiastes','songs','isaiah','jeremiah','lamentations','ezekiel','daniel','hosea','joel','amos',
    'obadiah','jonah','micah','nahum','habakkuk','zephaniah','haggai','zechariah','malachi','matthew',
    'mark','luke','john','acts','romans','1_corinthians','2_corinthians','galatians','ephesians','philippians',
    'colossians','1_thessalonians','2_thessalonians','1_timothy','2_timothy','titus','philemon','hebrews',
    'james','1_peter','2_peter','1_john','2_john','3_john','jude','revelation'
    );

function DataPath: string;
begin
  Result := GetUserDir + ApplicationName;
end;

function DatabaseList: TStringArray;
var
  s, item : string;
const
  ext : array [1..4] of string = ('.unbound','.bbli','.mybible','.SQLite3');
begin
  Result := [];
  for item in GetFileList(DataPath, '*.*') do
    for s in ext do
      if Suffix(s, item) then Result.Add(item);
end;

function GetUnboundBiblesList: TStringArray;
begin
  Result := GetFileList(DataPath, '*.bbl.unbound');
end;

function ConfigPath: string;
begin
  {$ifdef windows} Result := LocalAppDataPath + ApplicationName;  {$endif}
  {$ifdef unix}    Result := GetUserDir + '.config/unboundbible'; {$endif}
end;

function ConfigFile: string;
begin
  Result := ConfigPath + Slash + 'config.ini';
end;

function ModulesFile: string;
begin
  Result := ConfigPath + Slash + 'modules.ini';
end;

function HistoryFile: string;
begin
  Result := ConfigPath + Slash + 'history.ini';
end;

function ru: string;
begin
  Result := '';
  if (Localization.id = 'ru') or (Localization.id = 'uk') then Result := 'ru';
end;

function HomeURL: string;
begin
  Result := 'https://unboundbible.net/' + ru;
end;

function DownloadsURL: string;
begin
  Result := 'https://unboundbible.net/goto/ubdownload' + ru + '.php';
end;

function IssueURL: string;
begin
  Result := 'https://unboundbible.net/goto/contact' + ru + '.php'
end;

function DonateURL: string;
begin
  Result := 'https://unboundbible.net/goto/donate' + ru + '.php'
end;

function BibleHubURL(book, chapter, number: integer): string;
begin
  if not (book in [1..66]) then Exit('');
  Result := 'http://biblehub.com/interlinear/' + BibleHubArray[book] + '/';
  Result += ToStr(chapter) + '-' + ToStr(number) + '.htm';
end;

procedure CreateDataDirectory;
begin
  if not DirectoryExists(DataPath) then ForceDirectories(DataPath);
end;

procedure RemoveOldFiles;
var
  f, t : string;
const
  OldFiles : array [1..5] of string = (
    'kjv+.unbound',
    'kjv.unbound',
    'rst+.unbound',
    'rstw.unbound',
    'ubio.unbound');
begin
  if not ApplicationUpdate then Exit;
  for f in OldFiles do
    begin
      t := DataPath + Slash + f;
      if FileExists(t) then DeleteFile(t);
    end;
end;

procedure UnzipDefaultsFiles;
var
  UnZipper: TUnZipper;
  List : TStringArray;
  f, d : string;
  empty : boolean;
begin
  if not DirectoryExists(DataPath) then ForceDirectories(DataPath);

  empty := GetUnboundBiblesList.IsEmpty;
  if not ApplicationUpdate and not empty then Exit;

  List := GetFileList(SharePath + ModulesDirectory, '*.zip');

  UnZipper := TUnZipper.Create;
  UnZipper.UseUTF8 := True;
  UnZipper.OutputPath := DataPath;

  for f in List do
    begin
      d := DataPath + Slash + ExtractOnlyName(f);
      if not empty and not FileExists(d) then Continue;
      try
        UnZipper.FileName := f;
        UnZipper.UnZipAllFiles;
      except
        //
      end;
    end;

  UnZipper.Free;
end;

end.

