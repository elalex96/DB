-- =============================================
-- Author:		Manuel CD
-- Create date: 10-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_VaciarRM] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @NomContrato NVARCHAR(MAX);
		   --
             SELECT @NomContrato = NumeroContrato
             FROM dbo.CO_Contrato
             WHERE IdContrato = @IdContrato;
    --SELECT @NomContrato

    -- Insert statements for procedure here
             DELETE dbo.PC_RM
             WHERE [ID del contrato asignado por CNH (RF01_01)] = @NomContrato--'CNH-M1-EK-BALAM/2017'
         END;
