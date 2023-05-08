-- =============================================
-- Author:		Manuel CD
-- Create date: 10-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_VaciarIngresos] 
	-- Add the parameters for the stored procedure here
@Mes        NVARCHAR(50),
@IdUsuario  INT,
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             DELETE PC_Ingresos
             WHERE MES = @Mes;
         END;