-- =============================================  
-- Author:  <Luis David>  
-- Create date: <21/10/2021>  
-- Description: <Se guarda la tabla de Carso>  
-- =============================================  
CREATE PROCEDURE [dbo].[Carso_InsertaItemsDetalle] 
@LayoutCarso dbo.CARSO_ItemDetalle READONLY,
@IdCabecera int
AS
BEGIN
	INSERT INTO Carso_Items_comparativaDetalle
	(
		LineaPresupuesto ,	Item ,	Cantidad ,		CentroCosto ,
		Unidad ,			LugarEntrega ,			Instalacion ,
		IdPosicion ,		p1 ,					p2 ,
		p3 ,				p4 ,					p5 ,
		IdLineaPresupuesto,	IdUnidad,				IdInstalacion,
		IdCentroCosto,		IdCabecera)
	SELECT 
		[LineaPresupuesto]	,[Item]	,[Cantidad]		,[CentroCosto]
		,[Unidad]			,[LugarEntrega]			,[Instalacion]
		,[IdPosicion]		,[p1]					,[p2]
		,[p3]				,[p4]					,[p5]
		,[IdLineaPresupuesto],[IdUnidad]			,[IdInstalacion]
		,[IdCentroCosto],	@IdCabecera
	FROM @LayoutCarso

	select isnull(Max(id),0) as Id from Carso_Items_comparativaDetalle
END