{-------------------------------------------------------------------------------
Photo Organizer

by Alvaro 'krono' Gonzalez Ferrer

https://alvarogonzalezferrer.github.io/

Copyright (c) 2022

In loving memory of my father.

Released under the MIT license.

NOTE: Needs exiftool to get EXIF data! >> https://exiftool.org/

--------------------------------------------------------------------------------
This app is a photo organizer, to move your photos into folders, using EXIF data, organized by

year / month / day

or

year / month

or

year

I like to keep my photo backups cold on site, not on the cloud.

So I keep my photos like this

year/month/photo.jpg

i.e 2020/12/photo.jpg
--------------------------------------------------------------------------------
To compile:
Source code for Lazarus > https://www.lazarus-ide.org/
-------------------------------------------------------------------------------}
unit photo_organizer_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ComCtrls, LCLType, WinDirs, LazFileUtils, LazUtils, FileUtil, about_form;

type

  { TMainForm }

  TMainForm = class(TForm)
    FolderStructureCombo: TComboBox;
    SortModeLabel: TLabel;
    ProgressBar1: TProgressBar;
    ResultsMemo: TMemo;
    FindPhotosBtn: TButton;
    ChooseSourceBtn: TButton;
    ChooseoOutputBtn: TButton;
    CopyPhotosBTN: TButton;
    IncludeSubDirs: TCheckBox;
    LabelStep2: TLabel;
    LabelStep3: TLabel;
    LabelStep4: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SourceFolder: TEdit;
    LabelStep1: TLabel;
    MainMenu: TMainMenu;
    MenuAbout: TMenuItem;
    MenuItem1: TMenuItem;
    MenuExit: TMenuItem;
    OutputFolder: TEdit;
    procedure ChooseoOutputBtnClick(Sender: TObject);
    procedure ChooseSourceBtnClick(Sender: TObject);
    procedure CopyPhotosBTNClick(Sender: TObject);
    procedure FindPhotosBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
     // DEBUG load configuration
     SelectDirectoryDialog1.InitialDir:=GetWindowsSpecialDir(CSIDL_PERSONAL); // empezar en mis documentos
end;

procedure TMainForm.MenuAboutClick(Sender: TObject);
begin
  aboutForm.ShowModal; // about me form
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
   reply : Integer;
begin
  // confirm close
  reply := Application.MessageBox('Exit, are you sure?', 'Exit', MB_ICONQUESTION + MB_YESNO);
  if reply = IDNO then CloseAction := caNone;
end;

procedure TMainForm.ChooseSourceBtnClick(Sender: TObject);
begin
  // choose source folder - step 1
  if SelectDirectoryDialog1.Execute then
  begin
     SourceFolder.Caption := AppendPathDelim(SelectDirectoryDialog1.FileName);
     ChooseoOutputBtn.Enabled := True;  // enable step 2
  end;
end;

procedure TMainForm.CopyPhotosBTNClick(Sender: TObject);
var
     tmpFileList : String; // temp file path with photo list
     tmpFileHandle : TFileStream; // temp file with photo list
     tmpFileOutputList : String; // temp file path with photo and exif list
     //tmpFileBatch : String; // temp file to call exiftools
     batchCommand : String; // command in batch file
     exifTool : String; // command for exif tool / debug should be configurable
     tfIn : TextFile; // input file from exiftool output
     s : String; // tmp read line
     photoIn : String; // photo in path
     photoOut : String; // photo out path

