#Include "Minigui.ch"
#Include "Common.ch"
*----------------------*
Procedure  Principal()
*----------------------*
SET DATE BRITISH 
SET CENTURY ON 

REQUEST DBFCDX
RDDSETDEFAULT("DBFCDX")
DBSETDRIVER("DBFCDX")

Public DRIVER := 'DBFCDX'

If Select('OrcDB') = 0 .and. ! FOrcDB()
     Return
Endif

If Select('MetaDB') = 0 .and. ! FMetaDB()
     Return
Endif

Define Window Jprinc;
At 0,0;
Width 300 Height 300;
Title 'Controle Marketing';
Main;
Nomaximize;
Nosize

@100,50 Button Borc;
Caption 'Orçamentos'; 
Width 100 Height 100;
Action {|| Porc() }

@100,155 Button Bmeta;
Caption 'Metas';
Width 100 Height 100;
Action {|| Pmeta() }

End Window 
Center Window Jprinc
Activate Window Jprinc 

Return Nil
*----------------------*
Function FOrcDB()
*----------------------*
Local Struct := {}
Local CdxOrc := 'indexaorc'
Local OrcDB := 'OrcDB.DBF'

If ! File (OrcDB)	
     aadd(Struct, {'oNome' ,'C' , 150, 0 })
     aadd(Struct, {'oHporD' ,'N' , 19, 4 })
     aadd(Struct, {'oPporH' ,'N' , 19, 4 })
     aadd(Struct, {'oDias' ,'N' , 19, 4 })
     aadd(Struct, {'oTotalH' ,'N' , 19, 4 })
     aadd(Struct, {'oAd' ,'N' , 19, 4 })
     aadd(Struct, {'oValorT' ,'N' , 19, 4 })
     aadd(Struct, {'oHora', 'C' , 8, 0})
     aadd(Struct, {'oData', 'D' , 8, 0})
     DbCreate(OrcDB, Struct, DRIVER)
Endif

USE (OrcDB) ALIAS OrcDB New Shared Via DRIVER 

If NetErr()
     MsgSTOP("Atenção ! Arquivo [OrcDB.DBF] está bloqueado.")
     Return(.F.)
Endif

If ! File (CdxOrc + ".cdx")
     Index on Descend(Dtos(oData)) + Descend(oHora) Tag tempo to (CdxOrc)
Endif 

OrcDB->(dbSetIndex((CdxOrc)))

Return (.T.)
*----------------------*
Function FMetaDB()
*----------------------*
Local Struct := {}
Local CdxMeta := 'indexameta'
Local MetaDB := 'MetaDB.DBF'

If ! File (MetaDB)
     aadd(Struct,{'meNome' , 'C' , 150, 0 })
     aadd(Struct,{'meMeta' , 'N' , 19, 4 })
     aadd(Struct,{'mePrazo' , 'N' , 19, 4 })
     aadd(Struct,{'mNhoras' , 'N' , 19, 4 })
     aadd(Struct,{'mVhora' , 'N' , 19, 4 })
     aadd(Struct,{'mVdias' , 'N' , 19, 4 })
     aadd(Struct,{'mNvalor' , 'N' , 19, 4 })
     aadd(Struct,{'mHhora' , 'N' , 19, 4 })
     aadd(Struct,{'mHdias' , 'N' , 19, 4 })
     aadd(Struct, {'mHora', 'C' , 8, 0})
     aadd(Struct, {'mData', 'D' , 8, 0})
     aadd(Struct, {'HouV', 'C' , 1, 0})
     DbCreate(MetaDB, Struct, DRIVER)
Endif

USE (MetaDB) ALIAS MetaDB New Shared Via DRIVER 

If NetErr()
     MsgSTOP("Atenção ! Arquivo [MetaDB.DBF] está bloqueado.")
     Return(.F.)
Endif

If ! File (CdxMeta + ".cdx")
     Index on Descend(Dtos(mData)) + Descend(mHora) Tag tempo to (CdxMeta)
Endif 

MetaDB->(dbSetIndex((CdxMeta)))

Return (.T.)
*----------------------*
Procedure Porc()
*----------------------*
Define Window Jorc;
At 0,0;
Width 950 Height 500;
Title 'Orçamentos';
Child;
Nomaximize;
Nosize

