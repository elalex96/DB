
CREATE PROCEDURE [dbo].[SP_PC_ContratosContratista] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario  INT
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 30-10-17
-- Description:	
-- ---------------------------------------------
-- 20180521	BAAC	Se modifica para mostrar los contratos de Licencia en consorcio con Pemex
-- =============================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON
    -- Insert statements for procedure here
    DECLARE @IdContratista INT 
    SELECT @IdContratista = IdContratista 
    FROM dbo.CO_Contrato 
    WHERE IdContrato = @IdContrato

         SELECT IdContrato,
                NumeroContrato
         FROM CO_Contrato
         WHERE IdContratista = @IdContratista
               AND ( IsPC = 1 OR IsConsorcio = 1)
END

