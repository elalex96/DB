-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-03-2020
-- Description:	Archivos cargados de las instancias de entregables, última versión y no reachazados.
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_EniInstanciasExternoArchivos] 
	-- Add the parameters for the stored procedure here
	@IdContrato            INT, 
	@IdUsuario             INT, 
	@IdInstanciaEntregable INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON

         -- Insert statements for procedure here
         SELECT ED.DocumentoEntregableId, 
                ED.NombreArchivo, 
                MAX(HALT.IdLineaTiempo) AS Versionn, 
                ED.Bucket, 
                ED.Folder, 
                ED.UUIDAmazon, 
                IE.idInstanciaEntregable, 
                LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo)))) AS TipoArchivo
         FROM dbo.EN_InstanciasEntregable IE
              JOIN dbo.EN_HistorialAprobacionesLineaTiempo HALT ON IE.idInstanciaEntregable = HALT.idInstanciaEntregable
                                                                   AND HALT.Rechazado = 0
              JOIN dbo.EN_DocumentoVersion DE ON HALT.idInstanciaEntregable = DE.idInstanciaEntregable
              JOIN dbo.EN_EntregableDocumento ED ON DE.DocumentoEntregableId = ED.DocumentoEntregableId
                                                    AND ED.idTipoArchivo = 10000
                                                    AND ED.Activo = 1
         WHERE IE.idInstanciaEntregable = @IdInstanciaEntregable
         GROUP BY ED.DocumentoEntregableId, 
                  ED.NombreArchivo, 
                  ED.Bucket, 
                  ED.Folder, 
                  ED.UUIDAmazon, 
                  IE.idInstanciaEntregable, 
                  LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.',ED.NOMBREARCHIVO,LEN(ED.NOMBREARCHIVO)-5), LEN(ED.NombreArchivo))))
     END