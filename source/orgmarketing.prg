#Include "Minigui.Ch"
#Include "Common.Ch"
*-------------------------*
Procedure Principal
*-------------------------*
REQUEST DBFCDX

RDDSETDEFAULT("DBFCDX")
DBSETDRIVER("DBFCDX")

If Select('BaseMark') = 0 .and. ! MarkDBopen()
     Return
Endif

Define Window escolhendo;
At 0 , 0;
Width 200 Height 200;
Main;
Nomaximize;
Nosize

@10,10 combobox escolheai;
Items {'','Orçamento', 'Meta'};
    Value 1 ;
    Width 110 Font 'Arial' Size 9 ;
    On Change{|| EscolheP(escolhendo.escolheai.value)}

End Window 
Center Window escolhendo
Activate Window escolhendo

Return
*-------------------------*
Function EscolheP(essai)
*-------------------------*
If essai == 2
	Pjanelatotalmostra()
Elseif essai == 3
	PMeta()
Endif 

Return

*-------------------------*
Function MarkDBopen()
*-------------------------*
Local DRIVER := 'DBFCDX'
Local Struct := {}
Local CdxBase := 'indexabase'
Local BaseMark := 'BaseMark.DBF'

If .NOT. File (BaseMark)	
     aadd(Struct,{'hora' ,'N' , 19, 4 })	
     aadd(Struct,{'preco' , 'N' , 19, 4 })	
     aadd(Struct,{'precohora' ,'N' , 19, 4 })
	 aadd(Struct, {'cliente', 'C', 150, 0 })
     aadd(Struct, {'horaorc', 'C', 8, 0})
     aadd(Struct, {'dataorc', 'D', 8, 0})
     DbCreate(BaseMark, Struct, DRIVER)	
Endif

USE (BaseMark) ALIAS BaseMark New Shared Via DRIVER 

If NetErr()
     MsgSTOP("Atenção ! Arquivo de [  ] está bloqueado.")
     Return(.F.)
Endif

If ! File (Cdxbase+".cdx")
     Index on Descend(Dtos(dataorc)) + Descend(horaorc) Tag tempo to (Cdxbase)
Endif 	

BaseMark->(dbSetIndex((CdxBase)))

Return(.T.)

*-------------------------*
Procedure Pjanelatotalmostra()
*-------------------------*
Define Window janelaMenuTotal;
At 0 , 0;
Width 750 Height 500;
Child;
Nomaximize;
Nosize

@10,10 Grid Mostraconta;
     Width 500 Height 450;
     Headers{'Qtd de Horas','Valor da Hora','Total de serviço','Nome do Cliente'};
     Widths {100,100,100,200}

@20,550 Button Calctotal;     
     Caption 'Calcular Total';
     Width 150;
     Action {||PjanelaTotal()}

@100,550 DatePicker data1 ON ENTER {||Fmostragridtotal(janelaMenuTotal.data1.value,janelaMenuTotal.data2.value)}
@145,550 DatePicker data2 ON ENTER {||Fmostragridtotal(janelaMenuTotal.data1.value,janelaMenuTotal.data2.value)}

End Window 
Center Window janelaMenuTotal
Activate Window janelaMenuTotal

Return

*-------------------------*
Function Fmostragridtotal(DataIni, DataFin)
*-------------------------*
janelaMenuTotal.Mostraconta.deleteallitems

BaseMark->(OrdSetFocus(1))
BaseMark->(DbSeek(DtoS(DataFin),.T.))
	     
	Do While ! BaseMark->dataorc < DataIni .and. ! BaseMark->(Eof()) 
	     
		If BaseMark->dataorc > DataFin	
	          BaseMark->(DbSkip())	
	          Loop
	     Endif
	    
	     Add Item{Alltrim((Str(BaseMark->hora,10,2))),;
	     Alltrim('R$'+ (Str(BaseMark->preco,10,2))),;
	     Alltrim('R$'+ (Str(BaseMark->precohora,10,2))),;
	     Alltrim(BaseMark->cliente,150,0)}to Mostraconta of janelaMenuTotal
	     
	     BaseMark->(DbSkip())
	     
	Enddo
     
Return

*-------------------------*
Procedure PjanelaTotal()
*-------------------------*
Define Window janelaTotal;
At 0 , 0;
Width 750 Height 500;
Child;
Nomaximize;
Nosize

@25,100 Label info1 Value 'Nome do cliente : ';
	Width 300 Height 25 Font 'Arial' Size 09 Bold

@50,100 Textbox nomeCliente Width 300

@100,100 Label info2 Value 'Quantidade de horas trabalhadas :';
	Width 300 Height 25 Font 'Arial' Size 09 Bold

@125,100 Textbox InputHoras Width 200

@175,100 Label info3 Value 'Valor da hora :';
	Width 300 Height 25 Font 'Arial' Size 09 Bold

@200,100 Label RealTotal1 Value 'R$';
	Width 20 Height 25 Font 'Arial' Size 09 Bold

@200,120 Textbox InputPreco Width 200

@250,100 Label info4 Value 'Valor pelo serviço :';
     Width 300 Height 25 Font 'Arial' Size 09 Bold

@275,100 Label RealTotal2 Value 'R$';
	Width 20 Height 25 Font 'Arial' Size 09 Bold
	
@275,120 Textbox ShowTotal Width 200 Readonly

@125,425 Button chamaCalc;
     Caption 'Calcular' Width 150;
     Action {||janelaTotal.ShowTotal.Value := Alltrim(str(Fcalculatotal(janelaTotal.InputHoras.Value,janelaTotal.InputPreco.Value)))}

