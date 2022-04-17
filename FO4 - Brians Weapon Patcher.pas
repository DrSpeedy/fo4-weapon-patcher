{
	MIT License

	Copyright (c) 2022 Brian Wilson

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
	Questions: brian@wiltech.org
}
unit userscript;

uses 'lib\mxpf';

// Global variables
var
	AmmoList, omodAmmoList: TStringList;

// helpers
{ Get native base (last 6) as string }
function genvb(var e: IInterface; var ip: string): string;
begin
	Result := RightStr(IntToHex(genv(e, ip), 8), 6);
end;

function Initialize: integer;
var
	prop, props: IInterface;
	i: integer;
	pfOmodAmmoChange, pfOmodDamageChange, pfOmodHasMaster: boolean;
begin
    // Initialize stringlists
	AmmoList := TStringList.Create;
	omodAmmoList := TStringList.Create;
	
	// Update these values from the shell script or manualy edit them
	AmmoList.Add('01F279=62,7,0.9,0.95,0.7,Normal formula behaviour,1'); // .50 BMG
	AmmoList.Add('0020CB=58,7,0.89,0.95,0.7,Normal formula behaviour,1'); // .338 LM
	AmmoList.Add('01F278=29,4,0.8,0.95,0.7,No dismember/explode,1'); // 5.56x45mm
	AmmoList.Add('037897=33,4,0.75,0.95,0.7,No dismember/explode,1'); // 7.62x39mm
	AmmoList.Add('0020C0=36,4,0.75,0.95,0.7,No dismember/explode,1'); // 9x39mm
	AmmoList.Add('0020C2=29,4,0.75,0.95,0.7,No dismember/explode,1'); // .300 BLK
	AmmoList.Add('002173=27,4,0.7,0.95,0.7,No dismember/explode,1'); // .223 REM
	AmmoList.Add('002754=29,4,0.75,0.95,0.7,No dismember/explode,1'); // 5.49x45mm
	AmmoList.Add('003958=31,4,0.75,0.95,0.7,No dismember/explode,1'); // 6.8 SPC
	AmmoList.Add('01F276=26,4,0.55,0.95,0.7,No dismember/explode,1'); // 10mm
	AmmoList.Add('01F66A=27,4,0.55,0.95,0.7,No dismember/explode,1'); // .45 ACP
	AmmoList.Add('04CE87=25,4,0.5,0.95,0.7,No dismember/explode,1'); // 9x19mm
	AmmoList.Add('09221C=33,4,0.68,0.95,0.7,No dismember/explode,1'); // .44 Mag
	AmmoList.Add('000FFA=26,4,0.7,0.95,0.7,No dismember/explode,1'); // 5.7x28mm
	AmmoList.Add('0020BF=24,4,0.5,0.95,0.7,No dismember/explode,1'); // 9x18mm
	AmmoList.Add('0020C1=27,4,0.55,0.95,0.7,No dismember/explode,1'); // .40 S&W
	AmmoList.Add('00217B=39,4,0.6,0.95,0.7,Normal formula behaviour,1'); // .50 AE
	AmmoList.Add('01F673=56,6,0.35,0.95,0.7,Explode only,1'); // 12 GA
	AmmoList.Add('003B88=39,6,0.3,0.95,0.7,Normal formula behaviour,1'); // 28 Ga
	AmmoList.Add('01F66B=49,7,0.8,0.95,0.7,No dismember/explode,1'); // .308 WIN
	AmmoList.Add('01F66C=49,7,0.8,0.95,0.7,No dismember/explode,1'); // 7.62x51mm
	AmmoList.Add('0012FE=46,7,0.78,0.95,0.7,No dismember/explode,1'); // 8x57mm
	AmmoList.Add('001340=55,7,0.85,0.95,0.7,No dismember/explode,1'); // 300 WM
	AmmoList.Add('0013B4=42,7,0.78,0.95,0.7,No dismember/explode,1'); // 303 BRIT
	AmmoList.Add('0020BE=44,7,0.78,0.95,0.7,No dismember/explode,1'); // 7.62x54R
	AmmoList.Add('02C8B1=41,4,0.68,0.95,0.7,Normal formula behaviour,1'); // .45-70 Govt
	AmmoList.Add('04742B=25,4,0.52,0.95,0.7,No dismember/explode,1'); // 7.62x25mm
	AmmoList.Add('009907=59,2,0.9,0.95,0.7,Explode only,1'); // Pasta Ammo
	AmmoList.Add('18ABDF=56,4,0.78,0.95,0.7,Normal formula behaviour,1'); // 2mm EC
	AmmoList.Add('0496EB=33,2,0.75,0.95,0.7,Normal formula behaviour,1'); // Comp 7.62x39mm
	AmmoList.Add('04D39C=41,2,0.68,0.95,0.7,Normal formula behaviour,1'); // Comp .45-70 Govt
	AmmoList.Add('245D53=49,2,0.8,0.95,0.7,Normal formula behaviour,1'); // Comp .308 WIN
	AmmoList.Add('1943D0=49,2,0.8,0.95,0.7,Normal formula behaviour,1'); // NPC 5mm (replaced by 7.62x51mm)
	AmmoList.Add('245D68=56,2,0.35,0.95,0.7,Normal formula behaviour,1'); // Comp 12ga
	AmmoList.Add('245D6A=26,2,0.55,0.95,0.7,Normal formula behaviour,1'); // Comp 10mm
	AmmoList.Add('245D6B=27,2,0.55,0.95,0.7,Normal formula behaviour,1'); // Comp .45 ACP
	
	DefaultOptionsMXPF;
	InitializeMXPF;
	PatchFileByName('Brians_Test_Weapon_Patch');
	
	// WEAP Prefilter
	LoadRecords('WEAP');
	for i := 0 to MaxRecordIndex do
	begin
		if (Signature(GetRecord(i)) = 'WEAP') then
		begin
			PreFilterWEAPRecord(i);
			//RemoveRecord(i);
		end;
	end;
	
	// OMOD prefilter // this still does go through all loaded records, not just OMOD. need to fix;
	LoadRecords('OMOD');
	BuildAmmoModCache;
	for i := 0 to MaxRecordIndex do
	begin
		if (Signature(GetRecord(i)) = 'OMOD') then
		begin
			PreFilterOMODRecord(i);
			//RemoveRecord(i);
		end;
	end;
	
	//CopyRecordsToPatch;
	// Patch records
	for i := 0 to MaxPatchRecordIndex do
	begin
		//AddMessage(Signature(GetPatchRecord(i)));
		if (Signature(GetPatchRecord(i)) = 'WEAP') then
		begin
			PatchWeaponRecord(GetPatchRecord(i));
		end;
		if (Signature(GetPatchRecord(i)) = 'OMOD') then
		begin
			AddMessage('Patching OMOD: ' + Name(GetPatchRecord(i)));
			PatchOMODRecord(i);
		end;
	end;
