-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description:	Consulta los Volumenes de Producción Mensuales
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaVolumenProduccionMensualCIEP] 
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish;
         -- Insert statements for procedure here
         SELECT PCM.IdProduccionCrudoMensual, 
                PCM.QCE AS Barriles, 
                PCM.API, 
                PCM.Mes, 
                RIGHT('00'+CAST(MONTH(PCM.Mes) AS VARCHAR(2)), 2)+' '+DATENAME(month, PCM.Mes) AS NombreMes, 
                DATENAME(YEAR, PCM.Mes) AS Anio, 
                AC.NombreAreaContractual, 
                RIGHT('00'+CAST(MONTH(PCM.Mes) AS VARCHAR(2)), 2)+' '+SUBSTRING(DATENAME(month, PCM.Mes), 1, 3)+' '+DATENAME(YEAR, PCM.Mes) AS MesAnio, 
                UC.Nombre AS CreadoPor, 
                PCM.CreadoEl, 
                UM.Nombre AS ModificadoPor, 
                PCM.ModificadoEl
         FROM dbo.CO_ProduccionCrudoMensualCIEP PCM
              LEFT JOIN dbo.CO_Contrato CO ON CO.IdContrato = PCM.idcontrato
              LEFT JOIN dbo.CO_AreaContractual AC ON ac.IdAreaContractual = CO.IdAreaContractual
              LEFT JOIN dbo.AP_Usuario UC ON PCM.CreadoPor = UC.UsuarioID
              LEFT JOIN dbo.AP_Usuario UM ON PCM.ModificadoPor = UM.UsuarioID
         WHERE(PCM.IdContrato = @IdContrato)
         ORDER BY PCM.Mes;
     END;