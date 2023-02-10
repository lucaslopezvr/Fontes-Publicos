

//Bibliotecas
#INCLUDE "Totvs.ch"
#INCLUDE "FWMVCDef.ch"

/*---- MVC - Modelo X  ---------*/  

//Variaveis Estaticas 
Static cTitulo   := "ML1 x ML2 x ML3"
Static cTabPai   := "ML1" // Fabricantes
Static cTabFilho := "ML2" // Veiculos
Static cTabNeto  := "ML3" // Motoristas

/*---- FUNCTION ---------------------------------------------------------------------*/
User Function xMVC03()

	Local   aArea   := GetArea()
	Local   oBrowse := Nil
	Private aRotina := {}

	//Definição do Menu
	aRotina := MenuDef()

	//Instanciando o Browse
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias(cTabPai)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	oBrowse:Activate()

	RestArea(aArea)
Return Nil 

/*---- MENU -------------------------------------------------------------------------*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.xMVC03" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.xMVC03" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.xMVC03" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.xMVC03" OPERATION 5 ACCESS 0

Return aRotina

/*----- MODELO ----------------------------------------------------------------------*/
Static Function ModelDef()

	Local oStruPai    := FwFormStruct(1,cTabPai)	
	Local oStruFilho  := FwFormStruct(1,cTabFilho)
	Local oStruNeto   := FwFormStruct(1,cTabNeto)
	Local aRelFilho   := {}
	Local aRelNeto    := {}
	Local oModel 	  := Nil
	Local bPre	  := Nil
	Local bPos	  := Nil
	Local bCommit     := Nil 
	Local bCancel     := Nil 

	
	oModel	:= MPFormModel():New("xMVC03M", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("ML1MASTER", /*cOwner*/ , oStruPai)
	oModel:AddGrid("ML2DETAIL","ML1MASTER"   , oStruFilho)
	oModel:AddGrid("ML3DETAIL","ML2DETAIL"   , oStruNeto)
	oModel:SetPrimaryKey({})

	//RelaçãoVa Pai/Filho (ML1/ML2)
	oStruFilho:SetProperty("ML2_CODFAB", MODEL_FIELD_OBRIGAT, .F.)
	aAdd(aRelFilho, {"ML2_FILIAL","FWxFilial('ML2')"})
	aAdd(aRelFilho, {"ML2_CODFAB", "ML1_CODFAB"})
	oModel:SetRelation("ML2DETAIL",aRelFilho, ML2->((IndexKey(1))))

	// Para colocar filtros na consulta padrão da tabela ML2, deve-se
	// incluir através do Configurador 

	//Relação Filho/Neto (ML2/ML3)
	aAdd(aRelNeto, {"ML3_FILIAL", "FwXFilial('ML3')"})
	aAdd(aRelNeto, {"ML3_CODVEI", "ML2_CODVEI"})
	oModel:SetRelation("ML3DETAIL",aRelNeto, ML3->((IndexKey(1))))

	//Definindo campos unicos da linha
	//oModel:GetModel("ML1MASTER"):SetUniqueLine({"ML1_CODFAB"})
	oModel:GetModel("ML2DETAIL"):SetUniqueLine({"ML2_CODVEI"})
	oModel:GetModel("ML3DETAIL"):SetUniqueLine({"ML3_CODMOT"})

Return oModel

/*----- VIEW ------------------------------------------------------------------------*/
Static Function ViewDef()

	Local oModel     := FWLoadModel("xMVC03")
	Local oStruPai   := FwFormStruct(2, cTabPai) 
	Local oStruFilho := FwFormStruct(2, cTabFilho)
	Local oStruNeto  := FwFormStruct(2, cTabNeto)
	Local oView      

	//Criação das Views do Cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ML1", oStruPai  , "ML1MASTER")
	oView:AddGrid("VIEW_ML2", oStruFilho , "ML2DETAIL")
	oView:AddGrid("VIEW_ML3", oStruNeto  , "ML3DETAIL")

	//Definindo Cabec e Grids
	oView:CreateHorizontalBox("CABEC_PAI"   , 65)
	oView:CreateHorizontalBox("ESPACO_MEIO" , 35)
		oView:CreateVerticalBox("GRID_FILHO", 50, "ESPACO_MEIO")
		oView:CreateVerticalBox("GRID_NETO" , 50, "ESPACO_MEIO")
	oView:SetOwnerView("VIEW_ML1","CABEC_PAI")
	oView:SetOwnerView("VIEW_ML2","GRID_FILHO")
	oView:SetOwnerView("VIEW_ML3","GRID_NETO")


	//Titulos
	oView:EnableTitleView("VIEW_ML1", "Pai - ML1")
	oView:EnableTitleView("VIEW_ML2", "Filho - ML2")
	oView:EnableTitleView("VIEW_ML3", "Neto - ML3")

	//Incremental Grid
	oView:AddIncrementField("VIEW_ML3", "A5_LOJA")

Return oView



// Gatilho para preenchimento da descrição do Veículo
User Function xGatMVC1()

Local oModel    := FWModelActive()
Local cDesc     := Posicione("ML2", 2, FwXFilial("ML2") + ML2->ML2_CODVEI , "ML2_DESCRI") 

//Fazendo o filtro na grid, com o código do fabricante
oModel:GetModel('ML2DETAIL'):SetLoadFilter(, "ML2_CODFAB ='" + "" + "' " ) 
oModel:SetValue('ML2DETAIL','ML2_DESCRI',cDesc)

Return cDesc


// Gatilho para preenchimento do nome do Motorista
User Function xGatMVC2()

Local oModel    := FWModelActive()
Local cDesc     := Posicione("ML3", 2, FwXFilial("ML3") + ML3->ML3_CODMOT , "ML3_NOME") 

oModel:SetValue('ML3DETAIL','ML3_NOME',cDesc)

Return cDesc

