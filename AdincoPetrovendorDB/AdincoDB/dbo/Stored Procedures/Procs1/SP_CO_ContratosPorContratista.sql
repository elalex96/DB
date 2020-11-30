-- =============================================
-- Author:		Marcos Garcia
-- Create date: 05-12-2019
-- Description:	Selecciona los Contratos por Contratista
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ContratosPorContratista] 
--[SP_CO_ContratosPorContratista]  3,10002
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         --======Seleccion del Contratista=========
         DECLARE @IdContratista INT;
         --===============
         SET @IdContratista =
         (
             SELECT IdContratista
             FROM dbo.CO_Contrato
             WHERE IdContrato = @IdContrato
         );
         --=======Contratos con el mismo Contratista========
         --Solo Para Jaguar
         IF(@IdContratista = 10005
            OR @IdContratista = 10006)
             BEGIN
                 SELECT IdContrato, 
                        NumeroContrato
                 FROM dbo.CO_Contrato
                 WHERE IdContratista IN(10005, 10006)
                 AND Activo = 1;
             END;
             ELSE
             BEGIN
                 SELECT IdContrato, 
                        NumeroContrato
                 FROM dbo.CO_Contrato
                 WHERE IdContratista = @IdContratista
                       AND Activo = 1;
             END;
     END;