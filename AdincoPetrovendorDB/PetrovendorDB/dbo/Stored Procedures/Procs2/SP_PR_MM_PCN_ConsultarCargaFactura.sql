DROP PROCEDURE IF EXISTS SP_PR_MM_PCN_ConsultarCargaFactura
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-08-17
-- Description:	Consulta Aceptaciones que tengan una carta de contenido nacional aprobada para adjuntarle una factura
-- =============================================
-- Author:		Luis David
-- Create date: 04/11/2021
-- Description:	Reacomodo de tablas para optimización
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_ConsultarCargaFactura]
	-- Add the parameters for the stored procedure here
@IdProveedor int ,
@IdAceptacionPedido int 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #FACTURAXML(IdTipoDocumento int, Documento nvarchar(300), Estatus nvarchar(300), FechaCarga datetime, FechaEvaluacion datetime)
    CREATE TABLE #FACTURAPDF(IdTipoDocumento int, Documento nvarchar(300), Estatus nvarchar(300), FechaCarga datetime, FechaEvaluacion datetime) 
	CREATE TABLE #FACTURA(IdTipoDocumento int, Documento nvarchar(300), Estatus nvarchar(300), FechaCarga datetime, FechaEvaluacion datetime)
	
	----VALIDAR SI EXISTE UNA ACEPTACION FACTURA DE X ACEPTACION SI NO CREARLA 

	DECLARE @IsAceptacionFactura INT =(SELECT COUNT(IdAceptacionFactura) 
									  FROM	MM_AceptacionFactura AS AF
									  WHERE IdAceptacionPedido = @IdAceptacionPedido)

	IF @IsAceptacionFactura = 0  

	BEGIN 
	 INSERT INTO MM_AceptacionFactura (IdAceptacionPedido, CreadoEl,IdEstatus, IdEstatusXML,IdEstatusPDF)
	 VALUES(@IdAceptacionPedido, GETDATE(), 1,4,4)

	END 
	 
	 INSERT INTO #FACTURAXML (IdTipoDocumento, Documento,Estatus,FechaCarga,FechaEvaluacion)
	 SELECT 18,'Factura XML', ISNULL(TV.TipoValidacion,'Sin Documento'), FechaCargaXML, FechaEvaluacionXML
	  
	 FROM MM_AceptacionFactura
	 LEFT JOIN S_TipoValidacionDoc AS TV 
	 ON IdEstatusXML = TV.IdTipoValidacionDoc
	 WHERE IdAceptacionPedido = @IdAceptacionPedido

	 INSERT INTO #FACTURAPDF (IdTipoDocumento, Documento,Estatus,FechaCarga,FechaEvaluacion)
	 SELECT 17,'Factura PDF', ISNULL(TV.TipoValidacion,'Sin Documento'), FechaCargaPDF, FechaEvaluacionPDF
	 FROM MM_AceptacionFactura
	 LEFT JOIN S_TipoValidacionDoc AS TV 
	 ON IdEstatusPDF = TV.IdTipoValidacionDoc
	 WHERE IdAceptacionPedido = @IdAceptacionPedido

	 INSERT INTO #FACTURA
	 SELECT * FROM #FACTURAPDF
	 UNION 
	 SELECT * FROM #FACTURAXML


	 SELECT IdTipoDocumento, Documento, Estatus, FechaCarga, FechaEvaluacion FROM #FACTURA


		 ---APC.IdEstatus=2 EStatus Aprobado 
     END;
