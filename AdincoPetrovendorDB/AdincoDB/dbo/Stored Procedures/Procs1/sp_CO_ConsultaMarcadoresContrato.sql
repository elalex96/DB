-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Consulta la lista de marcadores para un contrato 
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaMarcadoresContrato]
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT M.IdMarcador, 
                M.MarcadorCorto, 
                M.Marcador
         FROM dbo.CO_ContratoMarcador CM
              INNER JOIN dbo.CO_Marcador M ON CM.IdMarcador = M.IdMarcador
         WHERE CM.IdContrato = @IdContrato;
     END;