@ 10, 10 Grid Gorc;
Width 700 Height 450;
Headers {'Cliente', 'Horas por dia', 'Preço por hora', 'Qtd. dias', 'Total de horas', 'Adicionais','Valor final'};
Widths {100,100,100,100,100,100,100};
JUSTIFY{BROWSE_JTFY_LEFT,;
	BROWSE_JTFY_CENTER,;
	BROWSE_JTFY_LEFT,;
	BROWSE_JTFY_CENTER,;
	BROWSE_JTFY_CENTER,;
	BROWSE_JTFY_LEFT,;
	BROWSE_JTFY_LEFT}

@50, 750 Button BCorc;
Caption 'Novo Orçamento';
Width 150;
Action {|| PCorc()}

@100,750 Datepicker d1 On Enter{||POsearch(Jorc.d1.value,Jorc.d2.value)}
@135,750 Datepicker d2 On Enter{||POsearch(Jorc.d1.value,Jorc.d2.value)}

End Window 
Center Window Jorc
Activate Window Jorc 

Return Nil
*----------------------*
Procedure POsearch(dataIni, dataFin)
*----------------------*
Jorc.Gorc.DeleteAllItems
OrcDB->(OrdSetFocus(1))	
OrcDB->(DbSeek(DtoS(dataFin),.T.))
     
Do While ! OrcDB->oData < dataIni .and. ! OrcDB->(Eof()) 
     
	If OrcDB->oData > dataFin	
          OrcDB->(DbSkip())
          Loop
     Endif
    
     Add Item {Alltrim(OrcDB->oNome,150,0),;
     Alltrim(Str(OrcDB->oHporD,10,0)),;
     Alltrim('R$' + Str(OrcDB->oPporH,10,2)),;
     Alltrim(Str(OrcDB->oDias,10,0)),;
     Alltrim(Str(OrcDB->oTotalH,10,0)),;
     Alltrim('R$' + Str(OrcDB->oAd,10,2)),;
     Alltrim('R$' + Str(OrcDB->oValorT,10,2))} To Gorc Of Jorc
     
     OrcDB->(DbSkip())
     
Enddo
     
Return
*----------------------*
Procedure Pmeta()
*----------------------*
Define Window Jmeta;
At 0,0;
Width 1000 Height 550;
Title 'Metas';
Child;
Nomaximize;
Nosize;
On Init {||PMsearch(Jmeta.dm1.value,Jmeta.dm2.value,Jmeta.escolhemostra.value)}

@ 10, 10 Grid Gmeta;
Width 800 Height 450;
Headers {'','','','','','',''};
Widths {150,100,100,100,100,150,100};
JUSTIFY{BROWSE_JTFY_LEFT,;
	BROWSE_JTFY_RIGHT,;
	BROWSE_JTFY_RIGHT,;
	BROWSE_JTFY_RIGHT,;
	BROWSE_JTFY_RIGHT,;
	BROWSE_JTFY_RIGHT,;
	BROWSE_JTFY_RIGHT}

@50, 800 Button BCmeta;
Caption 'Nova Meta';
Width 150;
Action {|| PCmeta()}

@100,850 Combobox escolhemostra;
Items{'Hora', 'Preço'};
Value 1;
Width 110 Font 'Arial' Size 9 ;
On Change {||PMsearch(Jmeta.dm1.value,Jmeta.dm2.value,Jmeta.escolhemostra.value)}

@150,750 Datepicker dm1 On Enter{||PMsearch(Jmeta.dm1.value,Jmeta.dm2.value,Jmeta.escolhemostra.value)}
@185,750 Datepicker dm2 On Enter{||PMsearch(Jmeta.dm1.value,Jmeta.dm2.value,Jmeta.escolhemostra.value)}

End Window 
Center Window Jmeta 
Activate Window Jmeta 

Return Nil
*----------------------*
Procedure PMsearch(dataIni, dataFin, qualmostra)
*----------------------*
Jmeta.Gmeta.header(1):= 'Nome'
Jmeta.Gmeta.header(2):= 'Meta'
Jmeta.Gmeta.header(3):= 'Data'
Jmeta.Gmeta.header(4):= 'Prazo'

If qualmostra == 1

Jmeta.Gmeta.header(5):= 'Horas pretendidas'
Jmeta.Gmeta.header(6):= 'Meta Preço/Hora'
Jmeta.Gmeta.header(7):= 'Meta diária'
Jmeta.Gmeta.DeleteAllItems
MetaDB->(OrdSetFocus(1))
MetaDB->(DbSeek(DtoS(dataFin),.T.))
     
