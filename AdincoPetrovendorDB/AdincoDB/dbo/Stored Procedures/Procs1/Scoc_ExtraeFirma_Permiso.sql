/****** Object:  StoredProcedure [dbo].[Scoc_ExtraeFirma_Permiso]    Script Date: 08/02/2019 10:45:56 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 28/01/198
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[Scoc_ExtraeFirma_Permiso]--10061,10010,2,'20181201'
    @idUsuario  INT,
    @idContrato INT,
    @idPermiso  INT,
    @Mes DATE
AS
    BEGIN
        SET NOCOUNT ON;
    	  SELECT TOP 1 ISNULL( RazonSocial,'') AS RazonSocial,
          ISNULL(  'Certificado emitido por: ' + Emisor + CHAR(10) + 'Caducidad Certificado: '
               +replace(
			   convert(NVARCHAR, FechaCaducidad, 106)
			   , ' ', '/'),'') AS firma,

			  ISNULL(RazonSocial+'.'+CHAR(10)+'Certificado emitido por: ' + Emisor + CHAR(10) + 'Caducidad Certificado: '
               +replace(
			   convert(NVARCHAR, FechaCaducidad, 106)
			   , ' ', '/'),'') AS firmaJunta,

			 ISNULL(FE.FecMovto,HA.FecMovto) AS horaFirma 
        FROM
               dbo.SCOC_FirmaElectronica FE
			RIGHT JOIN dbo.SCOC_HistorialAprobaciones HA ON HA.IdPermiso = FE.IdPermiso AND 
			   HA.MesReporte = FE.MesReporte AND
			    HA.IdContrato = FE.IdContrato 
        WHERE
               HA.IdPermiso = @idPermiso
               AND HA.MesReporte = @Mes
               AND HA.IdContrato = @idContrato
			   AND Rechazado =0-- OR idestatus=10000
        ORDER BY
               FE.FecMovto, HA.FecMovto DESC;
    END;