@175,425 Button gravaCalc;
     Caption 'Gravar' Width 150;
     Action {||janelaTotal.ShowTotal.Value := Alltrim(str(Fcalculatotal(janelaTotal.InputHoras.Value,janelaTotal.InputPreco.Value))),;
     PgravaTotalDB(janelaTotal.InputHoras.Value,;
     janelaTotal.InputPreco.Value,;
     janelaTotal.ShowTotal.Value,;
     janelaTotal.nomeCliente.Value), janelaTotal.Release}

End Window 
Center Window janelaTotal
Activate Window janelaTotal 

Return 

*-------------------------*
Procedure PgravaTotalDB(nHoraTotal,nValorTotal,nPrecoHoraTotal,cNomecliente)
*-------------------------*
     BaseMark->(DbAppend())
     BaseMark->hora := val(nHoraTotal)
     BaseMark->preco := val(nValorTotal)
     BaseMark->precohora := val(nPrecoHoraTotal)
     BaseMark->cliente := cNomeCliente
	 BaseMark->horaorc := Time()
     BaseMark->dataorc := Date()
 
Return

*-------------------------*
Function Fcalculatotal(nHoraTotal,nValorTotal)
*-------------------------*
Local Result 

Result := val(nHoraTotal) * val(nValorTotal)

Return (Result)

*-------------------------*
Procedure PMeta()
*-------------------------*
Define Window janelamenumeta;
At 0 , 0;
Width 750 Height 500;
Child;
NoMaximize;
NoSize

@10,10 Grid Mostracontameta;
     Width 300 Height 450;
     Headers{};
     Widths {}

@20,500 Button Calctotal;     
	Caption 'Calcular Meta';
	Width 200;
	Action {||PjanelaMeta()}
    
End Window 
Center Window janelamenumeta
Activate Window janelamenumeta
    
Return
*-------------------------*
Function Fmostragridtotal(DataIni, DataFin)
*-------------------------*
janelamenumeta.Mostracontameta.deleteallitems

BaseMark->(OrdSetFocus(1))
BaseMark->(DbSeek(DtoS(DataFin),.T.))
	     
	Do While ! BaseMark->dataorc < DataIni .and. ! BaseMark->(Eof()) 
	     
		If BaseMark->dataorc > DataFin	
	          BaseMark->(DbSkip())	
	          Loop
	     Endif
	    
	     Add Item{}to Mostraconta of janelaMenuTotal
	     
	     BaseMark->(DbSkip())
	     
	Enddo
     
Return
*-------------------------*
Procedure PjanelaMeta()
*-------------------------*
Define Window janelameta;
At 0 , 0;
Width 750 Height 500;
Child;
Nomaximize;
Nosize;
On Init {||mudaParametro(janelameta.cb_MesDia.value)}

	@25,100 Label apelidorc orcamento value 'nome orcamento:'

	@50,100 Textbox peganomeorc Width 300
    
    @75,100 Label infohorapreco Value 'Calcular meta por';
        Width 300 Height 25 Font 'Arial' Size 09 Bold
    
    @100,100 Combobox cb_MesDia;
    Items {'hora', 'Preço'};
    Value 1 ;
    Width 110 Font 'Arial' Size 9 ;
    On Change {|| mudaParametro(janelameta.cb_MesDia.value)}
     
    @125,100 Label infometa1 Width 300 Height 25 Font 'Arial' Size 09 Bold
    
  	@150,100 Label realmeta1 Width 20 Height 25 Font 'Arial' Size 09 Bold
    
    @150,120 Textbox InputMeta Width 150
    
    @175,100 Label infometa2 Width 300 Height 25 Font 'Arial' Size 09 Bold
    
    @200,100 Label realmeta2 Width 20 Height 25 Font 'Arial' Size 09 Bold
    
    @200,120 Textbox Inputhorapreco Width 150
    
    @250,100 Label infometa3 Width 300 Height 25 Font 'Arial' Size 09 Bold
    
    @275,100 Label realmeta3 Width 20 Height 25 Font 'Arial' Size 09 Bold
    
    @275,120 Textbox Showhorapreco Width 150 Readonly
    
    @125,425 Button chamaCalcmeta;
         Caption 'Calcular' Width 150;
         Action {||janelameta.Showhorapreco.value := Alltrim(Str(Fcalculameta(janelameta.InputMeta.value,;
         janelameta.Inputhorapreco.value)))}
    
    @175,425 Button gravaCalcmeta;
         Caption 'Gravar' Width 150;
         Action {||janelameta.Showhorapreco.value := Alltrim(Str(Fcalculameta(janelameta.InputMeta.value,;
         janelameta.Inputhorapreco.value))), janelameta.Release}
    
End Window 
Center Window janelameta
Activate Window janelameta 
    
Return 

*-------------------------*
Function mudaParametro(horaoupreco)
*-------------------------*
if horaoupreco == 2

janelameta.infometa1.value := 'Meta desejada:'
janelameta.realmeta1.value := 'R$'
janelameta.infometa2.value := 'Preço das horas: '
janelameta.realmeta2.value := 'R$'
janelameta.infometa3.value := 'Horas necessário para alcançar a meta:'
janelameta.realmeta3.value := 'Qtd'

else

janelameta.infometa1.value := 'Meta desejada:'
janelameta.realmeta1.value := 'R$'
janelameta.infometa2.value := 'Quantidade de horas: '
janelameta.realmeta2.value := 'Qtd'
janelameta.infometa3.value :='Preço necessário para alcançar a meta:'
janelameta.realmeta3.value := 'R$'

endif

Return

*-------------------------*
Function Fcalculameta(mMeta,mHoraPreco)
*-------------------------*
Result:= Val(mMeta) / Val(mHoraPreco)

Return (Result)