Do While ! MetaDB->mData < dataIni .and. ! MetaDB->(Eof()) 
     
	If MetaDB->mData > dataFin
          MetaDB->(DbSkip())
          Loop
     Endif
    
     If MetaDB->HouV == 'H'
     
     Add Item{Alltrim((Str(MetaDB->meNome,150,0))),;
     Alltrim('R$' + Str(MetaDB->meMeta,10,2)),;
     Alltrim(Str(MetaDB->mData,8,0)),;
     Alltrim(Str(MetaDB->mePrazo,10,0)+' dias'),;
     Alltrim(Str(MetaDB->mNhoras,10,0)),;
     Alltrim('R$' + Str(MetaDB->mVhora,10,2)),;
     Alltrim(Str(MetaDB->mVdias,10,0))}to Gmeta of Jmeta
     
     MetaDB->(DbSkip())
     
     Else 
     
	 MetaDB->(DbSkip())
	 
	 Endif  
Enddo

Else

Jmeta.Gmeta.header(5):= 'Valor pretendido'
Jmeta.Gmeta.header(6):= 'Meta de horas'
Jmeta.Gmeta.header(7):= 'Meta diária'
Jmeta.Gmeta.DeleteAllItems
MetaDB->(OrdSetFocus(1))	
MetaDB->(DbSeek(DtoS(dataFin),.T.))     
Do While ! MetaDB->mData < dataIni .and. ! MetaDB->(Eof()) 
     
	If MetaDB->mData > dataFin
          MetaDB->(DbSkip())
          Loop
     Endif
     
     If MetaDB->HouV == 'V'
    
     Add Item{Alltrim((Str(MetaDB->meNome,150,0))),;
     Alltrim('R$ ' + Str(MetaDB->meMeta,10,2)),;
     Alltrim(Str(MetaDB->mData,8,0)),;
     Alltrim(Str(MetaDB->mePrazo,10,0)+' dias'),;
     Alltrim('R$ ' + Str(MetaDB->mNvalor,10,2)),;
     Alltrim(Str(MetaDB->mHhoras,10,0)),;
     Alltrim(Str(MetaDB->mHdias,10,0))}to Gmeta of Jmeta
      
     MetaDB->(DbSkip())
     
     Else 
     
	 MetaDB->(DbSkip())
	 
	 Endif 
Enddo
Endif

Return
*----------------------*
Procedure PCorc()
*----------------------*
Define Window JCorc;
At 0,0;
Width 550 Height 400;
Title 'Registro de Orçamentos';
Child;
Nomaximize;
Nosize

@25,50 Label nomeO Width 200 Height 25 Font 'Arial' Size 9 Bold
@50,50 Textbox onNome Width 200

@95,50 Label horasdiaO Width 200 Height 25 Font 'Arial' Size 9 Bold
@120,75 Textbox oHoras Width 50 Rightalign
@120,50 Label realqtd1 Width 25 Height 25 Font 'Arial' Size 9 Bold
@120,130 Label horash  Width 35 Height 25 Font 'Arial' Size 9 Bold

@165,50 Label precoO Width 200 Height 25 Font 'Arial' Size 9 Bold
@190,75 Textbox oPreco Width 75 Rightalign
@190,50 Label realqtd2 Width 25 Height 25 Font 'Arial' Size 9 Bold

@235,50  Label diasO Width 200 Height 25 Font 'Arial' Size 9 Bold
@260,75 Textbox oDias Width 50 Rightalign
@260,50 Label realqtd3 Width 25 Height 25 Font 'Arial' Size 9 Bold
@260,130 Label diasd Width 25 Height 25 Font 'Arial' Size 9 Bold

@305,50 Label adicionaO Width 200 Height 25 Font 'Arial' Size 9 Bold
@330,75 Textbox oAdd Width 50 Rightalign
@330,50 Label add Width 25 Height 25 Font 'Arial' Size 9 Bold

@95,300 Label tempototalO Width 200 Height 25 Font 'Arial' Size 9 Bold
@120,300 Textbox oTempo Width 200 Readonly

@165,300 Label resultO Width 200 Height 25 Font 'Arial' Size 9 Bold
@190,300 Textbox oResultado Width 200 Readonly

@50, 300 Button oCalcula;
Caption 'Calcular';
Action {||FCorc(JCorc.oPreco.value,JCorc.oDias.value,JCorc.oHoras.value,JCorc.oAdd.value)}