end;

function PreFilterWEAPRecord(var i: integer): integer;
var
	j: integer;
	bBallistic, bHasAmmoData: boolean;
	rec: IInterface;
begin
	Result := 0;
	rec := GetRecord(i);
	bBallistic := False;
	bHasAmmoData := False;
	
	if (HasKeyword(rec, 'WeaponTypeBallistic')) then
	begin
		bBallistic := True;
	end;
	
	//AddMessage('Debug: ' + Name(rec) + ' : AmmoList = ' + AmmoList.Values[genvb(rec, 'DNAM\Ammo')]);
	if (Length(AmmoList.Values[genvb(rec, 'DNAM\Ammo')]) > 0) then
	begin
		bHasAmmoData := True;
	end;
	
	if bBallistic and bHasAmmoData then
	begin
		CopyRecordToPatch(i);
		//RemoveRecord(i);
		AddMessage('WEAP: ' + Name(rec) + ' : ' + geev(rec, 'DNAM\Ammo'));
	end;
end;

function BuildAmmoModCache: integer;
var
	tmp: string;
	i, j: integer;
	prop, props, rec: IInterface;
begin
	Result := 0;
	for i := 0 to MaxPatchRecordIndex do
	begin
		rec := GetPatchRecord(i);
		//ProcessWeapon(rec);
	
		// Cache the weapon ammo base form id (geevb) to the keywords starting with ma_ supplied w/ the weapon
		// This is for OMOD patching later on...
		props := ElementByPath(rec, 'KWDA');
		for j := 0 to Pred(ElementCount(props)) do
		begin
			prop := ElementByIndex(props, j);
			tmp := GetEditValue(prop);
			if (pos('ma_', tmp) > 0) and (pos('ma_BallisticGun', tmp) = 0) then
			begin
				omodAmmoList.Values[RightStr(IntToHex(GetNativeValue(prop), 8), 6)] := genvb(rec, 'DNAM\Ammo');
				//AddMessage('DEBUG: ' + Name(rec) + ' ' + RightStr(IntToHex(GetNativeValue(prop), 8), 6) + '=' + genvb(rec, 'DNAM\Ammo'));
			end;
		end;
	end;
end;

function PreFilterOMODRecord(var i: integer): integer;
var
	tmp: string;
	j: integer;
	pfOmodAmmoChange, pfOmodDamageChange, pfOmodHasMaster: boolean;
	prop, props: IInterface;
