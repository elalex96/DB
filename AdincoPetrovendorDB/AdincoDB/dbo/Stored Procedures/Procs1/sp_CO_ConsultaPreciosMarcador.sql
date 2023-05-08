-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description:	Consulta el precio del marcador de una contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaPreciosMarcador] 
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
--@IdMarcador INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SET LANGUAGE spanish;
         SELECT PMM.IdPrecioMarcadorMensual, 
                PMM.IdMarcador, 
                M.MarcadorCorto, 
                M.Marcador, 
                PMM.Mes, 
                PMM.Precio, 
                RIGHT('00'+CAST(MONTH(PMM.Mes) AS VARCHAR(2)), 2)+' '+DATENAME(MONTH, PMM.Mes) AS NombreMes, 
                DATENAME(YEAR, PMM.Mes) AS Anio, 
                UC.Nombre AS CreadoPor, 
                PMM.CreadoEn, 
                UM.Nombre AS ModificadoPor, 
                PMM.ModificadoEl
         FROM dbo.CO_PrecioMarcadorMensual AS PMM
              INNER JOIN dbo.CO_Marcador AS M ON PMM.IdMarcador = M.IdMarcador
              LEFT JOIN dbo.AP_Usuario UC ON PMM.CreadoPor = UC.UsuarioID
              LEFT JOIN dbo.AP_Usuario UM ON PMM.ModificadoPor = UM.UsuarioID
         WHERE(PMM.IdContrato = @IdContrato)
              --AND (PMM.IdMarcador = @IdMarcador)
              AND YEAR(PMM.Mes) <= YEAR(CURRENT_TIMESTAMP);
     END;