@50,415 Button oGrava;
Caption 'Salvar';
Action {||FCOgrava(JCorc.onNome.value,;
	 JCorc.oHoras.value,;
	 JCorc.oPreco.value,;
	 JCorc.oDias.value,;
	 JCorc.oAdd.value,;
	 JCorc.oTempo.value,;
	 JCorc.oResultado.value),JCorc.release}

JCorc.nomeO.value:= 'Digite o nome do cliente:'
JCorc.horasdiaO.value:= 'Horas estipuladas por dia:'
JCorc.realqtd1.value := 'Qtd'
JCorc.precoO.value:= 'Preço por hora de serviço:'
JCorc.realqtd2.value := ' R$'
JCorc.diasO.value := 'Qtd. de dias para conclusão:'
JCorc.realqtd3.value := 'Qtd'
JCorc.diasd.value := 'dias'
JCorc.horash.value := 'horas'
JCorc.adicionaO.value := 'Custos adicionais:'
JCorc.add.value := 'R$'

JCorc.tempototalO.value := 'Total de horas para o serviço:'
JCorc.resultO.value:= 'O valor do orçamento é de:'

End Window 
Center Window JCorc
Activate Window JCorc 

Return Nil
*----------------------*
Procedure PCmeta()
*----------------------*
Define Window JCmeta; 
At 0,0;
Width 800 Height 600;
Title 'Registro de Metas';
Child;
Nomaximize;
Nosize;
On Init {|| Fqualmeta(JCmeta.mEscolhe.value)}

@50,300 Combobox mEscolhe;
Items{'Hora', 'Preço'};
Value 1;
Width 110 Font 'Arial' Size 9 ;
On Change {|| Fqualmeta(JCmeta.mEscolhe.value)}
@25,270 Label combom Width 200 Height 25 Font 'Arial' Size 9 Bold

@25,50 Label nomeM Width 200 Height 25 Font 'Arial' Size 9 Bold
@50,50 Textbox mNome Width 200

@95,50 Label meta Width 200 Height 25 Font 'Arial' Size 9 Bold
@120,75 Textbox mMeta Width 100 Rightalign 
@120,50 Label rq1 Width 20 Height 25 Font 'Arial' Size 9 Bold

@165,50 Label PrazoM Width 200 Height 25 Font 'Arial' Size 9 Bold
@190,75 Textbox mPrazo Width 75 Rightalign 
@190,50 Label rq2 Width 25 Height 25 Font 'Arial' Size 9 Bold
@190,155 Label dias Width 25 Height 25 Font 'Arial' Size 9 Bold

@235,50 Label PouH Width 200 Height 25 Font 'Arial' Size 9 Bold
@260,75 Textbox mPouh Width 100 Rightalign 
@260,50 Label rq3 Width 20 Height 25 Font 'Arial' Size 9 Bold

@95,300 Label resulttudo Width 300 Height 25 Font 'Arial' Size 9 Bold
@120,300 Textbox mresult Width 200 Readonly Rightalign 

@165,300 Label resultdia Width 300 Height 25 Font 'Arial' Size 9 Bold
@190,300 Textbox mresultd Width 200 Readonly Rightalign 

@250,300 Button mCalcula;
Caption 'Calcular'

@300,300 Button mgrava;
Caption 'Salvar';
Action {||FCMgrava(JCmeta.mNome.value,;
JCmeta.mMeta.value,;
JCmeta.mPrazo.value,;
JCmeta.mPouh.value,;
JCmeta.mresult.value,;
JCmeta.mresultd.value,;
JCmeta.mEscolhe.value), JCmeta.release}

End Window
Center Window JCmeta
Activate Window JCmeta

Return Nil 
*----------------------*
Function Fqualmeta(escolheu)
*----------------------*
**Labels 
JCmeta.combom.value := 'Calcular meta por:'
JCmeta.nomeM.value := 'Digite um nome para a meta:'
JCmeta.prazoM.value := 'Prazo:'
JCmeta.meta.value := 'Meta desejada:'
JCmeta.rq1.value := 'R$'
JCmeta.rq2.value := 'Qtd'
JCmeta.dias.value := 'dias'
**limpa tb
JCmeta.mNome.value := ''
JCmeta.mMeta.value := ''
JCmeta.mPrazo.value := ''
JCmeta.mPouh.value := ''
JCmeta.mresult.value := ''
JCmeta.mresultd.value := ''