begin
	Result := 0;
	if (geev(GetRecord(i), 'DATA\Form Type') = 'Weapon') then
	begin
		pfOmodAmmoChange := False;
		pfOmodDamageChange := False;
		pfOmodHasMaster := False;
		
		// Check properties
		props := ElementByPath(GetRecord(i), 'DATA\Properties');
		for j := 0 to Pred(ElementCount(props)) do
		begin
			prop := ElementByIndex(props, j);
			if (geev(prop, 'Value Type') = 'FormID,Int') and (geev(prop, 'Property') = 'Ammo') then
			begin
				pfOmodAmmoChange := True;
			end;
			if (geev(prop, 'Value Type') = 'Float') and (geev(prop, 'Property') = 'AttackDamage') then
			begin
				pfOmodDamageChange := True;
			end;
		end;
		
		// Check attach point keywords...
		props := ElementByPath(GetRecord(i), 'MNAM');
		for j := 0 to Pred(ElementCount(props)) do
		begin
			prop := ElementByIndex(props, j);
			tmp := RightStr(IntToHex(GetNativeValue(prop), 8), 6); // our ammo list key
			//AddMessage('DEBUG: ' + GetEditValue(prop) + ' = ' + tmp + ' Parant ammo: ' + omodAmmoList.Values[tmp]);
			if (Length(omodAmmoList.Values[tmp]) > 0) then
			begin
				pfOmodHasMaster := True;
			end;
		end;
		
		// If all is good, copy the OMOD record to the patch
		if pfOmodAmmoChange and pfOmodDamageChange and pfOmodHasMaster then
		begin
			CopyRecordToPatch(i);
			//RemoveRecord(i);
			AddMessage('OMOD: ' + Name(GetRecord(i)) + ': ' + GetEditValue(prop));
		end;
	end;
end;

function PatchWeaponRecord(e: IInterface): integer;
var
	key, tmp: string;
	tmpList, ammoCacheList: TStringList;
	i, j: integer;
	f: float;
	prop, props: IInterface;
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
				2 = outOfRangeBaseMult
				3 = baseDmgPistolMult
				4 = outOfRangePistolMult
				5 = onHit
				6 = reloadSpeedMult
			}
			// Set base damage
			j := random(strtoint(tmpList[1])) + strtoint(tmpList[0]);
			if (HasKeyword(e, 'WeaponTypePistol')) then
			begin
				f := j;
				j := Round(f * strtofloat(tmpList[3]));
			end;
			seev(e, 'DNAM\Damage - Base', inttostr(j));
			
			// Set OutOfRange Mult
			f := strtofloat(tmpList[2]);
			if (HasKeyword(e, 'WeaponTypePistol')) then
			begin
				f := f * strtofloat(tmpList[4]);
			end;
			seev(e, 'DNAM\Damage - OutOfRange Mult', f);
			
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

function PatchOMODRecord(var i: integer): integer;
var
	ammoKey, attachKey, tmp: string;
	j, k: integer;
	f1, f2: float;
	prop, props, rec: IInterface;
	tmpList: TStringList;
begin
	Result := 0;
	rec := GetPatchRecord(i);
	tmpList := TStringList.Create;
	tmpList.Delimiter := ',';
	tmpList.StrictDelimiter := True;
	
	// Get keys
	props := ElementByPath(rec, 'MNAM');
	for j := 0 to Pred(ElementCount(props)) do
	begin
		prop := ElementByIndex(props, j);
		tmp := RightStr(IntToHex(GetNativeValue(prop), 8), 6);
		if (Length(omodAmmoList.Values[tmp]) > 0) then
		begin
			attachKey := tmp;
			ammoKey := omodAmmoList.Values[attachKey];
			//Break;
		end;
	end;
	
	tmpList.DelimitedText := AmmoList.Values[ammoKey];
	props := ElementByPath(rec, 'DATA\Properties');
	for j := 0 to Pred(ElementCount(props)) do
	begin
		prop := ElementByIndex(props, j);
		if (geev(prop, 'Value Type') = 'Float') and (geev(prop, 'Property') = 'AttackDamage') then
		begin
			// Original caliber base damage
			k := random(strtoint(tmpList[1])) + strtoint(tmpList[0]);
			if (HasKeyword(rec, 'WeaponTypePistol')) then
			begin
				f1 := k;
				k := Round(f1 * strtofloat(tmpList[3]));
			end;
			
			seev(prop, 'Value Type', 'Int');
			seev(prop, 'Function Type', 'SET');
			seev(prop, 'Value 1', k);
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
	omodAmmoList.Free;
end;
end.