begin

     // disable all controls
     ChooseoOutputBtn.Enabled:=False;
     ChooseSourceBtn.Enabled:=False;
     FindPhotosBtn.Enabled:=False;
     CopyPhotosBTN.Enabled:=False;
     CopyPhotosBTN.Caption:='WORKING!';

    // create list of files to process
    tmpFileList := GetTempFileName(); // get temp filename for output

    // get exif tool path
    exiftool := ExtractFilePath(ParamStr(0)) + 'exiftool.exe';

    // DEBUG - needs error catch
    // dump to file the photo list
    tmpFileHandle := TFileStream.Create(tmpFileList, fmCreate);
    ResultsMemo.Lines.SaveToStream(tmpFileHandle);
    tmpFileHandle.Free;

    // fist get exif data from the list of photos we have
    // we use exiftool -- https://exiftool.org/

    //ShowMessage('IN @ ' + tmpFileList); // DEBUG

    //ShowMessage('EXE > ' + exifTool ); // my exe

    tmpFileOutputList := GetTempFileName(); // tmp file 2, need to catch it after creating 1st file

    // execute exiftool *should be in same path as our exe file*
    // parameters
    // exiftool -T -FilePath -DateTimeOriginal -d %Y\%m -@ LISTA_DE_ARCHIVOS.TXT

    //tmpFileBatch:= GetTempFileName('', 'BAT') + '.bat';

    //ShowMessage('OUT > ' + tmpFileOutputList); // DEBUG
    //ShowMessage('BAT ' + tmpFileBatch); // DEBUG

    // DEBUG WE SHOULD TAKE DATE FORMAT FROM COMBO
    // TAG DateTimeOriginal no funciona en videos
    // TAG CreateDate  deberia funcionar en video tambien
    batchCommand := '@echo DONT CLOSE THIS WINDOW WE ARE READING YOUR PHOTOS DATES && @' + exifTool + ' -T -FilePath -CreateDate -d %Y/%m -@ '+ tmpFileList + ' > ' + tmpFileOutputList ;

    ShowMessage('We will scan your photos for date EXIF data' + LineEnding + 'This will open a special window, do NOT close it.' + LineEnding + 'Let the process end without closing the window!');

    ExecuteProcess('cmd','/c ' + batchCommand); // debug esto tarda mucho y abre una ventana negra, deberia avisar!!

    // progress bar
    ProgressBar1.Max := ResultsMemo.Lines.Count;
    ProgressBar1.Min := 1;
    ProgressBar1.Position:=1;
    ProgressBar1.Enabled:=True;

    AssignFile(tfIn, tmpFileOutputList);
    try
       Reset(tfIn);

       while not eof (tfIn) do
       begin
            ReadLn(tfIn, s);
            photoIn := Copy(s, 1, pos(#9, s)-1);
            photoOut:= Copy(s, pos(#9, s)+1, s.Length);

            // EXIFTOOL USA / Y NECESITO USAR \

            photoIn := StringReplace(photoIn, '/', '\', [rfReplaceAll, rfIgnoreCase]);
            photoOut := StringReplace(photoOut, '/', '\', [rfReplaceAll, rfIgnoreCase]);

            // debug if date is - means no data
            // should attemp to take date from file date!
            if photoOut = '-' then
               photoOut:= 'no_date';

            // real path
            photoOut := OutputFolder.Caption + photoOut;

            // create dir structure
            ForceDirectories(photoOut);

            // copy file
            photoOut := photoOut + '\' + ExtractFileName(photoIn);

            CopyFile(photoIn, photoOut, [cffPreserveTime, cffCreateDestDirectory]);



            // progress bar
            ProgressBar1.Position := ProgressBar1.Position + 1;
            Application.ProcessMessages;


            //ShowMessage(photoIn + #13#10+ photoOut);
       end;

    finally
     CloseFile(tfIn);
    end;

    ShowMessage('DEBUG all done ready to clean up'); // DEBUG

    // cleanup
    // delete temp files
    DeleteFile(tmpFileList);
    DeleteFile(tmpFileOutputList);
    //DeleteFile(tmpFileBatch);

    // disable buttons and reset interface
    // DEBUG / NOT DONE

    // OK message
    ShowMessage('Everything done! Thanks!');
end;

procedure TMainForm.FindPhotosBtnClick(Sender: TObject);
var
   Photos: TStringList; // photo list -- DEBUG - DEBERIA SER GLOBAL O UN SINGLETON PARA PODER USARLA LUEGO?
begin
     // find photos - step 3

     // ir buscando las carpetas y listarlas
     // hacerlo recursivo si es necesario
     // ver https://wiki.freepascal.org/FindAllFiles
     // DEBUG hacer la lista de archivos configurable!
     Photos := FindAllFiles(SourceFolder.Caption, '*.jpg;*.jpeg;*.mp4;*.webp', IncludeSubDirs.Checked); //find all files
     try
        if Photos.Count > 0 then
        begin
          ShowMessage(Format('Found %d files', [Photos.Count])); // avisar lo que hizo

          ResultsMemo.Lines.BeginUpdate; // acelera la actualizacion - ver https://forum.lazarus.freepascal.org/index.php?topic=45733.0
          ResultsMemo.Lines.Clear;
          //ResultsMemo.Lines.Add( 'Found ' + Photos.Count.ToString + ' files.' + LineEnding + LineEnding);  // cabecera- NO PONER ASI PUEDO USAR LA LISTA DEL MEMO DIRECTAMENTE!!
          ResultsMemo.Lines.AddStrings(Photos);  // cargar la lista, puede ser larga, ojo!
          ResultsMemo.Lines.EndUpdate; // listo el update
          CopyPhotosBTN.Enabled := True; // permitir copiar
        end
        else
        begin
             ShowMessage('No photos found!');
             ResultsMemo.Lines.Clear;
             CopyPhotosBTN.Enabled := False;
        end;

     finally
      Photos.Free; // liberar memoria
     end;
end;

procedure TMainForm.ChooseoOutputBtnClick(Sender: TObject);
begin
     // choose output folder - step 2
  if SelectDirectoryDialog1.Execute then
  begin
       // must be different from source folder
       if (AppendPathDelim(SelectDirectoryDialog1.FileName) = SourceFolder.Caption) then
       begin
            ShowMessage('Output folder must be different from source folder!');
       end
       else
       begin
            OutputFolder.Caption := AppendPathDelim(SelectDirectoryDialog1.FileName);
            FindPhotosBtn.Enabled := True;  // enable step 3
       end;
  end;
end;

procedure TMainForm.MenuExitClick(Sender: TObject);
var
   reply : Integer;
begin
   // end app
   reply := Application.MessageBox('Exit, are you sure?', 'Exit', MB_ICONQUESTION + MB_YESNO);
   if reply = IDYES then Application.Terminate;
end;

end.

