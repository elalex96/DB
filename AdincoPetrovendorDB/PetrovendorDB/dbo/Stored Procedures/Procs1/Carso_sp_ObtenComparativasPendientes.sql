DROP PROCEDURE IF EXISTS Carso_sp_ObtenComparativasPendientes
	GO
	-- =============================================  
	-- Author:  <Luis David>  
	-- Create date: <22/10/2021>  
	-- Description: <Se obtienen las comparativas no procesadas>  
	-- =============================================  
	CREATE PROCEDURE Carso_sp_ObtenComparativasPendientes
	AS
	BEGIN
	SELECT 
	CC.Id,
	CC.[FechaEntrega] ,		CC.[TipoAdjudicacion] ,	CC.[JustificacionPedido] ,
	CC.[Aprobadores],			CC.[MensajeAprobacion] ,
	CC.[IdComparativa],
	CC.[p6] ,					CC.[p7] ,					CC.[p8] ,
	CC.[p9] ,					CC.[p10],					CC.[DataAreaID],
	--==
	CD.Id as IdCabecera,
	CD.[LineaPresupuesto]
	,CD.[IdLineaPresupuesto]
	,CD.[IdPosicion]
	,CD.[Item]
	,CD.[Cantidad]
	,CD.[Unidad]	
	,CD.[IdUnidad]	
	,CD.[LugarEntrega]
	,CD.[Instalacion]
	,CD.[IdInstalacion]
	,CD.[CentroCosto]
	,CD.[IdCentroCosto]					
		,CD.[p1]					
		,CD.[p2]
		,CD.[p3]				
		,CD.[p4]					
		,CD.[p5]
				
		
	FROM 
	Carso_Items_comparativaCabecera as CC
	join Carso_Items_comparativaDetalle as CD
	ON CC.id = CD.IdCabecera
	WHERE CC.Procesado = 0
	END