If escolheu == 1

JCmeta.PouH.value := 'Número de horas pretendidas:'
Jcmeta.rq3.value := 'Qtd'
JCmeta.resulttudo.value := 'Meta de valor por hora:'
JCmeta.resultdia.value := 'Meta diária de "arrecadação":'

JCmeta.mCalcula.Action := {||FCmetaH(JCmeta.mMeta.value,JCmeta.mPouH.value,JCmeta.mPrazo.value)}

Else

JCmeta.PouH.value:= 'Valor pretendido por hora: '
Jcmeta.rq3.value := 'R$'
JCmeta.resulttudo.value := 'Meta de número de horas trabalhadas:'
JCmeta.resultdia.value := 'Meta diária de horas:'

JCmeta.mCalcula.Action := {||FCmetaP(JCmeta.mMeta.value,JCmeta.mPouH.value,JCmeta.mPrazo.value)}

Endif 

Return Nil 

*----------Cálculos e gravações----------*

*----------------------*
Function FCorc(nPreco,nDia,nHora,nAdd)
*----------------------*
Local vOrc[2]

vOrc[1]:= val(nDia) * val(nHora)
vOrc[2]:= val(nAdd) + (val(nPreco)* vOrc[1])

JCorc.oTempo.value := Alltrim(str(vOrc[1],10,0)+' horas')
JCorc.oResultado.value := Alltrim(str(vOrc[2],10,2)+' R$')

Return 
*----------------------*
Function FCmetaH(nMeta, nHora, nPrazo)
*----------------------*
Local vPreco[2]

vPreco[1] := val(nMeta) / val(nHora) 
vPreco[2] := vPreco[1] / val(nPrazo)

JCmeta.mresult.value := Alltrim(str(vPreco[1],10,2)+' R$')
JCmeta.mresultd.value := Alltrim(str(vPreco[2],10,2)+' R$')

Return Nil
*----------------------*
Function FCmetaP(nMeta, nPreco, nPrazo)
*----------------------*
Local vHora[2]

vHora[1]:= val(nMeta) / val(nPreco) 
vHora[2]:= vHora[1] / val(nPrazo)

JCmeta.mresult.value  := Alltrim(str(vHora[1],10,0)+ ' horas')
JCmeta.mresultd.value := Alltrim(str(vHora[2],10,0)+ ' horas')

Return Nil 
*----------------------*
Function FCOgrava(cNome,nHD,nPH,nDias,nTH,nAd,nValt)
*----------------------*
OrcDB->(Ordsetfocus(1))
OrcDB->(DbAppend())

OrcDB->oNome := Alltrim(cNome)
OrcDB->oHporD := val(nHD)
OrcDB->oPporH := val(nPH)
OrcDB->oDias := val(nDias)
OrcDB->oTotalH := val(nTH)
OrcDB->oAd := val(nAd)
OrcDB->oValorT := val(nValt)  
OrcDB->oHora := Time()
OrcDB->oData := Date()

Return Msginfo('OrçAmento salvo com sucesso!')
*----------------------*
Function FCMgrava(cNome,nMeta,nPrazo,nPretend,nResult1,nResult2,Gravaonde)
*----------------------*
If Gravaonde == 1

MetaDB->(Ordsetfocus(1))
MetaDB->(DbAppend())

MetaDB->meNome := Alltrim(cNome)
MetaDB->meMeta := Val(nMeta)
MetaDB->mePrazo := Val(nPrazo)
MetaDB->mNhoras := Val(nPretend)
MetaDB->mVhora := Val(nResult1)
MetaDB->mVdias := Val(nResult2)
MetaDB->mHora := Time()
MetaDB->mData := Date() 
MetaDB->HouV := 'H'

Else

MetaDB->(Ordsetfocus(1))
MetaDB->(DbAppend())

MetaDB->meNome := Alltrim(cNome)
MetaDB->meMeta := Val(nMeta)
MetaDB->mePrazo := Val(nPrazo)
MetaDB->mNvalor:= Val(nPretend)
MetaDB->mHhora := Val(nResult1)
MetaDB->mHdias := Val(nResult2)
MetaDB->mHora := Time()
MetaDB->mData := Date() 
MetaDB->HouV := 'V'

Endif

Return Msginfo('Meta salva com sucesso!')
