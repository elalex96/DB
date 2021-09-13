USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_Ins_WDEA_Bitacora_AdincoSAP]    Script Date: 10/09/2021 08:38:11 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[SP_Ins_WDEA_Bitacora_AdincoSAP]
(
	@IdBitacoraLectura		int
)
as
begin
		declare @isDebug bit
		select @isDebug = 1
		/*
		select *
		from	WDEA_Layout_T
		where	CreadoEL	< '2021-09-06'
		and		RowN = 42
		*/

		/*Actualice estos registros para que pudieran arrojar informacion de salida*/
		--if ( @isDebug = 1) 
		--begin
		--	update	WDEA_Layout_T
		--	set		--Terminos_Pago	=	'Terminos de Prueba',
		--			--Justificacion	=	'Justificacion de Prueba',
		--			--Validity_Per_Start	=	'16/11/2020',
		--			--Validity_Period_End =	'19/12/2020',
		--			--Release_State		=	'xx',
		--			--Order_Unit			=	'KG',
		--			Short_Text			=	'SERVICIO ELECTRICO'
		--	where	RowN				in	(41, 42)
			
						
		--end

		--select Release_State, * from WDEA_Layout_T where RowN in (41,42)

		declare @maxNoConsecutivo int
		--Tabla para convertir de string a los tipos de datos correctos
		CREATE TABLE #tmpData(
			ID						int,
			Item					nvarchar(20)	NULL,
			Purch_Organization		nvarchar(1000)	NULL,
			Cost_Center				nvarchar(1000)	NULL,
			WBS_Element				nvarchar(1000)	NULL,
			Short_Text				nvarchar(max)	NULL,
			OUTLINE_AGREEMENT		nvarchar(100)	NULL,
			Validity_Per_Start		date			NULL,
			Validity_Period_End		date			NULL,
			Deletion_Indicador		nvarchar(5)		NULL,
			Plant					nvarchar(10)	NULL,
			Order_Quantity			float			NULL,
			Order_Unit				nvarchar(10)	NULL,
			Net_Price				float			NULL,
			Currency				nvarchar(5)		NULL,
			Vendor_Supplying_Plant	nvarchar(100)	NULL,
			Purchasing_Document		nvarchar(20)	NULL,
			Release_State			nvarchar(5)		NULL,
			Name_of_Vendor			nvarchar(100)	NULL,
			Order_Price_Unit		nvarchar(5)		NULL,
			Net_Order_Value			float			NULL,
			Requisitioner			nvarchar(100)	NULL,
			Terminos_Pago			nvarchar(100)	NULL,
			Justificacion			nvarchar(max)	NULL,
			Pais					nvarchar(5)		null,
			Contrato				nvarchar(5)		null,
			FaseContrato			nvarchar(5)		null,
			CentroCosto				nvarchar(5)		null,
			ConsecutivoPozo			nvarchar(5)		null,
			TareaPresupuesto		int				null,
			SubTareaPresupuesto		nvarchar(5)		null,
			X						nvarchar(5)		null,
		) 


		--Tabla para cachar los errores y posteriormente excluir de la busqueda final esos registros
		create table #tmpErrores
		(
			Id		int identity,
			RowId	int,
			Columna	varchar(10),
			Error	varchar(max),
			esError	bit
		)

		create table #tmpLineasPresupuesto
		(
			IdentificadorWDEA		varchar(3), 
			IdInstalacionAdinco		int, 
			Tarea					int, 
			IdContrato				int, 
			IdLineaPresupuestoMes	int, 
			IdPozo					varchar(10)
		)

		create table #tmpLineasPresupuestoFinales
		(
			Id						int,
			IdLineaPresupuestoMes	int
		)

		create table #tmpVendorSupplyingPlant
		(
			Id	int
		)

		create table #tmpRequisitioner
		(
			Id			int,
			IdUsuario	int
		)

		create table #tmpRegistrosPorDocumento
		(
			Purchasing_Document	varchar(50),
			Total				int,
			Id					int
		)

		create table #tmpRegistrosValidadosPorDocumento
		(
			Purchasing_Document	varchar(50),
			Total				int,
			Id					int
		)

		create table #tmpMateriales
		(
			Id					int,
			IdMaterial			int,
			DescripcionCorta	varchar(max)
		)


		--Convertimos los tipos de Dato
		insert	into	#tmpData
		select	--top 1
				Id						=	RowN,--ROW_NUMBER() OVER( ORDER BY RowN),
				Item					=	case when len(Item)						= 0 then null else item						end,
				Purch_Organization		=	case when len(Purch_Organization)		= 0 then null else Purch_Organization		end,
				Cost_Center				=	case when len(Cost_Center)				= 0 then null else Cost_Center				end,
				WBS_Element				=	case when len(WBS_Element)				= 0 then null else WBS_Element				end,
				Short_Text,
				Outline_Agreegement,
				Validity_Per_Start		=	case when len(rtrim(ltrim(Validity_Per_Start)))>6 then cast(substring(Validity_Per_Start,7,4)+'-'+ substring(Validity_Per_Start,4,2)+'-'+substring(Validity_Per_Start,0,3)		as date) else null end,
				Validity_Period_End		=	case when len(rtrim(ltrim(Validity_Period_End)))>6 then cast(substring(Validity_Period_End,7,4)+'-'+ substring(Validity_Period_End,4,2)+'-'+substring(Validity_Period_End,0,3)	as date) else null end,
				Deletion_Indicador,
				Plant,
				cast(Order_Quantity as float),
				Order_Unit,
				cast(replace(Net_Price,',','') as float),
				Currency				=	case when len(Currency)					= 0 then null else Currency					end,
				Vendor_Supplying_Plant	=	case when len(Vendor_Supplying_Plant)	= 0 then null else Vendor_Supplying_Plant	end,
				Purchasing_Document		=	case when len(Purchasing_Document)		= 0 then null else Purchasing_Document		end,
				Release_State			=	case when len(Release_State)			= 0 then null else Release_State			end,
				Name_of_Vendor,
				Order_Price_Unit,
				Net_Order_Value			=	case when len(Net_Order_Value)			= 0 then null else cast(replace(Net_Order_Value,',','') as float)	end,
				Requisitioner			=	case when len(Requisitioner)			= 0 then null else Requisitioner									end,
				Terminos_Pago			=	case when len(Terminos_Pago)			= 0 then null else Terminos_Pago									end,
				Justificacion			=	case when len(Justificacion)			= 0 then null else Justificacion									end,
				Pais					=	substring(WBS_Element,0,3),
				Contrato				=	substring(WBS_Element,4,3),
				FaseContrato			=	substring(WBS_Element,7,1),
				CentroCosto				=	substring(WBS_Element,9,2),
				ConsecutivoPozo			=	substring(WBS_Element,12,3),
				TareaPresupuesto		=	cast(substring(WBS_Element,15,3) as int),
				SubTareaPresupuesto		=	substring(WBS_Element,19,1),
				x						=	substring(WBS_Element,20,10)
		from	WDEA_Layout_T
		where	IdBitacoraLectura	=	@IdBitacoraLectura	--CreadoEL	< @fecha --'2021-09-06'

		--select 111,* from WDEA_Layout_T		where WBS_Element = 'MX-OGAD-DR-071096.A000NC'
		--select 222,* from #tmpData			where WBS_Element = 'MX-OGAD-DR-071096.A000NC'
		--select * from WDEA_Layout_T
		--select * from #tmpData
	
			/*Validaciones*/

			/*Item*/
			insert into #tmpErrores	select Id, 'A', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el número de partida en la celda A, Fila '+cast(Id as varchar(10))+'.',1				from #tmpData where Item is null order by Id
			/*******************/
			/*Purch_Organization*/
			insert into #tmpErrores	select Id, 'B', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el contrato en la celda B, Fila '+cast(Id as varchar(10))+'.',1						from #tmpData where Purch_Organization is null order by Id

			insert into #tmpErrores	select Id, 'B', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el contrato en la celda B, Fila '+cast(Id as varchar(10))+'.',1						from #tmpData where Purch_Organization not in ('MOG','MCY','M30','M16','M17') order by Id
			/*******************/

			/*WBS_Element*/
			insert into #tmpErrores	select Id, 'D', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró WBS en la celda D, Fila '+cast(Id as varchar(10))+'.',1								from #tmpData where WBS_Element is null order by Id
	
			insert into #tmpErrores
			select Id, 'D', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontraro WBS Element en la celda D, Fila '+cast(Id as varchar(10))+'.',1												from #tmpData where WBS_Element is null order by Id

			/*Se obtienen las lineas de Presupuesto*/
			insert into		#tmpLineasPresupuesto
			SELECT			IdentificadorWDEA, IdInstalacionAdinco, Tarea, S.IdContrato, LMP.IdLineaPresupuestoMes, IdPozo = p.IdPozoSAP
			FROM			Adinco..CO_LineaPresupuestoMes				AS LMP
			JOIN			Petrovendor..WDEA_SubTareasPresupuestales	AS S	ON LMP.IdServicio		= S.IdSubtarea
			JOIN			Petrovendor..PozosSAP						AS P	ON LMP.IdInstalacion	= P.IdInstalacionAdinco
			JOIN			Adinco..CO_Presupuesto						AS PR	ON LMP.IdPresupuesto	= PR.IdPresupuesto AND PR.Activo = 1
			group by		S.IdentificadorWDEA,
							P.IdInstalacionAdinco,
							S.Tarea,
							S.IdContrato,
							LMP.IdLineaPresupuestoMes, 
							p.IdPozoSAP
			
			--select * from #tmpLineasPresupuesto
					
			--SELECT			IdentificadorWDEA, IdInstalacionAdinco, Tarea, S.IdContrato, LMP.IdLineaPresupuestoMes, IdPozo = p.IdPozoSAP, LMP.IdInstalacion,P.IdInstalacionAdinco
			--FROM			Adinco..CO_LineaPresupuestoMes				AS LMP
			--JOIN			Petrovendor..WDEA_SubTareasPresupuestales	AS S	ON LMP.IdServicio		= S.IdSubtarea
			--JOIN			Petrovendor..PozosSAP						AS P	ON LMP.IdInstalacion	= P.IdInstalacionAdinco
			--JOIN			Adinco..CO_Presupuesto						AS PR	ON LMP.IdPresupuesto	= PR.IdPresupuesto AND PR.Activo = 1
			--group by		S.IdentificadorWDEA,
			--				P.IdInstalacionAdinco,
			--				S.Tarea,
			--				S.IdContrato,
			--				LMP.IdLineaPresupuestoMes, 
			--				p.IdPozoSAP,
			--				LMP.IdInstalacion
			/*********************SE MODIFICÓ PARA QUE PUDIERA ARROJAR AL MENOS UNOS REGISTROS VALIDOS********************************/
			
			--if ( @isDebug = 1)
			--begin
			--	select * from #tmpLineasPresupuesto
			--	update #tmpLineasPresupuesto set IdPozo = '071'
			--	select * from #tmpLineasPresupuesto
			--end
	
			/*Se guardan en la tabla de #tmpErrores aquellos registors que no existen en el presupuesto cargado y activo en ADINCO.*/
			insert into #tmpErrores
			select		ID,	'D',  'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La linea de presupuesto de la celda D, Fila '	+	cast(Id as varchar(10))	+	' No existe en ADINCO.',1
			from		#tmpData where ID not in(
											--select		t1.ID,	'D',  'No se encontraro la linea de presupuesto WBS Element en la celda D, Fila '+cast(Id as varchar(10))+'.'		, t1.Purch_Organization, *
											select		t1.ID
											from		#tmpData				t1
											inner join	#tmpLineasPresupuesto	t2
											on			t1.SubTareaPresupuesto											=	t2.IdentificadorWDEA	COLLATE SQL_Latin1_General_CP1_CI_AS
											AND			t1.ConsecutivoPozo		COLLATE SQL_Latin1_General_CP1_CI_AS	=	t2.IdPozo
											inner join	PurchaseOrganization	t3
											on			t1.Contrato				=	t3.Siglas	COLLATE SQL_Latin1_General_CP1_CI_AS	
											and			t3.IdContrato			=	t2.IdContrato
										)
	
			/*Se guardan los id's y las lineas de presupuesto aprobadas*/
			insert into #tmpLineasPresupuestoFinales
			select		t1.ID,
						t2.IdLineaPresupuestoMes
			from		#tmpData				t1
			inner join	#tmpLineasPresupuesto	t2
			on			t1.SubTareaPresupuesto											=	t2.IdentificadorWDEA	COLLATE SQL_Latin1_General_CP1_CI_AS
			AND			t1.ConsecutivoPozo		COLLATE SQL_Latin1_General_CP1_CI_AS	=	t2.IdPozo
			inner join	PurchaseOrganization	t3
			on			t1.Contrato				=	t3.Siglas	COLLATE SQL_Latin1_General_CP1_CI_AS	
			and			t3.IdContrato			=	t2.IdContrato

			--select * from #tmpLineasPresupuestoFinales
			
			/*******************/
	
	
	
			/*Validity_Per_Start*/
			insert into #tmpErrores	select Id, 'G', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la fecha de inicio en la celda G, Fila '+cast(Id as varchar(10))+'.',1				from #tmpData where Validity_Per_Start is null order by Id

			insert into #tmpErrores	select Id, 'G', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : El formato de la fecha de inicio en la celda G, Fila '+cast(Id as varchar(10))+' es incorrecto.',1	from #tmpData 
			where	Validity_Per_Start is not null 
			and		(year(Validity_Per_Start) < 1900)
			and		(month(Validity_Per_Start) < 1 or month(Validity_Per_Start)>12)
			and		(day(Validity_Per_Start) < 1 and day(Validity_Per_Start)>31)
			order by Id
			/*******************/
	
			/*Validity_Per_Start*/
			insert into #tmpErrores	select Id, 'H', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la fecha de inicio en la celda H, Fila '+cast(Id as varchar(10))+'.',1				from #tmpData where Validity_Per_Start is null order by Id

			insert into #tmpErrores	select Id, 'H', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : El formato de la fecha de inicio en la celda H, Fila '+cast(Id as varchar(10))+' es incorrecto.',1	from #tmpData 
			where	Validity_Per_Start is not null 
			and		year(Validity_Per_Start) <1900
			and		(month(Validity_Per_Start) < 1 and month(Validity_Per_Start)>12)
			and		(day(Validity_Per_Start) < 1 and day(Validity_Per_Start)>31)
			order by Id
			/*******************/

			/*Plant*/
			insert into #tmpErrores	select Id, 'J', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la empresa en la celda J, Fila '+cast(Id as varchar(10))+'.',1						from #tmpData where Plant is null order by Id
			--insert into #tmpErrores select Id, 'J', 'La columna Plant contiene diferente a MX01'														from #tmpData where Plant <> 'MX01' order by Id
			/*******************/

			/*Order_Quantity*/
			insert into #tmpErrores	select Id, 'K', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la cantidad de la partida en la celda K, Fila '+cast(Id as varchar(10))+'.',1		from #tmpData where Order_Quantity is null order by Id

			insert into #tmpErrores	select Id, 'K', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La cantidad de la partida en la celda K, Fila '+cast(Id as varchar(10))
			+' no tiene el formato numérico esperado.',1																								from #tmpData where len( cast(Order_Quantity - cast(Order_Quantity as int) as varchar(10))) >6 order by Id
			/*******************/

			/*Order_Unit*/
			insert into #tmpErrores	select Id, 'L', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la unidad de la partida en la celda L, Fila '+cast(Id as varchar(10))+'.',1			from #tmpData where Order_Unit is null order by Id
			/*******************/

			/*Net_Price*/
			insert into #tmpErrores	select Id, 'M', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el costo de la partida en la celda M, Fila '+cast(Id as varchar(10))+'.',1			from #tmpData where Net_Price is null order by Id
	
			insert into #tmpErrores	select Id, 'M', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La cantidad de la partida en la celda M, Fila '+cast(Id as varchar(10))
			+' no tiene el formato numérico esperado',1																									from #tmpData where len( cast(Net_Price - cast(Net_Price as int) as varchar(10))) >6 order by Id
			/*******************/

			/*Currency*/
			insert into #tmpErrores	select Id, 'N', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la moneda en la celda N, Fila '+cast(Id as varchar(10))+'.',1						from #tmpData where Currency is null order by Id
			/*******************/

			/*Vendor_Supplying_Plant*/
			insert into #tmpErrores	select Id, 'O', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el registro en la celda O, Fila '+cast(Id as varchar(10))+'',1						from #tmpData where Vendor_Supplying_Plant is null order by Id
			--Se inserta en la temporal #tmpVendorSupplyingPlant registros de aquellos que si estan en el catálogo
			insert into #tmpVendorSupplyingPlant
			select		t1.Id 
			from		#tmpData					t1
			inner join	DEA_ProveedorDescripcionSAP	t2
			on			t2.IdProveedor	=	cast ( SUBSTRING(t1.Vendor_Supplying_Plant, 1, CHARINDEX(' ', t1.Vendor_Supplying_Plant) - 1) as int)
			where		t1.Vendor_Supplying_Plant is not null order by t1.Id
			--Se insertan en la tabla de errores aquellos registros de #tmpData (tabla principal con todos los registros) que no esten en #tmpVendorSupplyingPlant
			insert into #tmpErrores
			select		t1.ID,	'O', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el registro en la celda O, Fila '+cast(t1.Id as varchar(10))+'',1 --,t1.Vendor_Supplying_Plant	, SUBSTRING(t1.Vendor_Supplying_Plant, 1, CHARINDEX(' ', t1.Vendor_Supplying_Plant) - 1)			
			from		#tmpData					t1
			left join	#tmpVendorSupplyingPlant	t2
			on			t1.ID						=	t2.ID
			where		t2.ID						is	null
			order by 1,2
			/*******************/
	
	
			/*Purchasing_Document*/
			insert into #tmpErrores
			select Id, 'P', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el número de orden de compra de SAP en la celda P, Fila '
							+cast(Id as varchar(10))+'.',1																								from #tmpData where Purchasing_Document is null order by Id
			/*******************/

			/*Release_State*/
			insert into #tmpErrores	select Id, 'Q', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La columna Q - Fila '+cast(Id as varchar(10))+'. Release State contiene valores nulos',1			from #tmpData where Release_State is null order by Id
			/*******************/

			insert into #tmpErrores	select Id, 'Q', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La columna Q - Fila '+cast(Id as varchar(10))+'. Release State contiene valores diferentes a XX',1	from #tmpData where Release_State <> 'XX' order by Id
			/*******************/

			/*Net_Order_Value*/
			insert into #tmpErrores
			select Id, 'T', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el costo de la orden de compra en la celda T, Fila '
							+cast(Id as varchar(10))+'.',1																from #tmpData where Net_Order_Value is null order by Id

			insert into #tmpErrores
			select Id, 'T', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La cantidad de la partida en la celda T, Fila '+cast(Id as varchar(10))
							+' no tiene el formato numérico esperado',1													from #tmpData where len( cast(Net_Order_Value - cast(Net_Order_Value as int) as varchar(10))) >6 order by Id
			/*******************/	
	
			/*Requisitioner*/				
			insert into #tmpErrores
			select Id, 'U', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el usuario requisitor en la celda U, Fila '+cast(Id as varchar(10))+'.',1	from #tmpData where Requisitioner is null order by Id
			--Se Obtienene los registros que si se encuentran en la tabla DEA_UsuarioSolicitanteSAP
			insert into	#tmpRequisitioner
			select		ID,
						t2.IdUsuario
			from		#tmpData					t1
			inner join	DEA_UsuarioSolicitanteSAP	t2
			on			t1.Requisitioner			=	t2.DescripcionSAP COLLATE SQL_Latin1_General_CP1_CI_AS
			group by	Id, t2.IdUsuario
			--Se insertan en la tabla de errores aquellos registros que no se encuentren en la tabla DEA_UsuarioSolicitanteSAP
			insert into #tmpErrores
			select		t1.ID,	'U', 'La orden de compra '+cast(isnull(t1.Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : El usuario requisitor de la celda U, Fila '+cast(isnull(t1.Id,'') as varchar(10))+' No existe en ADINCO.',1
			from		#tmpData					t1
			left join	#tmpRequisitioner			t2
			on			t1.ID						=	t2.ID
			where		t2.ID						is	null
			order by	1,2


			/*Terminos_Pago*/
			insert into #tmpErrores
			select Id, 'V', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontraron términos de pago en la celda V, Fila '+cast(Id as varchar(10))+'.',1										from #tmpData where Terminos_Pago is null order by Id

			insert into #tmpErrores
			select Id, 'V', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontraron términos de pago en la celda V, Fila '+cast(Id as varchar(10))+'.',1										from #tmpData where IsNumeric(Terminos_Pago) = 1 AND CAST(Terminos_Pago as VARCHAR(5)) NOT LIKE '%.%' order by Id

			/*Justificacion*/
			insert into #tmpErrores 
			select Id, 'W', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la justificación en la celda W, Fila '+cast(Id as varchar(10))+'.',1											from #tmpData where Justificacion is null order by Id


		/*Obtengo el total de registros por OC*/
		insert into	#tmpRegistrosPorDocumento
		select		Purchasing_Document, 
					Total					=	count(*),
					Id						=	max(ID)
		from		#tmpData 
		group by	Purchasing_Document

		/*Obtengo el total de registros que se validaron exitosamente por OC*/
		insert into	#tmpRegistrosValidadosPorDocumento
		select		Purchasing_Document, 
					Total				=	count(*),
					Id					=	max(t1.ID)
		from		#tmpData			t1
		left join	#tmpErrores			t2
		on			t1.ID				=	t2.RowId
		where		t2.RowId			is	null
		group by	Purchasing_Document



		/*Inserto en Bitacora un mensaje de registro exitoso por cada OC que si se hayan validado todas sus filas*/
		/*row columna error*/
		insert into #tmpErrores
		select		t1.id,
					'P',
					'La orden de compra ' + CAST(t1.Purchasing_Document AS varchar(50)) + ' fue registrada exitosamente',0
		from		#tmpRegistrosPorDocumento			t1
		inner join	#tmpRegistrosValidadosPorDocumento	t2
		on			t1.Purchasing_Document				=	t2.Purchasing_Document
		and			t1.Total							=	t2.Total



		/*Se guardan todos los errores en la nueva Bitacora*/
		insert into WDEA_Bitacora_AdincoSAP
		select	getdate(), Error , ROW_NUMBER() OVER( ORDER BY esError,RowID), @IdBitacoraLectura from #tmpErrores where esError = 1 group by esError, RowId, Columna, Error order by RowId
		/*Se obtiene el consecutivo donde se quedó la bitacora*/
		select	@maxNoConsecutivo = max(NoConsecutivoProcesamiento) 
		from	WDEA_Bitacora_AdincoSAP
		/*Se guarda un registro de aquellos rows que se procesaron con exito*/
		insert into WDEA_Bitacora_AdincoSAP
		select	--RowId, Columna,
				getdate(), Error , ROW_NUMBER() OVER( ORDER BY esError,RowID)+@maxNoConsecutivo, @IdBitacoraLectura from #tmpErrores where esError = 0 group by esError, RowId, Columna, Error order by RowId

				--select * from #tmpErrores where esError = 0 

		--select	* from	WDEA_Bitacora_AdincoSAP order by Id

		--select * from #tmpErrores where Columna = ''
		/************************************/
		

		insert into	#tmpMateriales
		select		t1.Id,
					mat.IdMaterial,
					mat.DescripcionCorta
		from		#tmpErrores		t2 
		inner join	#tmpData		t1
		on			t1.ID			=	t2.RowId
		inner join	dbo.MM_Material					mat
		on			mat.DescripcionCorta			=		t1.Short_Text COLLATE SQL_Latin1_General_CP1_CI_AS
		where  t2. esError = 0
		group by	t1.Id,
					mat.IdMaterial,
					mat.DescripcionCorta


		
		/*Se muestra el resultado final donde a #tmpData sele excluyen aquellos ID's que coincidan con los contenidos dentro de #tmpErrores*/
		/*
		select		
					t1.ID,							Pais,					IdContrato,						Contrato,
					FaseContrato,					CentroCosto,			ConsecutivoPozo,				TareaPresupuesto,
					SubTareaPresupuesto,			X,						Item,							Purch_Organization,
					Cost_Center,					WBS_Element,			mat.idMaterial,					Short_Text,
					OUTLINE_AGREEMENT,			Validity_Per_Start,		Validity_Period_End,			Deletion_Indicador,
					Plant,							Order_Quantity,			u.IdUnidad,						Order_Unit,
					Net_Price,						re.IdUsuario,			lpm.IdLineaPresupuestoMes,		IdMoneda,
					Currency,						p.IdProveedor,			Vendor_Supplying_Plant,			Purchasing_Document,
					Release_State,					Name_of_Vendor,			Order_Price_Unit,				Net_Order_Value,
					Requisitioner,					Terminos_Pago,			Justificacion
		from		#tmpData						t1
		inner join	PurchaseOrganization			po
		on			t1.Contrato						=		po.siglas COLLATE SQL_Latin1_General_CP1_CI_AS
		inner join	Adinco..PV_TipoMoneda			mo
		on			mo.TipoMonedaCorto				=		t1.Currency
		inner join	#tmpLineasPresupuestoFinales	lpm
		on			lpm.Id							=		t1.ID
		inner join	DEA_ProveedorDescripcionSAP		p
		on			p.IdProveedor					=		cast ( SUBSTRING(t1.Vendor_Supplying_Plant, 1, CHARINDEX(' ', t1.Vendor_Supplying_Plant) - 1) as int)
		inner join	#tmpRequisitioner				re
		on			re.Id							=		t1.ID
		inner join	dbo.PV_MM_MaterialUnidad		u
		on			u.umb							=		t1.Order_Unit COLLATE SQL_Latin1_General_CP1_CI_AS
		inner join	#tmpMateriales					mat
		on			mat.DescripcionCorta			=		t1.Short_Text COLLATE SQL_Latin1_General_CP1_CI_AS
		and			mat.ID							=		t1.id
		left join	#tmpErrores			t2
		on			t1.ID				=	t2.RowId
		and			t2.esError			=	1
		where		t2.RowId			is	null

		order by Id
		*/
		
		--select		*
		--from		#tmpData						t1
		--inner join	PurchaseOrganization			po
		--on			t1.Contrato						=		po.siglas COLLATE SQL_Latin1_General_CP1_CI_AS
		--inner join	Adinco..PV_TipoMoneda			mo
		--on			mo.TipoMonedaCorto				=		t1.Currency
		--inner join	#tmpLineasPresupuestoFinales	lpm
		--on			lpm.Id							=		t1.ID
		--inner join	DEA_ProveedorDescripcionSAP		p
		--on			p.IdProveedor					=		cast ( SUBSTRING(t1.Vendor_Supplying_Plant, 1, CHARINDEX(' ', t1.Vendor_Supplying_Plant) - 1) as int)
		--inner join	#tmpRequisitioner				re
		--on			re.Id							=		t1.ID
		--inner join	dbo.PV_MM_MaterialUnidad		u
		--on			u.umb							=		t1.Order_Unit COLLATE SQL_Latin1_General_CP1_CI_AS
		----inner join	#tmpMateriales					mat
		----on			mat.DescripcionCorta			=		t1.Short_Text COLLATE SQL_Latin1_General_CP1_CI_AS
		----and			mat.ID							=		t1.id
		--left join	#tmpErrores			t2
		--on			t1.ID				=	t2.RowId
		--and			t2.esError			=	1
		--where		t2.RowId			is	null

		insert into WDEA_PurchasingDocumentsImportados
					(	IDLAYOUT,			ITEM,				PURCHASE_ORGANIZATION,	IDCONTRATO,			COST_CENTER,	WBS_ELEMENT,	IDLINEAPRESUPUESTOMES,		OUTLINE_AGREEMENT,			SHORT_TEXT,		IDMATERIAL,				VALIDITY_PER_START,	VALIDITY_PER_END,	DELETION_INDICATOR,	
						PLANT,				ORDER_QUANTITY,		ORDER_UNIT,				IDUNIDAD,			NET_PRICE,		CURRENCY,		IDMONEDA,					VENDOR_SUPPLIYING_PLANT,	IDPROVEEDOR,	PURCHASING_DOCUMENT,	RELEASE_STATE,		NAME_OF_VENDOR,		ORDER_PRICE_UNIT,	
						NET_ORDER_VALUE,	REQUISITIONER,		IDUSUARIOSOLICITANTE,	TERMINOS_DE_PAGO,	JUSTIFICACION, IdBitacora)
		select			@IdBitacoraLectura,	Item,				Purch_Organization,		IdContrato,			Cost_Center,	WBS_Element,	lpm.IdLineaPresupuestoMes,	OUTLINE_AGREEMENT,			Short_Text,		mat.IdMaterial,			Validity_Per_Start,	Validity_Period_End,Deletion_Indicador,
						Plant,				Order_Quantity,		Order_Unit,				u.IdUnidad,			Net_Price,		Currency,		IdMoneda,					Vendor_Supplying_Plant,		p.IdProveedor,	Purchasing_Document,	Release_State,		Name_of_Vendor,		Order_Price_Unit,	
						Net_Order_Value,	Requisitioner,		re.IdUsuario,			Terminos_Pago,		Justificacion, @IdBitacoraLectura
					
		from		#tmpData						t1
		inner join	PurchaseOrganization			po
		on			t1.Contrato						=		po.siglas COLLATE SQL_Latin1_General_CP1_CI_AS
		inner join	Adinco..PV_TipoMoneda			mo
		on			mo.TipoMonedaCorto				=		t1.Currency
		inner join	#tmpLineasPresupuestoFinales	lpm
		on			lpm.Id							=		t1.ID
		inner join	DEA_ProveedorDescripcionSAP		p
		on			p.IdProveedor					=		cast ( SUBSTRING(t1.Vendor_Supplying_Plant, 1, CHARINDEX(' ', t1.Vendor_Supplying_Plant) - 1) as int)
		inner join	#tmpRequisitioner				re
		on			re.Id							=		t1.ID
		inner join	dbo.PV_MM_MaterialUnidad		u
		on			u.umb							=		t1.Order_Unit COLLATE SQL_Latin1_General_CP1_CI_AS
		inner join	#tmpMateriales					mat
		on			mat.DescripcionCorta			=		t1.Short_Text COLLATE SQL_Latin1_General_CP1_CI_AS
		and			mat.ID							=		t1.id
		left join	#tmpErrores			t2
		on			t1.ID				=	t2.RowId
		and			t2.esError			=	1
		where		t2.RowId			is	null

		INSERT INTO PendientesProcesarProcura_WSDEA
		(
			IdBitacora
		)
		VALUES
		(
			@IdBitacoraLectura
		);

end

