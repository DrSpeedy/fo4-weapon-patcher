{
	New script template, only shows processed records
	Assigning any nonzero value to Result will terminate script
}
unit userscript;

uses 'lib\mxpf';

// Global variables
var
	AmmoList: TStringList;

// helpers
{ Get native base (last 6) as string }
function genvb(var e: IInterface; var ip: string): string;
begin
	Result := RightStr(IntToHex(genv(e, ip), 8), 6);
end;

function Initialize: integer;
var
	tmp:string;
	
begin
    // Initialize stringlists
	AmmoList := TStringList.Create;
	
	// Load values from CSV
	AmmoList.Add('01F279=62,7,0.9,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('0020CB=58,7,0.89,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('01F278=29,4,0.8,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('037897=33,4,0.75,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0020C0=36,4,0.75,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0020C2=29,4,0.75,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('002173=27,4,0.7,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('002754=29,4,0.75,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('003958=31,4,0.75,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('01F276=26,4,0.55,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('01F66A=27,4,0.55,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('04CE87=25,4,0.5,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('09221C=33,4,0.68,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('000FFA=26,4,0.7,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0020BF=24,4,0.5,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0020C1=27,4,0.55,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('00217B=34,4,0.6,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('01F673=56,6,0.35,0.95,0.7,Explode only,1');
	AmmoList.Add('003B88=39,6,0.3,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('01F66B=49,7,0.8,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('01F66C=49,7,0.8,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0012FE=46,7,0.78,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('001340=55,7,0.85,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0013B4=42,7,0.78,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('0020BE=44,7,0.78,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('02C8B1=41,4,0.68,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('04742B=25,4,0.52,0.95,0.7,No dismember/explode,1');
	AmmoList.Add('009907=59,2,0.9,0.95,0.7,Explode only,1');
	AmmoList.Add('18ABDF=56,4,0.78,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('0496EB=33,2,0.75,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('04D39C=41,2,0.68,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('245D53=49,2,0.8,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('1943D0=49,2,0.8,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('245D68=56,2,0.35,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('245D6A=26,2,0.55,0.95,0.7,Normal formula behaviour,1');
	AmmoList.Add('245D6B=27,2,0.55,0.95,0.7,Normal formula behaviour,1');
	
	DefaultOptionsMXPF;
	InitializeMXPF;
end;

// called for every record selected in xEdit
function Process(e: IInterface): integer;
var
	key: string;
	tmpList: TStringList;
	i, j: integer;
	f: float;
begin
    Result := 0;
	tmpList := TStringList.Create;
	tmpList.Delimiter := ',';
	tmpList.StrictDelimiter := True; // stops spaces being used as a delim
	
	if (HasKeyword(e, 'WeaponTypeBallistic')) then
	begin
		AddMessage('Processing: ' + Name(e));
		key := genvb(e, 'DNAM\Ammo');
		if (Length(AmmoList.Values[key]) <> 0) then
		begin
			tmpList.DelimitedText := AmmoList.Values[key];
			{
				0 = baseDmg
				1 = randDmgBoost
				2 = outOfRangeMult
				4 = baseDmgPistolMult
				5 = outOfRangePistolMult
				5 = onHit
				6 = reloadSpeedMult
			}
			// Set base damage
			j := random(strtoint(tmpList[1])) + strtoint(tmpList[0]);
			if (HasKeyword(e, 'WeaponTypePistol')) then
			begin
				f := j;
				j := Round(f * strtofloat(tmpList[4]));
			end;
			seev(e, 'DNAM\Damage - Base', inttostr(j));
			
			// Set other
			seev(e, 'DNAM\Damage - OutOfRange Mult', tmpList[2]);
			seev(e, 'DNAM\On Hit', tmpList[5]);
			seev(e, 'DNAM\Reload Speed', tmpList[6]);
			
		//else
		//	AddMessage('Ammo: ' + geev(e, 'DNAM\Ammo') + ' has not been registered!');
		end;
		
	end;
	tmpList.Free;
end;

// Called after processing
// You can remove it if script doesn't require finalization code
function Finalize: integer;
begin
    Result := 0;
	FinalizeMXPF;
	AmmoList.Free;
end;
end.
