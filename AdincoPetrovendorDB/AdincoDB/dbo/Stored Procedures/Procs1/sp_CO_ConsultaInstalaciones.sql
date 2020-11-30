-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaInstalaciones] 
-- Add the parameters for the stored procedure here
@IdContrato INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @IdAreacontractual AS INT;
         SELECT @IdAreacontractual = IdAreaContractual
         FROM dbo.CO_Contrato
         WHERE idcontrato = @IdContrato;

         /**/

         SELECT I.IdInstalacion, 
                I.NombreInstalacion, 
                I.IdInstalacionPemex, 
                ACIEP.NombreActividad
         FROM dbo.CO_Instalacion I
              INNER JOIN dbo.CO_ActividadCIEP ACIEP ON I.IdActividad = ACIEP.IdActividad
         WHERE--(I.EsBolsa = 0) AND 
         I.IdAreaContractual = @IdAreaContractual;
     END;