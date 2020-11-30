-- =============================================
-- Author:		Reyna Olvera
-- Create date: 28/01/198
-- Description:
-- =============================================
CREATE  PROCEDURE [dbo].[Scoc_ExtraeDocumentoForatoSoporteReinicio]--'20181101',10061,10040,23
	@Mes DATE,
	@idUsuario int,
	@idContrato INT,
	@TipoDocumento INT,
	@idPermiso INT
    
AS
BEGIN
	SET NOCOUNT ON;
IF @TipoDocumento=23 OR @TipoDocumento=24
BEGIN
SELECT FormatoAmazonID,NombreArchivo
 FROM SCOC_FormatoAmazon
        JOIN dbo.SCOC_EnvioNotificacion
            ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
               AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
    WHERE SCOC_FormatoAmazon.idContrato = @idContrato AND 
	dbo.SCOC_EnvioNotificacion.MesReporte=@Mes
	 AND OpcionReporte=@TipoDocumento
 END
 ELSE IF @idPermiso=9--Comercializador de liquidos
 BEGIN
 SELECT FormatoAmazonID,NombreArchivo
 FROM SCOC_FormatoAmazon
        JOIN dbo.SCOC_EnvioNotificacion
            ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
               AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
    WHERE SCOC_FormatoAmazon.idContrato = @idContrato AND 
	dbo.SCOC_EnvioNotificacion.MesReporte=@Mes
	 AND OpcionReporte IN (2,4, 15,17,25)--=25
END
ELSE IF @idPermiso=10--Comercializador de gas
 BEGIN
 SELECT FormatoAmazonID,NombreArchivo
 FROM SCOC_FormatoAmazon
        JOIN dbo.SCOC_EnvioNotificacion
            ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
               AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
    WHERE SCOC_FormatoAmazon.idContrato = @idContrato AND 
	dbo.SCOC_EnvioNotificacion.MesReporte=@Mes
	 AND OpcionReporte IN( 1,3,5, 14,16,18,26,27)-- (26,27)
END
ELSE IF @idPermiso=6--SCOC
BEGIN
SELECT FormatoAmazonID,NombreArchivo
 FROM SCOC_FormatoAmazon
        JOIN dbo.SCOC_EnvioNotificacion
            ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
               AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
    WHERE SCOC_FormatoAmazon.idContrato = @idContrato AND 
	dbo.SCOC_EnvioNotificacion.MesReporte=@Mes AND OpcionReporte  NOT IN(23,24)
END
ELSE
SELECT FormatoAmazonID,NombreArchivo
 FROM SCOC_FormatoAmazon
        JOIN dbo.SCOC_EnvioNotificacion
            ON SCOC_EnvioNotificacion.idContrato = SCOC_FormatoAmazon.idContrato
               AND SCOC_EnvioNotificacion.MesReporte = SCOC_FormatoAmazon.MesReporte
    WHERE SCOC_FormatoAmazon.idContrato = @idContrato AND 
	dbo.SCOC_EnvioNotificacion.MesReporte=@Mes AND OpcionReporte  NOT IN(23,24,25,26,27)
END
