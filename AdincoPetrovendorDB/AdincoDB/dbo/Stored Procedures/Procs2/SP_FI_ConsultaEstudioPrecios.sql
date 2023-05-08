-- =============================================
-- Author:		Manuel CD
-- Create date: 12-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaEstudioPrecios]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         SELECT IdEstudioPrecioTransfer, 
                EPT.Nombre, 
                SUBSTRING(Descripcion, 0, 30) AS Descripcion, 
                FolioOperacion,
                CASE
                    WHEN ISNULL(ProcesadoSIPAC, 0) = 0
                    THEN 'NO'
                    ELSE 'SI'
                END AS Presentado, 
                EPT.FechaInicioVigencia, 
                EPT.FechaFinVigencia, 
                EPT.FechaCargaSIPAC, 
                S.RazonSocial AS EmpresaRelacionada, 
                U.Nombre AS CreadoPor, 
                EPT.CreadoEn,
                CASE
                    WHEN EPT.Archivo LIKE 0x
                         OR EPT.Archivo IS NULL
                    THEN '¡PDF NO CARGADO!'
                    ELSE 'Pdf Cargado'
                END AS Archivo
         FROM FI_EstudioPreciosTransfer EPT
              JOIN AP_Usuario U ON EPT.CreadoPor = U.UsuarioID
              JOIN dbo.PV_Subcontratista S ON S.IdSubcontratista = EPT.IdSubcontratista
         WHERE(IdContrato = @IdContrato)
         ORDER BY IdEstudioPrecioTransfer DESC;
     END;