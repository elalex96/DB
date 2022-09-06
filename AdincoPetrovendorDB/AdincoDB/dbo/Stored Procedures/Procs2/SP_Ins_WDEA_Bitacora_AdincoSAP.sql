USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS SP_Ins_WDEA_Bitacora_AdincoSAP
GO
CREATE proc [dbo].[SP_Ins_WDEA_Bitacora_AdincoSAP] --16999
(
	@IdBitacoraLectura		int
)
--===============================================
-- creado por: Luis David
-- creado el: 05/09/2022
-- modificado: utilizar la tabla WDEA_WBS para obtener la línea presupuesto Issue #2012(Petrovendor)
--===============================================
AS
begin
		declare @maxNoConsecutivo int, 
		@IdProveedorWDEA int = (SELECT TOP 1 idproveedor FROM S_Proveedor WHERE rfc = 'DDE151002QY9'), 
		@IdUsuarioAdministradorAdinco int = (SELECT TOP 1 IdUsuario FROM S_Usuario WHERE Correo like '%administrador@smps-adinco.com%');
		--Tabla para cachar los errores y posteriormente excluir de la busqueda final esos registros
		DROP TABLE IF EXISTS #tmpErrores
		create table #tmpErrores
		(
			Id		int identity,
			RowId	int,
			Columna	varchar(10),
			Error	varchar(max),
			esError	bit
		)
		DROP TABLE IF EXISTS #tmpVendorSupplyingPlant
		create table #tmpVendorSupplyingPlant
		(
			Id			int,
			IdProveedor	int
		)
		DROP TABLE IF EXISTS #tmpRequisitioner
		create table #tmpRequisitioner
		(
			Id			int,
			IdUsuario	int
		)
		DROP TABLE IF EXISTS #tmpRegistrosPorDocumento
		create table #tmpRegistrosPorDocumento
		(
			Purchasing_Document	varchar(50),
			Total				int,
			Id					int
		)
		DROP TABLE IF EXISTS #tmpRegistrosValidadosPorDocumento
		create table #tmpRegistrosValidadosPorDocumento
		(
			Purchasing_Document	varchar(50),
			Total				int,
			Id					int
		)
		DROP TABLE IF EXISTS #tmpMateriales
		create table #tmpMateriales
		(
			Id					int,
			IdMaterial			int,
			DescripcionCorta	varchar(max),
			IdProvedor			int
		)
		DROP TABLE IF EXISTS #tmpIncompletedOCs
		create table #tmpIncompletedOCs
		(
			OC	varchar(max)
		)
		--Tabla para convertir de string a los tipos de datos correctos
		DROP TABLE IF EXISTS #tmpData
		CREATE TABLE #tmpData(
			ID						int ,
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
			Terminos_Pago			VARCHAR(30)			NULL,
			Justificacion			nvarchar(max)	NULL,
			Pais					nvarchar(5)		null,
			Contrato				nvarchar(5)		null,
			FaseContrato			nvarchar(5)		null,
			CentroCosto				nvarchar(5)		null,
			ConsecutivoPozo			nvarchar(5)		null,
			TareaPresupuesto		int				null,
			SubTareaPresupuesto		nvarchar(5)		null,
			X						nvarchar(5)		null
		) 
		--============================================================
		-- Se inserta la unidad 
		INSERT INTO PV_MM_MaterialUnidad(
		Unidad,				UMB,			IsActivo,	IsEliminado,		
		CreadoPor,							CreadoEn)
		SELECT distinct 
		WDL.Order_Unit,		WDL.Order_Unit, 1,			0,
		@IdUsuarioAdministradorAdinco,		GETDATE()
		FROM WDEA_Layout_T WDL
		LEFT JOIN PV_MM_MaterialUnidad UM (NOLOCK)
			ON WDL.Order_Unit = UM.Unidad
			AND UM.IsActivo = 1 AND IsEliminado = 0
		WHERE UM.Unidad IS NULL
		AND WDL.Order_Unit IS NOT NULL
		--============================================================
		-- Se inserta el Material
		--select count(*) from MM_Material

		INSERT INTO MM_Material(
		IdProveedor,		IdUnidad,		DescripcionCorta,	DescripcionLarga,
		FechaAlta,			Activo,			IsEliminado,		CreadoPor,
		IdTipoCatalogoMaestro)
		SELECT DISTINCT 
		@IdProveedorWDEA,	MU.IdUnidad,	WDL.Short_Text,		WDL.Short_Text, 
		getdate(),			1,				0 ,					@IdUsuarioAdministradorAdinco,
		3 --Bienes
		FROM 
		WDEA_Layout_T as WDL
		LEFT JOIN MM_Material as M 
			ON WDL.Short_Text = M.DescripcionCorta 
			and IdProveedor = @IdProveedorWDEA
		LEFT JOIN PV_MM_MaterialUnidad AS MU (NOLOCK)
			ON WDL.Order_Unit = MU.Unidad
		WHERE m.DescripcionCorta is null
		AND WDL.Short_Text IS NOT NULL

		--============================================================
		--Convertimos los tipos de Dato
		insert	into	#tmpData
		select	--top 1
				Id						=	RowN ,--ROW_NUMBER() OVER( ORDER BY RowN),
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
				Net_Price				=	case when isnumeric(Net_Price) = 1 then cast(replace(Net_Price,',','') as float) else null end,
				Currency				=	case when len(Currency)					= 0 then null else Currency					end,
				Vendor_Supplying_Plant	=	case when len(Vendor_Supplying_Plant)	= 0 then null else Vendor_Supplying_Plant	end,
				Purchasing_Document		=	case when len(Purchasing_Document)		= 0 then null else Purchasing_Document		end,
				Release_State			=	case when len(Release_State)			= 0 then null else Release_State			end,
				Name_of_Vendor,
				Order_Price_Unit,
				Net_Order_Value			=	case when isnumeric(Net_Order_Value) = 1 then cast(replace(Net_Order_Value,',','') as float) else null end  ,--case when len(Net_Order_Value)			= 0 then cast(replace(Net_Order_Value,',','') as float)	end,
				Requisitioner			=	case when len(Requisitioner)			= 0 then null else Requisitioner									end,
				Terminos_Pago			=	CAST(Terminos_Pago AS varchar),
				Justificacion			=	case when len(Justificacion)			= 0 then null else Justificacion									end,
				Pais					=	substring(WBS_Element,0,3),
				Contrato				=	substring(WBS_Element,4,3),
				FaseContrato			=	substring(WBS_Element,7,1),
				CentroCosto				=	substring(WBS_Element,9,2),
				ConsecutivoPozo			=	substring(WBS_Element,12,3),
				TareaPresupuesto		=	cast(replace(substring(WBS_Element,15,3),'.','') as int),  --MX-OGA-OP-000132.B000NO
				SubTareaPresupuesto		=	substring(WBS_Element,19,1),
				x						=	substring(WBS_Element,20,10)
		from	WDEA_Layout_T
		where	IdBitacoraLectura	=	@IdBitacoraLectura	--CreadoEL	< @fecha --'2021-09-06'
	
		--	/*Validaciones*/

			/*Item*/
			insert into #tmpErrores	select Id, 'A', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el número de partida en la celda A, Fila '+cast(Id as varchar(10))+'.',1				
			from #tmpData where Item is null order by Id
			/*******************/
			/*Purch_Organization*/
			insert into #tmpErrores	select Id, 'B', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el contrato en la celda B, Fila '+cast(Id as varchar(10))+'.',1						
			from #tmpData where Purch_Organization is null order by Id

			insert into #tmpErrores	select Id, 'B', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el contrato en la celda B, Fila '+cast(Id as varchar(10))+'.',1						
			from #tmpData where Purch_Organization not in ('MOG','MCY','M30','M16','M17') order by Id
			/*******************/
			/*WBS_Element*/
			insert into #tmpErrores	
			SELECT t.Id, 'C', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró un centro de costos relacionado al WBS_Element en la celda C, Fila '+cast(t.Id as varchar(10))+'.',1
			FROM #tmpData AS t
			LEFT JOIN WDEA_SAP_CentroCostos WDCC (NOLOCK)
				ON dbo.WDEA_CC_SplitString(t.WBS_Element,'-') = WDCC.AcronimoSAP
				AND WDCC.Activo = 1
			where AcronimoSAP is null or WDCC.Activo = 0
	
			insert into #tmpErrores
			select Id, 'D', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró WBS Element en la celda D, Fila '+cast(Id as varchar(10))+'.',1												
			from #tmpData where WBS_Element is null order by Id
			
			--==================================================			
			insert into #tmpErrores
			select		DWL.ID,	'D',  'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, posiblemente a lo siguiente : El WBS no existe, La linea de presupuesto no está relacionada a un WBS o estas están desactivadas en ADINCO. Celda D  , Fila '	+	cast(DWL.Id as varchar(10))	+	' .',1
			from		#tmpData DWL
			LEFT JOIN WDEA_WBS WBS (NOLOCK)
				ON RTRIM(LTRIM(dwl.WBS_Element)) = RTRIM(LTRIM(WBS.WBS)) COLLATE SQL_Latin1_General_CP1_CI_AS	
			LEFT JOIN WDEA_WBSLineaPresupuesto WLP (NOLOCK)
				ON WBS.Id = WLP.IdWBS
			where 
			WBS.Id Is null
			or 
			WBS.Activo = 0
			or
			WLP.Id is null
			or 
			WLP.Activo = 0
			
			/*******************/
	
	
			
			/*Validity_Per_Start*/
			insert into #tmpErrores	select Id, 'G', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la fecha de inicio en la celda G, Fila '+cast(Id as varchar(10))+'.',1				from #tmpData 
			where Validity_Per_Start is null order by Id

			insert into #tmpErrores	select Id, 'G', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : El formato de la fecha de inicio en la celda G, Fila '+cast(Id as varchar(10))+' es incorrecto.',1	from #tmpData 
			where	Validity_Per_Start is not null 
			and		(year(Validity_Per_Start) < 1900)
			and		(month(Validity_Per_Start) < 1 or month(Validity_Per_Start)>12)
			and		(day(Validity_Per_Start) < 1 and day(Validity_Per_Start)>31)
			order by Id
			/*******************/
	
			/*Validity_Per_Start*/
			insert into #tmpErrores	select Id, 'H', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la fecha de fin en la celda H, Fila '+cast(Id as varchar(10))+'.',1				
			from #tmpData where Validity_Period_End is null order by Id

			insert into #tmpErrores	select Id, 'H', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : El formato de la fecha de fin en la celda H, Fila '+cast(Id as varchar(10))+' es incorrecto.',1	
			from #tmpData 
			where	Validity_Period_End is not null 
			and		year(Validity_Period_End) <1900
			and		(month(Validity_Period_End) < 1 and month(Validity_Period_End)>12)
			and		(day(Validity_Period_End) < 1 and day(Validity_Period_End)>31)
			order by Id
			/*******************/

			/*Plant*/
			insert into #tmpErrores	select Id, 'J', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la empresa en la celda J, Fila '+cast(Id as varchar(10))+'.',1						
			from #tmpData where Plant is null order by Id
			--insert into #tmpErrores select Id, 'J', 'La columna Plant contiene diferente a MX01'														from #tmpData where Plant <> 'MX01' order by Id
			/*******************/

			/*Order_Quantity*/
			insert into #tmpErrores	select Id, 'K', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la cantidad de la partida en la celda K, Fila '+cast(Id as varchar(10))+'.',1		
			from #tmpData where Order_Quantity is null order by Id

			insert into #tmpErrores	select Id, 'K', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La cantidad de la partida en la celda K, Fila '+cast(Id as varchar(10))

			+' no tiene el formato numérico esperado.',1																								from #tmpData where len( cast(Order_Quantity - cast(Order_Quantity as int) as varchar(10))) >6 order by Id
			/*******************/

			/*Order_Unit*/
			  insert into #tmpErrores select Id, 'L', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la unidad de la partida en la celda L, Fila '+cast(Id as varchar(10))+'.',1   
			  from #tmpData where Order_Unit is null order by Id  
			/*******************/

			/*Net_Price*/
			insert into #tmpErrores	select Id, 'M', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el costo de la partida en la celda M, Fila '+cast(Id as varchar(10))+'.',1			
			from #tmpData where Net_Price is null order by Id
	
			insert into #tmpErrores	select Id, 'M', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La cantidad de la partida en la celda M, Fila '+cast(Id as varchar(10))+' no tiene el formato numérico esperado',1																									
			from #tmpData where Net_Price is null order by Id
			/*******************/

			/*Currency*/
			insert into #tmpErrores	select Id, 'N', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la moneda en la celda N, Fila '+cast(Id as varchar(10))+'.',1						
			from #tmpData where Currency is null order by Id
			/*******************/

			/*Vendor_Supplying_Plant*/
			insert into #tmpErrores	select Id, 'O', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el registro en la celda O, Fila '+cast(Id as varchar(10))+'',1						
			from #tmpData where Vendor_Supplying_Plant is null order by Id
			--Se inserta en la temporal #tmpVendorSupplyingPlant registros de aquellos que si estan en el catálogo
			insert into #tmpVendorSupplyingPlant
			select		t1.Id,
						p.IdProveedor 
			from		#tmpData					t1
			inner join	S_Proveedor	p (NOLOCK)
			on			t1.Vendor_Supplying_Plant	= p.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
			where		t1.Vendor_Supplying_Plant is not null 
			and p.Activo = 1
			order by t1.Id
			
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
			select Id, 'P', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el número de orden de compra de SAP en la celda P, Fila '+cast(Id as varchar(10))+'.',1																								
			from #tmpData where Purchasing_Document is null order by Id
			/*******************/

			/*Net_Order_Value*/
			insert into #tmpErrores
			select Id, 'T', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' No pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el costo de la orden de compra en la celda T, Fila '+cast(Id as varchar(10))+'.',1																
			from #tmpData where Net_Order_Value is null order by Id

			insert into #tmpErrores
			select Id, 'T', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' No pudo ser registrada en ADINCO, debido al siguiente problema : La cantidad de la partida en la celda T, Fila '+cast(Id as varchar(10))+' no tiene el formato numérico esperado',1													
			from #tmpData where len( cast(Net_Order_Value - cast(Net_Order_Value as int) as varchar(10))) >6 order by Id
			/*******************/	
	
			/*Requisitioner*/				
			insert into #tmpErrores
			select Id, 'U', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró el usuario requisitor en la celda U, Fila '+cast(Id as varchar(10))+'.',1	
			from #tmpData where Requisitioner is null order by Id
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
			select		t1.ID,	'U', 'La orden de compra '+cast(isnull(t1.Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : El usuario requisitor ' + t1.Requisitioner + ' (celda U, Fila '+cast(isnull(t1.Id,'') as varchar(10))+') No existe en ADINCO.',1
			from		#tmpData					t1
			left join	#tmpRequisitioner			t2
			on			t1.ID						=	t2.ID
			where		t2.ID						is	null
			order by	1,2

			--select * from #tmpData
			/*Terminos_Pago*/
			insert into #tmpErrores
			select Id, 'V', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontraron términos de pago en la celda V, Fila '+cast(Id as varchar(10))+'.',1										
			from #tmpData where Terminos_Pago is null order by Id

			--select * from #tmpData

			--insert into #tmpErrores
			--select Id, 'V', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontraron términos de pago en la Celda V, fila '+cast(Id as varchar(10))+'.',1  from #tmpData where len(Terminos_Pago) = 0 or (len(Terminos_Pago) > 0 and CAST(Terminos_Pago as VARCHAR(10)) LIKE '%.%' ) order by Id

			/*Justificacion*/
			insert into #tmpErrores 
			select Id, 'W', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró la justificación en la celda W, Fila '+cast(Id as varchar(10))+'.',1											
			from #tmpData where Justificacion is null order by Id
			
			insert into	#tmpMateriales
			select		t1.Id,
						min(mat.IdMaterial),
						mat.DescripcionCorta,
						mat.IdProveedor
			from		#tmpData		t1
			inner join	dbo.MM_Material											mat 
			on			t1.Short_Text COLLATE SQL_Latin1_General_CP1_CI_AS =	mat.DescripcionCorta
			and			@IdProveedorWDEA =										mat.IdProveedor
			where		mat.IsEliminado					=	0
			and			mat.Activo						=	1
			group by	t1.Id,
						mat.DescripcionCorta,
						mat.IdProveedor


		--#tmpMaterialesEncontrados
		/*SE MODIFICA ESTA VALIDACIÓN PARA VALIDAR UNICAMENTE QUE LA UNIDAD, Y EL MATERIAL NO SEAN NULOS*/

			-- No existe el material
			insert into #tmpErrores 
			select t1.Id, 'E', 'La orden de compra '+cast(isnull(Purchasing_Document,'') as varchar(50))+' no pudo ser registrada en ADINCO, debido al siguiente problema : No se encontró un Material en la celda E, Fila'+cast(t1.Id as varchar(10))+'.',1											
			from		#tmpData t1
			where		T1.Short_Text IS NULL


			insert into #tmpIncompletedOCs
			select LEFT(replace(Error,'La orden de compra ',''), CHARINDEX(' ',replace(Error,'La orden de compra ','')+'')-1)  from #tmpErrores

			--select * from #tmpIncompletedOCs

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
		AND			T1.Order_Unit		IS NOT NULL
		
		group by	Purchasing_Document

		--select * from #tmpRegistrosValidadosPorDocumento

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

		
		delete		#tmpRegistrosValidadosPorDocumento
		from		#tmpRegistrosValidadosPorDocumento	t1
		inner join	#tmpIncompletedOCs					t2
		on			t1.Purchasing_Document				=	t2.OC


		/*Se guardan todos los errores en la nueva Bitacora*/
		insert into WDEA_Bitacora_AdincoSAP
		select	getdate(), Error , ROW_NUMBER() OVER( ORDER BY esError,RowID), @IdBitacoraLectura, 0 from #tmpErrores where esError = 1 group by esError, RowId, Columna, Error order by RowId
		
		--select 22,* from WDEA_Bitacora_AdincoSAP where IdBitacoraLectura = @IdBitacoraLectura
		
		/*Se obtiene el consecutivo donde se quedó la bitacora*/
		select	@maxNoConsecutivo = max(NoConsecutivoProcesamiento) 
		from	WDEA_Bitacora_AdincoSAP 
		/*Se guarda un registro de aquellos rows que se procesaron con exito*/
		insert into WDEA_Bitacora_AdincoSAP
		select	getdate(), Error , ROW_NUMBER() OVER( ORDER BY esError,RowID)+@maxNoConsecutivo, @IdBitacoraLectura, 1 
		from #tmpErrores where esError = 0 group by esError, RowId, Columna, Error order by RowId
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- INSERSIÓN CORRECTA A LA TABLA WDEA_PurchasingDocumentsImportados
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		insert into WDEA_PurchasingDocumentsImportados
					(	
		IDLAYOUT,					ITEM,						PURCHASE_ORGANIZATION,	IDCONTRATO,		COST_CENTER,			WBS_ELEMENT,	
		IDLINEAPRESUPUESTOMES,		OUTLINE_AGREEMENT,			SHORT_TEXT,				IDMATERIAL,		VALIDITY_PER_START,		VALIDITY_PER_END,	
		DELETION_INDICATOR,			PLANT,						ORDER_QUANTITY,			ORDER_UNIT,		IDUNIDAD,				NET_PRICE,		
		CURRENCY,					IDMONEDA,					VENDOR_SUPPLIYING_PLANT,IDPROVEEDOR,	PURCHASING_DOCUMENT,	RELEASE_STATE,		
		NAME_OF_VENDOR,				ORDER_PRICE_UNIT,			NET_ORDER_VALUE,		REQUISITIONER,	IDUSUARIOSOLICITANTE,	TERMINOS_DE_PAGO,	
		JUSTIFICACION,				IdBitacora)
		select   
		@IdBitacoraLectura,			Item,						Purch_Organization,		PO.IdContrato,	CC.idcentrocosto,		T1.WBS_Element, 
		WLP.IdLineaPresupuesto,	OUTLINE_AGREEMENT,			Short_Text,				mat.IdMaterial,	Validity_Per_Start,		Validity_Period_End,
		Deletion_Indicador,			Plant,						Order_Quantity,			Order_Unit,		u.IdUnidad,				Net_Price,  
		Currency,					IdMoneda,					Vendor_Supplying_Plant, p.IdProveedor,	Purchasing_Document,	Release_State,  
		Name_of_Vendor,				Order_Price_Unit,			Net_Order_Value,		Requisitioner,  re.IdUsuario,			ISNULL(TCC.DiasCredito,0),  
		Justificacion,				@IdBitacoraLectura  
		FROM		#tmpData						t1
		inner join	PurchaseOrganization			po (NOLOCK)
		ON			t1.Contrato						=		po.siglas COLLATE SQL_Latin1_General_CP1_CI_AS
		inner join	Adinco..PV_TipoMoneda			mo (NOLOCK)
		ON			t1.Currency =					mo.TipoMonedaCorto				
		inner join	S_Proveedor		p	(NOLOCK)
		ON			t1.Vendor_Supplying_Plant COLLATE SQL_Latin1_General_CP1_CI_AS = P.RFC
		inner join	#tmpRequisitioner				re
		ON			t1.ID =							re.Id
		inner join	dbo.PV_MM_MaterialUnidad		u (NOLOCK)
		ON			t1.Order_Unit COLLATE SQL_Latin1_General_CP1_CI_AS = u.umb
		inner join	#tmpMateriales					mat (NOLOCK)
		ON			t1.Short_Text COLLATE SQL_Latin1_General_CP1_CI_AS = mat.DescripcionCorta
		and			t1.id =							mat.ID
		and			@IdProveedorWDEA =				mat.IdProvedor
		left join	#tmpErrores						t2
			on			t1.ID =							t2.RowId
			and			1 =								t2.esError
		left join	#tmpIncompletedOCs				t3
			ON			rtrim(ltrim(Purchasing_Document)) = rtrim(ltrim(t3.OC))
		LEFT JOIN	WDEA_SAP_CentroCostos			WDCC
			ON			dbo.WDEA_CC_SplitString(t1.WBS_Element,'-') = WDCC.AcronimoSAP 
	    JOIN		CC_CentroCosto					CC  (NOLOCK)
			ON			WDCC.IdCentroCostosADINCO		=			CC.IdCentroCosto 
			AND			WDCC.Activo						=			1
		LEFT JOIN   WDEA_SAP_TerminosCondiciones	TCC (NOLOCK)
			ON			t1.Terminos_Pago COLLATE SQL_Latin1_General_CP1_CI_AS = TCC.Clabe
		JOIN WDEA_WBS AS WBS (NOLOCK)
			ON RTRIM(LTRIM(T1.WBS_Element)) = RTRIM(LTRIM(WBS.WBS)) COLLATE SQL_Latin1_General_CP1_CI_AS	
			AND WBS.Activo = 1	
			AND po.IdContrato = WBS.IdContrato
		JOIN WDEA_WBSLineaPresupuesto WLP
			ON WBS.Id = WLP.IdWBS
			AND WLP.Activo = 1
		WHERE		t2.RowId						is	null
		and			t3.OC							is	null
		and			isnull(p.IsEliminado,0)					=	0
		and			u.IsEliminado					=	0
		and			t1.Short_Text					is not null
		and			t1.Order_Unit					is not null
		and			p.Activo						= 1
		and			t1.Terminos_Pago				IS NOT NULL;

		INSERT INTO PendientesProcesarProcura_WSDEA
		(
			IdBitacora
		)
		VALUES
		(
			@IdBitacoraLectura
		);

END
