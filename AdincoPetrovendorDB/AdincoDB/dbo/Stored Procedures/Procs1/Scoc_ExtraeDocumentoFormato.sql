/****** Object:  StoredProcedure [dbo].[Scoc_ExtraeDocumentoFormato]    Script Date: 08/02/2019 09:49:56 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/05/28
-- Description:	Extrae los documentos que fueron enviados de acuerdo a la version
-- =============================================
CREATE  PROCEDURE [dbo].[Scoc_ExtraeDocumentoFormato]--'20181201',10061,10010
	@Mes DATE,
	@idUsuario int,
	@idContrato int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT FormatoAmazonID,NombreArchivo
 FROM SCOC_FormatoAmazon
        JOIN dbo.SCOC_EnvioNotificacion
            ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
               AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
    WHERE SCOC_FormatoAmazon.idContrato =@idContrato 
	AND dbo.SCOC_EnvioNotificacion.MesReporte=@Mes 
	AND (OpcionReporte  NOT IN(23,24)) --NOT IN(23,24,25,26,27))
          
END
