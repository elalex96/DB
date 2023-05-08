-- =============================================
-- Author:		Manuel CD
-- Create date: 16-01-2018
-- Description:	
-- =============================================
CREATE PROCEDURE SP_PC_VaciarVentasAsignacion 
	-- Add the parameters for the stored procedure here
@IdUsuario  INT,
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             DELETE PC_VentasAsignacion;
         END;

